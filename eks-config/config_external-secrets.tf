resource "aws_iam_role" "external_secrets" {
  count = var.enable_external_secrets ? 1 : 0
  name  = "${var.cluster_name}-external-secrets-iam-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${var.oidc_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.us-east-1.amazonaws.com/id/DA2A41AA3A1248194D818826BEC2B7B9:sub" : "system:serviceaccount:external-secrets:external-secrets-sa",
            "oidc.eks.us-east-1.amazonaws.com/id/DA2A41AA3A1248194D818826BEC2B7B9:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}


resource "aws_iam_policy" "external_secrets_policy" {
  count       = var.enable_external_secrets ? 1 : 0
  name        = "${var.cluster_name}-external-secrets-iam-policy"
  description = "Policy for External Secrets to access AWS Secrets Manager and SSM Parameter Store"

  policy = jsonencode({
    "Statement" : [
      {
        "Action" : "ssm:DescribeParameters",
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:ssm:*:*:parameter/*"
      },
      {
        "Action" : "secretsmanager:ListSecrets",
        "Effect" : "Allow",
        "Resource" : "*"
      },
      {
        "Action" : [
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:GetSecretValue",
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:DescribeSecret"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:secretsmanager:*:*:secret:*"
      },
      {
        "Action" : "kms:Decrypt",
        "Effect" : "Allow",
        "Resource" : "arn:aws:kms:*:*:key/*"
      }
    ],
    "Version" : "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "external_secrets_attach" {
  count      = var.enable_external_secrets ? 1 : 0
  policy_arn = aws_iam_policy.external_secrets_policy[0].arn
  role       = aws_iam_role.external_secrets[0].name
}


resource "helm_release" "external_secrets" {
  count      = var.enable_external_secrets ? 1 : 0
  name       = "external-secrets"
  namespace  = "external-secrets"
  chart      = "external-secrets"
  repository = "https://charts.external-secrets.io"
  version    = "0.9.16"

  create_namespace = true

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-secrets-sa"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_secrets[0].arn
  }
}


resource "kubernetes_manifest" "cluster_secret_store" {
  count = var.enable_external_secrets ? 1 : 0
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-secret-manager"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = data.aws_region.current.name
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = "external-secrets-sa"
                namespace = "external-secrets"
              }
            }
          }
        }
      }
    }
  }
}
