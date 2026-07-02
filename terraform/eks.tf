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
      ami_type       = "AL2_x86_64"
      instance_types = [var.node_instance_type]
      # Using higher max_size since we are on t3.micro to allow enough pod slots
      min_size       = 1
      max_size       = 16
      desired_size   = var.desired_nodes

      # Force kubelet to allow 11 pods instead of the default 4 on t3.micro
      bootstrap_extra_args = "--use-max-pods false --kubelet-extra-args '--max-pods=11'"
    }
  }

  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni = {
      # Enable Prefix Delegation to give each ENI more IP addresses
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    eks-pod-identity-agent = {}
  }

  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = true

  tags = { Project = "FifaApp" }
}
