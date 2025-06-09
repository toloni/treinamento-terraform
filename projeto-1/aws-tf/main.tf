# Root main.tf

module "infra" {
  source = "./modules/infra"

  cidr_block = "10.0.0.0/16"
}
