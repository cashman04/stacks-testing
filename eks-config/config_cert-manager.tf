

resource "aws_iam_role" "cert_manager" {
  count = var.enable_cert_manager ? 1 : 0
  name  = "${var.cluster_name}-cert-manager-iam-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ExplicitSelfRoleAssumption",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : "sts:AssumeRole",
        "Condition" : {
          "ArnLike" : {
            "aws:PrincipalArn" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/cert-manager-*"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${var.oidc_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "oidc.eks.us-east-1.amazonaws.com/id/94428A06DB3AC7323BA129635CB4F613:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-1.amazonaws.com/id/94428A06DB3AC7323BA129635CB4F613:sub" : "system:serviceaccount:cert-manager:cert-manager"
          }
        }
      }
    ]
  })
}


resource "aws_iam_policy" "cert_manager_policy" {
  count       = var.enable_cert_manager ? 1 : 0
  name        = "${var.cluster_name}-cert-manager-iam-policy"
  description = "Policy for Cert Manager"

  policy = jsonencode({
    "Statement" : [
      {
        "Action" : "route53:GetChange",
        "Effect" : "Allow",
        "Resource" : "arn:aws:route53:::change/*"
      },
      {
        "Action" : [
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:route53:::hostedzone/*"
      },
      {
        "Action" : "route53:ListHostedZonesByName",
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ],
    "Version" : "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "cert_manager_attach" {
  count      = var.enable_cert_manager ? 1 : 0
  policy_arn = aws_iam_policy.cert_manager_policy[0].arn
  role       = aws_iam_role.cert_manager[0].name
}


resource "helm_release" "cert_manager" {
  count      = var.enable_cert_manager ? 1 : 0
  name       = "cert-manager"
  namespace  = "cert-manager"
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = var.cert_manager_helm_chart_version

  create_namespace = true

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "cert-manager"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cert_manager[0].arn
  }

  set {
    name  = "installCRDs"
    value = "true"
  }
}

