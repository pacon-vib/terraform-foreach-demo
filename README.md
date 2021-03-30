# Terraform for_each toset() demo

When you try to do something entirely reasonable like create a "diagnostic setting" resource for each resource in a list, using a simple `for_each` loop on those resources' IDs, you get this error:

```
The given "for_each" argument value is unsuitable: the "for_each" argument
must be a map, or set of strings, and you have provided a value of type tuple.
```

Or this one:
```
The given "for_each" argument value is unsuitable: the "for_each" argument
must be a map, or set of strings, and you have provided a value of type tuple.
```

One way to "fix" this is to use `count` instead of `for_each`. However, this is bad because it makes the resources unstable at the next `apply` when the upstream resource list is changed.

This repo provides a simple demonstration of this problem (using `null_resource` to isolate the issue without needing to deploy real infra) and how to solve it using `zipmap()`.

Full transcript:

```
$ (cd 01-this-does-not-work/; terraform apply)

Error: Invalid for_each argument

  on main.tf line 8, in resource "null_resource" "bbb":
   8:   for_each = random_string.aaa.*.result

The given "for_each" argument value is unsuitable: the "for_each" argument
must be a map, or set of strings, and you have provided a value of type tuple.

$ (cd 02-this-does-not-work-either/; terraform apply)

Error: Invalid for_each argument

  on main.tf line 8, in resource "null_resource" "bbb":
   8:   for_each = random_string.aaa.*.result

The given "for_each" argument value is unsuitable: the "for_each" argument
must be a map, or set of strings, and you have provided a value of type tuple.

$ ec -n 02-this-does-not-work-either/main.tf
$ (cd 02-this-does-not-work-either/; terraform apply)

Error: Invalid for_each argument

  on main.tf line 8, in resource "null_resource" "bbb":
   8:   for_each = toset(random_string.aaa.*.result)

The "for_each" value depends on resource attributes that cannot be determined
until apply, so Terraform cannot predict how many instances will be created.
To work around this, use the -target argument to first apply only the
resources that the for_each depends on.

$ (cd 03-this-works/; terraform apply)
random_string.aaa[1]: Refreshing state... [id=HSKthBHn]
random_string.aaa[2]: Refreshing state... [id=EyHb3whu]
random_string.aaa[0]: Refreshing state... [id=glRFVLJk]
null_resource.bbb["1"]: Refreshing state... [id=8137298028519669359]
null_resource.bbb["0"]: Refreshing state... [id=2775773205000122659]
null_resource.bbb["2"]: Refreshing state... [id=8064430255934717552]

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```
