resource "aws_iam_user" "use1" {
  name = var.user_name
}

resource "aws_iam_group" "name" {
  name = var.group_name
}

resource "aws_iam_user_group_membership" "user_group_member" {
  user = aws_iam_user.use1

  groups = [aws_iam_group.name]
}

resource "aws_iam_policy" "s3Read" {
  name = "s3ReadOnly"
  policy = jsonencode({

    Version = "2012-10-17"
    Statement = [{

      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        "arn:aws:s3:::my-demo-bucket",
        "arn:aws:s3:::my-demo-bucket/*"
      ]
    }]
  })
}

resource "aws_iam_user_policy_attachment" "iam_polcy_attachment" {
  user       = aws_iam_user.use1.name
  policy_arn = aws_iam_policy.s3Read.arn
}


resource "aws_iam_role" "ec2-role" {

  name = "ec2-role"
  assume_role_policy = jsondecode({

    Version = "2012-10-17"
    Statement = [{

      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {

  role       = aws_iam_role.ec2-role.name
  policy_arn = aws_iam_policy.s3Read.arn

}