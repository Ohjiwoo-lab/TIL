resource "aws_iam_user" "gildong_hong" {
    name = "gildong.hong"
}

resource "aws_iam_group" "devops_group" {
    name = "devops"
}

resource "aws_iam_group_membership" "devops" {
    name = aws_iam_group.devops_group.name

    users = [
        aws_iam_user.gildong_hong.name
    ]

    group = aws_iam_group.devops_group.name
}

resource "aws_iam_user_policy" "art_devops_black" {
  name  = "super-admin"
  user  = aws_iam_user.gildong_hong.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "*"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}