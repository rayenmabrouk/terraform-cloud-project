# prod: one NAT per AZ, Multi-AZ database, deletion protection
project_name = "cloud5"
environment  = "prod"
owner        = "rayen-mabrouk"

vpc_cidr = "10.40.0.0/16"
nat_mode = "per_az"

instance_type    = "t3.small"
min_size         = 2
max_size         = 6
desired_capacity = 2

db_instance_class      = "db.t3.small"
db_multi_az            = true
db_deletion_protection = true
