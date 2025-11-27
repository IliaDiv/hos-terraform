data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "oidc" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

locals {
  # Strip the https:// prefix
  oidc_url = replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
}

# SECRETS SCI
resource "helm_release" "secrets_store_csi_driver" {
  name             = "secrets-store-csi-driver"
  repository       = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart            = "secrets-store-csi-driver"
  version          = "1.5.4"
  namespace        = "kube-system"
  create_namespace = false

  set = [
    {
      name  = "syncSecret.enabled"
      value = "false"
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    }
  ]
}


# AWS SCI
resource "helm_release" "csi_driver_aws_provider" {
  name             = "secrets-store-csi-driver-provider-aws"
  repository       = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart            = "secrets-store-csi-driver-provider-aws"
  version          = "2.1.1"
  namespace        = "kube-system"
  create_namespace = false

  set = [
    {
      name  = "secrets-store-csi-driver.install"
      value = "false"
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    }
  ]
}

resource "time_sleep" "wait_for_crds" {
  depends_on = [
    helm_release.secrets_store_csi_driver,
    helm_release.csi_driver_aws_provider
  ]
  create_duration = "250s"
}

##############################################################################################
# N8N
##############################################################################################

# ROLE
resource "aws_iam_role" "n8n_secret_reader" {
  name = "n8n-secret-reader"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:dev:n8n-service-token-reader"
          }
        }
      }
    ]
  })
}


# POLICY
resource "aws_iam_policy" "hos_n8n_token_reader" {
  name        = "n8n-service-token-reader"
  description = "Allow pods to read a specific secret from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        "Resource" : [
          "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:${var.openai_secrets_name}*",
          "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:${var.db_secrets_name}*"
        ]
      }
    ]
  })
}


# ATTACHMENT
resource "aws_iam_role_policy_attachment" "esrrs" {
  policy_arn = aws_iam_policy.hos_n8n_token_reader.arn
  role       = aws_iam_role.n8n_secret_reader.name
}

# SecretProviderClass
resource "null_resource" "secret_provider_class_n8n" {
  
  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply -f - <<EOF
      apiVersion: secrets-store.csi.x-k8s.io/v1
      kind: SecretProviderClass
      metadata:
        name: n8n-service-token
        namespace: dev
      spec:
        provider: aws
        parameters:
          objects: |
            - objectName: "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:${var.openai_secrets_name}-ZJOxwj"
              objectType: "secretsmanager"
              objectAlias: "openai"
            - objectName: "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:${var.db_secrets_name}-zhA0ZW"
              objectType: "secretsmanager"
              objectAlias: "rds"
      EOF
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete secretproviderclass n8n-service-token -n dev --ignore-not-found=true"
  }

  triggers = {
    secret_arn_n8n = "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:${var.openai_secrets_name}"
    secret_arn_db  = "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:${var.db_secrets_name}"
    namespace      = "dev"
  }

  depends_on = [time_sleep.wait_for_crds, helm_release.csi_driver]
}

# ServiceAccount
resource "kubernetes_service_account" "serviceaccount_token_n8n" {
  metadata {
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.n8n_secret_reader.arn
    }
    name      = "n8n-service-token-reader"
    namespace = "dev"
  }
}





##############################################################################################
# Flask
##############################################################################################

# ROLE
resource "aws_iam_role" "flask_secret_reader" {
  name = "flask-secret-reader"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:dev:flask-service-token-reader"
          }
        }
      }
    ]
  })
}


# POLICY
resource "aws_iam_policy" "hos_flask_token_reader" {
  name        = "flask-service-token-reader"
  description = "Allow pods to read a specific secret from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        "Resource" : "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:${var.db_secrets_name}*"
      }
    ]
  })
}


# ATTACHMENT
resource "aws_iam_role_policy_attachment" "esrrstwo" {
  policy_arn = aws_iam_policy.hos_flask_token_reader.arn
  role       = aws_iam_role.flask_secret_reader.name
}

# SecretProviderClass
resource "null_resource" "secret_provider_class_flask" {
  provisioner "local-exec" {
    command = <<-EOT
      kubectl apply -f - <<EOF
      apiVersion: secrets-store.csi.x-k8s.io/v1
      kind: SecretProviderClass
      metadata:
        name: flask-service-token
        namespace: dev
      spec:
        provider: aws
        parameters:
          objects: |
            - objectName: "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:${var.db_secrets_name}-zhA0ZW"
              objectType: "secretsmanager"
              objectAlias: "rds"
      EOF
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete secretproviderclass flask-service-token -n dev --ignore-not-found=true"
  }

  triggers = {
    secret_arn_db = "arn:aws:secretsmanager:${var.region}:${var.aws_account_id}:secret:${var.db_secrets_name}"
    namespace     = "dev"
  }

  depends_on = [time_sleep.wait_for_crds]
}

# ServiceAccount
resource "kubernetes_service_account" "serviceaccount_token_flask" {
  metadata {
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.flask_secret_reader.arn
    }
    name      = "flask-service-token-reader"
    namespace = "dev"
  }
}