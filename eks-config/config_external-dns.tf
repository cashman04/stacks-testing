resource "aws_iam_role" "external_dns" {
  count = var.enable_external_dns ? 1 : 0
  name  = "${var.cluster_name}-external-dns-iam-role"

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
            "oidc.eks.us-east-1.amazonaws.com/id/94428A06DB3AC7323BA129635CB4F613:aud" : "sts.amazonaws.com",
            "oidc.eks.us-east-1.amazonaws.com/id/94428A06DB3AC7323BA129635CB4F613:sub" : "system:serviceaccount:external-dns:external-dns-sa"
          }
        }
      }
    ]
  })
}


resource "aws_iam_policy" "external_dns_policy" {
  count       = var.enable_external_dns ? 1 : 0
  name        = "${var.cluster_name}-external-dns-iam-policy"
  description = "Policy for External DNS"


  policy = jsonencode({
    "Statement" : concat(
      [for zone_id in var.r53_zone_ids : {
        "Action" : "route53:ChangeResourceRecordSets",
        "Effect" : "Allow",
        "Resource" : "arn:aws:route53:::hostedzone/${zone_id}"
      }],
      [for zone_id in var.r53_zone_ids : {
        "Action" : "route53:ListTagsForResource",
        "Effect" : "Allow",
        "Resource" : "arn:aws:route53:::hostedzone/${zone_id}"
      }],
      [{
        "Action" : [
          "route53:ListResourceRecordSets",
          "route53:ListHostedZones"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }]
    ),
    "Version" : "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "external_dns_attach" {
  count      = var.enable_external_dns ? 1 : 0
  policy_arn = aws_iam_policy.external_dns_policy[0].arn
  role       = aws_iam_role.external_dns[0].name
}


resource "helm_release" "external_dns" {
  count      = var.enable_external_dns ? 1 : 0
  name       = "external-dns"
  namespace  = "external-dns"
  chart      = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  version    = var.external_dns_helm_chart_version

  create_namespace = true

  set {
    name  = "extraArgs[0]"
    value = "--source=ingress"
  }

  set {
    name  = "extraArgs[1]"
    value = "--ingress-class=alb"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns[0].arn
  }

  set {
    name  = "serviceAccount.name"
    value = "external-dns-sa"
  }
}

