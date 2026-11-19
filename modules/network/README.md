# Module `network`

VPC multi-AZ avec trois niveaux de sous-réseaux, Internet Gateway, sortie contrôlée (NAT) et endpoint S3 Gateway.

| Niveau | Route 0.0.0.0/0 | Usage |
|---|---|---|
| public | Internet Gateway | ALB, NAT Gateway |
| app | NAT Gateway | Instances de l'Auto Scaling Group |
| db | aucune | RDS, isolé d'Internet |

`nat_mode` : `none` (aucune NAT), `single` (une NAT partagée, dev/test), `per_az` (une NAT par AZ, prod).

## Exemple

```hcl
module "network" {
  source              = "../../modules/network"
  name_prefix         = "cloud5-dev"
  vpc_cidr            = "10.20.0.0/16"
  azs                 = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs = ["10.20.1.0/24", "10.20.2.0/24"]
  app_subnet_cidrs    = ["10.20.11.0/24", "10.20.12.0/24"]
  db_subnet_cidrs     = ["10.20.21.0/24", "10.20.22.0/24"]
  nat_mode            = "single"
}
```

## Entrées

| Nom | Type | Défaut | Description |
|---|---|---|---|
| name_prefix | string | - | Préfixe `<projet>-<env>` |
| vpc_cidr | string | - | CIDR du VPC |
| azs | list(string) | - | Au moins 2 AZ |
| public_subnet_cidrs | list(string) | - | Un CIDR par AZ |
| app_subnet_cidrs | list(string) | - | Un CIDR par AZ |
| db_subnet_cidrs | list(string) | - | Un CIDR par AZ |
| nat_mode | string | single | none, single ou per_az |
| tags | map(string) | {} | Tags additionnels |

## Sorties

`vpc_id`, `public_subnet_ids`, `app_subnet_ids`, `db_subnet_ids`.
