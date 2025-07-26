# 🚀 Deploying a Flask App on AWS EC2 using Terraform

This project uses **Terraform** to deploy a simple **Flask** web app on an **AWS EC2 instance**.

- Uses **Terraform Provisioners**:
  - **`remote-exec`**: Installs Python & Flask, runs the Flask app.
  - **`file`**: Uploads `app.py` from local to EC2.
  - **`local-exec`**: Outputs the EC2 **public IP** to easily access the app after deployment.

- **Flask** app listens on **port 80**, publicly accessible via the EC2 instance.
- Infrastructure is defined using **Infrastructure as Code (IaC)** with Terraform.
- Simple and efficient for learning **automation on AWS**.


