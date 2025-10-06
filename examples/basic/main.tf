module "sqs" {
  source       = "../../modules/sqs"
  queue_names  = ["priority-10", "priority-100"]
  create_roles = true
}
