module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "fifaapp-cluster"
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true
  
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    general = {
      instance_types = ["t3.micro"]
      min_size     = 1
      max_size     = 3
      desired_size = 2
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment = "production"
    Project     = "FifaApp"
  }
}
