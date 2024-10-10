# benchmark-infrastructure
The infrastructure for the benchmark includes a set of Vulnerable by Design (VbD) Targets of Evaluation (ToEs) used to measure the speed and accuracy of automated Application Security Testing (AST) tools.

# Deployment Steps

1. **Configure an IAM User:**
   Create an IAM user with permissions to read, write, and modify EC2 instances.

2. **Create an Access Key:**
   Generate an access key for the IAM user you just created.

3. **Configure AWS CLI:**
   Run `aws configure` and enter the access key from the previous step.

4. **Create a Cloudflare API Token:**
   Generate a Cloudflare API token with read and write permissions for the specific domain or zone you intend to use.

6. **Generate SSH key for the EC2 instance**
   Generate an SSH key for the EC2 instance, for example using the command `ssh-keygen -t ed25519`

7. **Update Variables in `variables.tf`:**
   Replace the required variables in the `variables.tf` file with your specific values.

8. **Deploy the VbD ToEs:**
   Run the deployment script with the following command `./deploy.sh`
