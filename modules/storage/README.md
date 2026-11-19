# Module `storage`

Bucket S3 privé du projet (ressources, journaux, sauvegardes).

| Mesure | Mise en œuvre |
|---|---|
| Versioning | Activé |
| Chiffrement | SSE-S3 (AES256) |
| Accès public | Bloqué (4 options) + ACL désactivées (`BucketOwnerEnforced`) |
| Transport | Refus de toute requête non TLS (`aws:SecureTransport = false`) |
| Cycle de vie | `logs/` supprimés après `log_retention_days` jours ; anciennes versions après `noncurrent_version_days` jours ; uploads incomplets après 7 jours |

**Contrainte AWS Academy Learner Lab :** une SCP interdit `s3:GetBucketObjectLockConfiguration`, que la ressource `aws_s3_bucket` lit systématiquement. Le bucket est donc déclaré dans une pile CloudFormation pilotée par Terraform (`aws_cloudformation_stack`). L'infrastructure reste entièrement en code, et `terraform destroy` supprime la pile et le bucket.

Nom du bucket : `<name_prefix>-assets-<account_id>` (unique globalement).

## Exemple

```hcl
module "storage" {
  source      = "../../modules/storage"
  name_prefix = "cloud5-dev"
}
```

## Entrées

| Nom | Type | Défaut | Description |
|---|---|---|---|
| name_prefix | string | - | Préfixe `<projet>-<env>` |
| log_retention_days | number | 30 | Rétention des objets `logs/` |
| noncurrent_version_days | number | 30 | Rétention des anciennes versions |
| tags | map(string) | {} | Tags additionnels |

## Sorties

`bucket_name`, `bucket_arn`.
