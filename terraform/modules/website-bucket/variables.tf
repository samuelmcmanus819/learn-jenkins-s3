variable "site_name" {
  description = "The name of the website"
  type        = string
}

variable "log_bucket_id" {
  description = "ID of the bucket to send logs to"
  type        = string
}

variable "index_file_name" {
  description = "The name of the index file"
  type        = string
}

variable "error_file_name" {
  description = "The name of the error file"
  type        = string
}

variable "path_to_site_files" {
  description = "The path to the files to upload to the bucket"
  type        = string
}

variable "site_files_pattern" {
  description = "The pattern to match for site files in the designated path"
  type        = string
}