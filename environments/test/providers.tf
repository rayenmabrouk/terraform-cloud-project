provider "aws" {
  region = var.aws_region

  # Mandatory tags (spec section 12) applied to every resource automatically
  default_tags {
    tags = local.common_tags
  }
}
