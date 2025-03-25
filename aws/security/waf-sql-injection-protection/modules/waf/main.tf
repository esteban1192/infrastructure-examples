resource "aws_wafv2_web_acl" "api_waf" {
  name        = "api-waf"
  scope       = "REGIONAL"
  description = "WAF to protect API Gateway against SQL injection"

  default_action {
    allow {}
  }

  rule {
    name     = "SQLInjectionProtection"
    priority = 1

    action {
      block {}
    }

    statement {
      sqli_match_statement {
        text_transformation {
          priority = 0
          type     = "NONE"
        }
        field_to_match {
          json_body {
            match_pattern {
              all {}
            }
            match_scope = "VALUE"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLInjectionProtection"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "api-waf"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "api_waf_association" {
  resource_arn = var.api_stage_arn
  web_acl_arn  = aws_wafv2_web_acl.api_waf.arn
}
