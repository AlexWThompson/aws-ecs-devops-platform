terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket       = "terraform-state-bucket-527557824388-us-east-2-an"
    key          = "environments/prod/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
