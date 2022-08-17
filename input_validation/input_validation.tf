variable "wrong_input" {
  type = number
  validation {
    condition     = var.wrong_input <= 0
    error_message = "The 'subnet.template' attribute is used but the variable 'template_folder' is not set."
  }
}