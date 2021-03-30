resource "random_string" "aaa" {
  count = 3
  length = 8
  special = false
}

resource "null_resource" "bbb" {
  for_each = random_string.aaa.*.result
  triggers = {
    foo = each.key
  }
}
