locals {
  db_host = split(":", var.rds_endpoint)[0] # By default the var returns the host:port, while port isn't needed 
}

resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }
  
  lifecycle {
    prevent_destroy = true
  }
  depends_on = [helm_release.argocd, helm_release.aws_lbc]
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }

  lifecycle {
    prevent_destroy = true
  }
  depends_on = [helm_release.argocd, helm_release.aws_lbc]
}

resource "kubernetes_namespace" "prod" {
  metadata {
    name = "prod"
  }

  lifecycle {
    prevent_destroy = true
  }
  depends_on = [helm_release.argocd, helm_release.aws_lbc]
}

resource "kubernetes_secret" "db_endpoint_dev" {
  metadata {
    name      = "postgres-endpoint"
    namespace = "dev"
  }

  data = {
    db_host = local.db_host
  }

  depends_on = [kubernetes_namespace.dev]
}

resource "kubernetes_secret" "db_endpoint_staging" {
  metadata {
    name      = "postgres-endpoint"
    namespace = "staging"
  }

  data = {
    db_host = local.db_host
  }

  depends_on = [kubernetes_namespace.staging]
}

resource "kubernetes_secret" "db_endpoint_prod" {
  metadata {
    name      = "postgres-endpoint"
    namespace = "prod"
  }

  data = {
    db_host = local.db_host
  }

  depends_on = [kubernetes_namespace.prod]
}