locals {
  db_host = split(":", var.rds_endpoint)[0] # By default the var returns the host:port, while port isn't needed 
}

resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }

  timeouts {
    delete = "10m"
  }
}

resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }

    timeouts {
    delete = "10m"
  }
}

resource "kubernetes_namespace" "prod" {
  metadata {
    name = "prod"
  }

    timeouts {
    delete = "10m"
  }
}

resource "kubernetes_secret" "db_endpoint_dev" {
  metadata {
    name      = "postgres-endpoint"
    namespace = "dev"
  }

  data = {
    db_host     = local.db_host
  }
}

resource "kubernetes_secret" "db_endpoint_staging" {
  metadata {
    name      = "postgres-endpoint"
    namespace = "staging"
  }

  data = {
    db_host     = local.db_host
  }
}

resource "kubernetes_secret" "db_endpoint_prod" {
  metadata {
    name      = "postgres-endpoint"
    namespace = "prod"
  }

  data = {
    db_host     = local.db_host
  }
}