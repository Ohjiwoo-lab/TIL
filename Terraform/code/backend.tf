terraform {
    backend "s3" {
      bucket         = "tf101-jiwoo-apne2-tfstate"
      key            = "Dev/terraform/vpc/terraform.tfstate"
      region         = "ap-northeast-2"  
      encrypt        = true
      dynamodb_table = "terraform-lock"
    }
}