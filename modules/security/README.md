# Module `security`

Security Groups chaînés : Internet -> ALB -> App -> DB.

| SG | Entrant | Sortant |
|---|---|---|
| sg-alb | 80 (et 443 si `enable_https`) depuis 0.0.0.0/0 | `app_port` vers sg-app uniquement |
| sg-app | `app_port` depuis sg-alb uniquement | 443 (paquets via NAT), `db_port` vers sg-db |
| sg-db | `db_port` depuis sg-app uniquement | aucun |

- Les règles référencent des Security Groups et non des IP : elles restent valides quand l'Auto Scaling remplace les instances.
- Aucune règle SSH (port 22) : l'administration passe par SSM Session Manager (authentification IAM, sessions journalisées, aucune clé).
- Rôles IAM : l'environnement AWS Academy Learner Lab interdit la création de rôles IAM. Les instances utilisent le profil existant `LabInstanceProfile` (contrainte documentée).

## Exemple

```hcl
module "security" {
  source      = "../../modules/security"
  name_prefix = "cloud5-dev"
  vpc_id      = module.network.vpc_id
}
```

## Entrées

| Nom | Type | Défaut | Description |
|---|---|---|---|
| name_prefix | string | - | Préfixe `<projet>-<env>` |
| vpc_id | string | - | VPC cible |
| app_port | number | 80 | Port applicatif |
| db_port | number | 5432 | Port PostgreSQL |
| enable_https | bool | false | Ouvre 443 sur l'ALB |
| tags | map(string) | {} | Tags additionnels |

## Sorties

`alb_sg_id`, `app_sg_id`, `db_sg_id`.
