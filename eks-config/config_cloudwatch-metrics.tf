resource "aws_iam_role" "cloudwatch_metrics" {
  count = var.enable_aws_cloudwatch_metrics ? 1 : 0
  name  = "${var.cluster_name}-cloudwatch-metrics-iam-role"

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
            "oidc.eks.us-east-1.amazonaws.com/id/94428A06DB3AC7323BA129635CB4F613:sub" : "system:serviceaccount:amazon-cloudwatch:aws-cloudwatch-metrics"
          }
        }
      }
    ]
  })
}


data "aws_iam_policy" "cloudwatch_agent" {
  name = "CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_metrics_attach" {
  count      = var.enable_aws_cloudwatch_metrics ? 1 : 0
  policy_arn = data.aws_iam_policy.cloudwatch_agent.arn
  role       = aws_iam_role.cloudwatch_metrics[0].name
}


resource "helm_release" "cloudwatch_metrics" {
  count      = var.enable_aws_cloudwatch_metrics ? 1 : 0
  name       = "aws-cloudwatch-metrics"
  namespace  = "amazon-cloudwatch"
  chart      = "aws-cloudwatch-metrics"
  repository = "https://aws.github.io/eks-charts"
  version    = var.aws_cloudwatch_metrics_helm_chart_version

  create_namespace = true

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-cloudwatch-metrics"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cloudwatch_metrics[0].arn
  }
}

