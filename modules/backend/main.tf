# ==============================================================================
# 1. S3 Storage (With Versioning for Reliability)
# ==============================================================================

resource "aws_s3_bucket" "app_data" {
  bucket_prefix = "${var.tags["Environment"]}-app-data-"
  tags = merge(var.tags, { Name = "${var.tags["Environment"]}-app-data" })
}

resource "aws_s3_bucket_versioning" "app_data_versioning" {
  bucket = aws_s3_bucket.app_data.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ==============================================================================
# 2. DynamoDB (Ideal for Session State in Active-Active)
# ==============================================================================

resource "aws_dynamodb_table" "app_sessions" {
  name = "${var.tags["Environment"]}-sessions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "SessionId"

  attribute {
    name = "SessionId"
    type = "S"
  }

  # Enabling streams is required if you want to upgrade this to a Global Table later
  stream_enabled = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  tags = merge(var.tags, { Name = "${var.tags["Environment"]}-sessions" })
}

# ==============================================================================
# 3. RDS Relational Database (PostgreSQL)
# ==============================================================================

resource "aws_security_group" "rds_sg" {
  name = "${var.tags["Environment"]}-rds-sg"
  description = "Allow database traffic from frontend"
  vpc_id = var.vpc_id

  ingress {
    description = "PostgreSQL from Frontend EC2"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [var.frontend_sg_id]
  }

  tags = merge(var.tags, { Name = "${var.tags["Environment"]}-rds-sg" })
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "${var.tags["Environment"]}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.tags["Environment"]}-rds-subnets" })
}

resource "aws_db_instance" "app_database" {
  identifier = "${var.tags["Environment"]}-app-db"
  engine = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"
  allocated_storage = 20
  db_name = "appdb"
  username = var.db_username
  password = var.db_password
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot = true # Set to false in production!

  tags = merge(var.tags, { Name = "${var.tags["Environment"]}-app-db" })
}

# ==============================================================================
# 4. IAM (Security Profiles for Frontend to access Backend)
# ==============================================================================

resource "aws_iam_role" "frontend_role" {
  name = "${var.tags["Environment"]}-frontend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "backend_access_policy" {
  name = "${var.tags["Environment"]}-backend-access-policy"
  description = "Allows EC2 to access S3 and DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.app_data.arn,
          "${aws_s3_bucket.app_data.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.app_sessions.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backend_access_attach" {
  role = aws_iam_role.frontend_role.name
  policy_arn = aws_iam_policy.backend_access_policy.arn
}

resource "aws_iam_instance_profile" "frontend_profile" {
  name = "${var.tags["Environment"]}-frontend-profile"
  role = aws_iam_role.frontend_role.name
}