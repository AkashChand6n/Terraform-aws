
# Terraform Study Repository

This repository contains the Terraform configurations I have worked on while learning and studying Terraform. The goal is to automate the provisioning and management of cloud infrastructure using Infrastructure as Code (IaC).

## Contents

- **Terraform Scripts**: The main Terraform scripts to manage infrastructure.
- **Modules**: Reusable components for organizing Terraform configurations.
- **Outputs**: Terraform outputs for tracking and accessing infrastructure details.
- **State Management**: Information on managing Terraform state files.

## Prerequisites

Before using the Terraform scripts in this repository, ensure that you have the following installed on your machine:

- [Terraform](https://www.terraform.io/downloads.html)
- Cloud provider CLI (e.g., AWS CLI) and credentials set up for your cloud provider (e.g., AWS, GCP, Azure).
- Text editor or IDE (e.g., VS Code, IntelliJ) with Terraform extensions (optional but recommended).

## Getting Started

Follow the steps below to get started with the Terraform configurations:

### 1. Clone the Repository

```bash
git clone https://github.com/AkashChand6n/Terraform-aws.git
cd terraform-study-repo
```

### 2. Configure Provider Credentials

Ensure that you have your cloud provider's credentials configured properly. For example, for AWS, you can configure using the AWS CLI:

```bash
aws configure
```

Alternatively, you can set environment variables or use a service account file for other cloud providers.

### 3. Initialize Terraform

In the project directory, initialize Terraform to download necessary providers:

```bash
terraform init
```

### 4. Plan the Infrastructure

Before applying the changes, you can preview the infrastructure changes:

```bash
terraform plan
```

### 5. Apply the Configuration

To apply the configuration and create the resources defined in the Terraform scripts, run:

```bash
terraform apply
```

Terraform will prompt you to confirm the changes. Type `yes` to proceed.

### 6. Destroy the Infrastructure (Optional)

If you want to destroy the created infrastructure, use the following command:

```bash
terraform destroy
```

This will delete all resources defined in the Terraform configuration.

## Directory Structure

```plaintext
├── modules/
│   ├── module_name/
│   └── another_module/
├── main.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

- **modules/**: Contains reusable Terraform modules.
- **main.tf**: The main Terraform configuration file, where resources are defined.
- **variables.tf**: Defines the input variables for the Terraform scripts.
- **outputs.tf**: Defines the output values from the Terraform configuration.
- **terraform.tfvars**: Holds the values for the variables (optional).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Terraform Documentation: [https://www.terraform.io/docs](https://www.terraform.io/docs)
- Cloud Provider Documentation (AWS, GCP, etc.)
