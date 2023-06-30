
# Clone git repository to the local machine

----------------------------------------
# Install Terraform
sudo yum install -y yum-utils shadow-utils
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Create bash environment variable to keep key values save:
export TF_VAR_env_ak=*key_value*
export TF_VAR_env_sk=*key_value*

# Configure AWS environment with Terraform
cd Exercise-HW/terraform/
terraform init
terraform plan
terraform apply


----------------------------------------
#Install Ansible
pip install ansible

# Substitute Public IPs of newly created AWS instances
cd ../ansible
vi (or nano) playbook.yml

# Run ansible playbook with "-i inventory.yml" or create "~/.ansible.cfg file" and copy the content from the repo to define new default inventory path.
ansible-playbook playbook.yml -i inventory.yml

# Done!
