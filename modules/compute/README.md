# Module `compute`

Launch Template, Auto Scaling Group multi-AZ et politique de scaling CPU.

- **AMI** : dernière Amazon Linux 2023, résolue via le paramètre SSM public (aucun ID codé en dur).
- **user_data** (`templates/user_data.sh.tftpl`) : installe nginx et publie une page qui affiche le nom d'hôte, l'ID d'instance, l'AZ, l'IP privée et l'état de joignabilité de la base. Rafraîchir la page montre la répartition entre instances.
- **Durcissement** : IMDSv2 obligatoire, volume racine gp3 chiffré, aucune clé SSH.
- **Profil IAM** : `LabInstanceProfile` (le Learner Lab interdit la création de rôles).
- **ASG** : `health_check_type = "ELB"`. Une instance déclarée *unhealthy* par l'ALB est remplacée automatiquement. Une nouvelle version du Launch Template déclenche un *instance refresh* progressif (50 % minimum en service).
- **Scaling** : target tracking sur `ASGAverageCPUUtilization` (`cpu_target`, 50 % par défaut).
- `desired_capacity` est ignoré après création : la capacité appartient ensuite à la politique de scaling et aux tests.

## Exemple

```hcl
module "compute" {
  source            = "../../modules/compute"
  name_prefix       = "cloud5-dev"
  project_name      = "cloud5"
  environment       = "dev"
  app_subnet_ids    = module.network.app_subnet_ids
  app_sg_id         = module.security.app_sg_id
  target_group_arns = [module.load_balancer.target_group_arn]
  db_host           = module.database.db_address
}
```

## Entrées

| Nom | Type | Défaut | Description |
|---|---|---|---|
| name_prefix | string | - | Préfixe `<projet>-<env>` |
| project_name / environment | string | - | Affichés sur la page |
| app_subnet_ids | list(string) | - | Sous-réseaux privés app (≥ 2) |
| app_sg_id | string | - | SG applicatif |
| instance_profile_name | string | LabInstanceProfile | Profil IAM |
| target_group_arns | list(string) | - | Target Groups de l'ALB |
| instance_type | string | t3.micro | Type d'instance |
| min_size / max_size / desired_capacity | number | 2 / 4 / 2 | Capacité |
| cpu_target | number | 50 | Cible CPU (%) |
| db_host / db_port | string / number | "" / 5432 | Test de connectivité affiché |
| tags | map(string) | {} | Tags des instances et volumes |

## Sorties

`asg_name`, `launch_template_id`, `ami_id`.
