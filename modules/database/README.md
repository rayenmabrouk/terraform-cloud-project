# Module `database`

Instance RDS PostgreSQL privée, son groupe de sous-réseaux et son groupe de paramètres.

Défense en profondeur :

| Couche | Mesure |
|---|---|
| Réseau | Sous-réseaux DB sans aucune route vers Internet, `publicly_accessible = false` |
| Pare-feu | `sg-db` n'accepte que `sg-app` sur le port 5432 |
| Transport | `rds.force_ssl = 1` : connexions non chiffrées refusées |
| Stockage | gp3 chiffré au repos (KMS) |
| Secret | `manage_master_user_password = true` : RDS génère le mot de passe et le stocke dans Secrets Manager. Il n'existe ni dans Git, ni dans les tfvars, ni dans l'état Terraform. |
| Audit | `log_connections = 1` |

Dev/test : pas de protection contre la suppression, destruction rapide sans snapshot final.
Prod : `deletion_protection = true`, ce qui active automatiquement le snapshot final.

Récupérer les identifiants (poste admin autorisé uniquement) :

```bash
aws secretsmanager get-secret-value --secret-id <master_user_secret_arn> --query SecretString --output text
```

## Exemple

```hcl
module "database" {
  source        = "../../modules/database"
  name_prefix   = "cloud5-dev"
  db_subnet_ids = module.network.db_subnet_ids
  db_sg_id      = module.security.db_sg_id
}
```

## Entrées

| Nom | Type | Défaut | Description |
|---|---|---|---|
| name_prefix | string | - | Préfixe `<projet>-<env>` |
| db_subnet_ids | list(string) | - | Sous-réseaux DB (≥ 2 AZ) |
| db_sg_id | string | - | SG de la base |
| engine_version | string | 16 | Version majeure PostgreSQL |
| instance_class | string | db.t3.micro | Classe RDS |
| allocated_storage | number | 20 | Stockage (GiB) |
| db_name | string | appdb | Base initiale |
| master_username | string | appadmin | Utilisateur maître |
| multi_az | bool | false | Standby synchrone |
| backup_retention_period | number | 1 | Jours de sauvegarde |
| deletion_protection | bool | false | Protection contre la suppression |
| tags | map(string) | {} | Tags additionnels |

## Sorties

`db_address`, `db_port`, `db_identifier`, `master_user_secret_arn`.
