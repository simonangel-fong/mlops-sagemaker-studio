# locals.tf

locals {

  # ##############################
  # Metadata
  # ##############################
  prefix_name = "${var.project}-${var.env}"


  mlflow_prefix = "mlflow-app/"

  # Phase 9. Bob writes here and nowhere else; alice keeps the root
  # prefixes above, which is what he is denied. Not in s3_prefixes: the
  # bucket does not need an empty marker for a prefix bob creates on his
  # first put.
  bob_prefix = "users/bob/"

  default_tags = merge(
    {
      Project   = var.project
      Env       = var.env
      ManagedBy = "terraform"
    },
    var.tags
  )
}


