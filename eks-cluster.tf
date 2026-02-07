data "aws_eks_cluster_auth" "myapp_cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.myapp_cluster.token
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id                   = module.myapp-vpc.vpc_id
  subnet_ids               = module.myapp-vpc.private_subnets
  control_plane_subnet_ids = module.myapp-vpc.private_subnets

  # Enable public endpoint
  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    worker_group_1 = {
      ami_type       = var.ami_type
      instance_types = var.instance_types
      
      min_size     = 2
      max_size     = 4
      desired_size = 2
    }
  }

  tags = {
    environment = "development"
    application = "myapp"
  }
}