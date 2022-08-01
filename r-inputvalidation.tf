locals {
  templateInvocation = [
    for k, subnet in var.subnets : k if subnet.template != null && subnet.template != ""
  ]
  templateInvocationCount = length(local.templateInvocation)
}
module input_validation {
    source   = "./input_validation"
    count    = local.templateInvocationCount > 0 && (var.template_folder == null || var.template_folder == "") ? 1 : 0
    wrong_input = local.templateInvocationCount
}