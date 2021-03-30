resource "random_string" "aaa" {
  count = 3
  length = 8
  special = false
}

locals {
  cool_ids = random_string.aaa.*.result
  cool_ids_zipmap = zipmap(range(length(local.cool_ids)), local.cool_ids)
}

resource "null_resource" "bbb" {
  for_each = local.cool_ids_zipmap
  triggers = {
    foo = each.key
  }
}
