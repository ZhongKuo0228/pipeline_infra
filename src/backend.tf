terraform {
  backend "s3" {
    bucket         = "task-6-1-terraform"
    key            = "terraform/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "task-6-1-terraform"
    encrypt        = true
  }
}
