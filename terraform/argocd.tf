resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.11"
  timeout          = 600
  wait             = false
  atomic           = false

  depends_on = [module.eks, helm_release.alb_controller]

  values = [
    <<-EOT
    configs:
      params:
        server.insecure: "true"
        server.rootpath: "/argocd"
        server.basehref: "/argocd"
    EOT
  ]
}

resource "kubernetes_ingress_v1" "argocd" {
  metadata {
    name      = "argocd-ingress"
    namespace = "argocd"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/group.name"  = "fraudsterslist"
      "alb.ingress.kubernetes.io/group.order" = "10"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path      = "/argocd"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port { number = 80 }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.argocd, helm_release.alb_controller]
}
