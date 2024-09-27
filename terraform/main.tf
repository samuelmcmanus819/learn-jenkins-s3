module "logging_bucket" {
  source              = "./modules/logging-bucket"
  logging_bucket_name = "learn-jenkins-site-logging-bucket"
}


module "learn_jenkins_site" {
  source             = "./modules/website-bucket"
  site_name          = "learn-jenkins-site"
  log_bucket_id      = module.logging_bucket.bucket_id
  index_file_name    = "index.html"
  error_file_name    = "error.html"
  path_to_site_files = "${path.module}/../../build/"
  site_files_pattern = "**/*"
}

# Output the S3 bucket website URL
output "website_url" {
  value = module.learn_jenkins_site.website_url
}
