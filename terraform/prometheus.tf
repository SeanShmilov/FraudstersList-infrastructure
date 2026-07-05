resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "58.1.3"
  timeout          = 600

  depends_on = [module.eks, helm_release.alb_controller]

  values = [
    <<-EOT
    # ---------------------------------------------------------
    # EXTREME FREE TIER OPTIMIZATIONS (t3.micro = 1GB RAM)
    # ---------------------------------------------------------
    
    # 1. Disable High Availability and extra features
    defaultRules:
      create: true # Required for Grafana dashboards (generates the CPU/Memory recording rules)
    alertmanager:
      enabled: false # Disable Alertmanager to save memory (not needed for basic metrics)
    kubeStateMetrics:
      enabled: true # Required for Kubernetes Dashboards (Pods, Deployments, Resources)
    nodeExporter:
      enabled: true # Required for Kubernetes Dashboards (CPU, Memory, Disk)

    # 2. Hard-cap Prometheus Server Database Memory
    prometheus:
      prometheusSpec:
        retention: 12h # Only keep 12 hours of metrics instead of 15 days
        resources:
          requests:
            memory: 256Mi
            cpu: 50m
          limits:
            memory: 512Mi # Prevent OOMKilled during startup WAL loading
            
    # 3. Hard-cap Grafana Memory and Setup Subpath Routing
    grafana:
      resources:
        requests:
          memory: 64Mi
          cpu: 50m
        limits:
          memory: 128Mi
      
      grafana.ini:
        server:
          # Allow Grafana to be served from the /grafana subpath on the Load Balancer
          root_url: "%(protocol)s://%(domain)s/grafana"
          serve_from_sub_path: true
    EOT
  ]
}

resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "grafana-ingress"
    namespace = "monitoring"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      
      # Grouping it with ArgoCD and FifaApp so they all share ONE Load Balancer!
      "alb.ingress.kubernetes.io/group.name"  = "fifaapp"
      "alb.ingress.kubernetes.io/group.order" = "15"
      
      # Fix the 503 error by telling AWS to check Grafana's specific health endpoint!
      "alb.ingress.kubernetes.io/healthcheck-path" = "/grafana/api/health"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path      = "/grafana"
          path_type = "Prefix"
          backend {
            service {
              name = "prometheus-grafana"
              port { number = 80 }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.prometheus]
}
