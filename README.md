# Jenkins Pipeline for Website Deployment to S3 with Terraform

This repository contains a Jenkins pipeline that builds a website and deploys it to an Amazon S3 bucket using Terraform. The deployment pipeline also includes security features such as S3 bucket scanning with TFSec and logging with a KMS-encrypted logging bucket. Additionally, a devcontainer is provided for developers who wish to manually run the Terraform configurations.

## Features

- **Jenkins Pipeline**: Automates the build and deployment of the website to an S3 bucket.
- **Terraform for Infrastructure**: Uses Terraform to provision the S3 bucket and associated resources.
- **Logging Bucket**: Creates an S3 logging bucket encrypted with AWS KMS for secure logging.
- **TFSec Integration**: Scans the S3 bucket infrastructure with TFSec for security vulnerabilities.
- **Devcontainer Support**: Provides a development container for developers to manually run the Terraform configuration within a consistent environment.

## Prerequisites

To use this repository, ensure the following dependencies are installed:

- [Jenkins](https://www.jenkins.io/) with pipeline support.
- [Terraform](https://www.terraform.io/) version 1.0+.
- [Docker](https://www.docker.com/) for devcontainer support.
- AWS credentials with appropriate permissions to create S3 buckets and KMS encryption.

## Usage

### Jenkins Pipeline

1. Clone this repository to your Jenkins server.
2. Configure the Jenkins pipeline to use the provided `Jenkinsfile`.
3. Set up your AWS credentials in Jenkins (using environment variables or credentials plugins).
4. The pipeline will:
   - Build the website.
   - Deploy it to the S3 bucket via Terraform.
   - Create a KMS-encrypted logging bucket.
   - Run TFSec to scan the S3 bucket for security vulnerabilities.

### Manually Running Terraform

1. Open the project in a supported editor like VSCode with Docker installed.
2. Use the provided devcontainer to start a consistent development environment.
3. Run Terraform commands manually inside the container:

   ```bash
   terraform init
   terraform plan
   terraform apply

## TFSec Scanning

TFSec is used to scan the Terraform infrastructure for potential security risks. It automatically runs within the Jenkins pipeline but can also be run manually for local testing.

To manually run TFSec:

```bash
tfsec .
```

## Devcontainer

This repository includes a `.devcontainer` folder for anyone who wants to run Terraform manually in a Docker-based development environment. The devcontainer comes pre-configured with both Terraform and TFSec installed.

### To use the devcontainer:

1. Open the project in **VSCode**.
2. When prompted by VSCode, choose to **reopen the project in a container**. This will automatically set up the development environment inside a Docker container with all required dependencies.
3. Once inside the devcontainer, you can run standard Terraform commands:

   ```bash
   terraform init
   terraform plan
   terraform apply
4. Additionally you can run TFSec scans from inside the container to check for any security vulnerabilities: 
    ```tfsec .
    This makes it easy for developers to run and test the Terraform configurations without needing to install anything locally.

## Infrastructure Details

- **S3 Website Bucket**: This S3 bucket is configured to host the website after being deployed via Terraform. It is set up with the necessary permissions for hosting static content.
  
- **Logging Bucket**: A separate S3 bucket is provisioned specifically for storing access logs. This bucket is encrypted using AWS KMS to ensure the security and confidentiality of your log data.

- **KMS Encryption**: The logging bucket is encrypted with AWS Key Management Service (KMS), adding an extra layer of security for your stored logs.

- **Terraform Modules**: The infrastructure is managed using Terraform modules, which make the code more modular, reusable, and maintainable. This helps keep the configurations organized and allows for easy updates.