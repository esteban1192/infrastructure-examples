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

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"

        scope_down_statement {
          byte_match_statement {
            field_to_match {
              body {}
            }
            positional_constraint = "CONTAINS"
            search_string         = "SELECT"

            text_transformation {
              priority = 0
              type     = "URL_DECODE"
            }

            text_transformation {
              priority = 1
              type     = "LOWERCASE"
            }
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
