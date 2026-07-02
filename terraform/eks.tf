module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      # Using higher max_size since we are on t3.micro to allow enough pod slots
      min_size       = 1
      max_size       = 20
      desired_size   = var.desired_nodes
    }
  }

  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
    eks-pod-identity-agent = {}
  }

  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = true

  tags = { Project = "FifaApp" }
}
