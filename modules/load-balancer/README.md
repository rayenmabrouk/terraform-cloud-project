# Module `load-balancer`

Application Load Balancer public, Target Group HTTP avec health check et listeners.

- Listener 80 : transfère vers le Target Group, ou redirige (301) vers HTTPS si `certificate_arn` est fourni.
- Listener 443 (optionnel) : politique `ELBSecurityPolicy-TLS13-1-2-2021-06` (TLS 1.2/1.3 uniquement).
- `drop_invalid_header_fields = true` : protection contre le HTTP request smuggling.
- Health check : `GET /` attend un code 200, toutes les 15 s. 2 succès donnent l'état Healthy, 2 échecs l'état Unhealthy : une instance défaillante sort de la rotation en ~30 s.
- `deregistration_delay = 30` : retrait rapide d'une instance qui quitte le groupe.

## Exemple

```hcl
module "load_balancer" {
  source            = "../../modules/load-balancer"
  name_prefix       = "cloud5-dev"
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}
```

## Entrées

| Nom | Type | Défaut | Description |
|---|---|---|---|
| name_prefix | string | - | Préfixe `<projet>-<env>` |
| vpc_id | string | - | VPC |
| public_subnet_ids | list(string) | - | Sous-réseaux publics (≥ 2 AZ) |
| alb_sg_id | string | - | SG de l'ALB |
| target_port | number | 80 | Port des cibles |
| health_check_path | string | / | Chemin du health check |
| certificate_arn | string | null | Active HTTPS |
| tags | map(string) | {} | Tags additionnels |

## Sorties

`alb_dns_name`, `alb_url`, `target_group_arn`.
