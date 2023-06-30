----------------------------------------
# Install aws-cli
cd ..
mkdir aws-cli
cd aws-cli/
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update


# Configure AWS environment

## Create VPC and Subnet
aws configure
aws ec2 create-vpc     --cidr-block 192.168.0.0/24
aws ec2 create-subnet --vpc-id vpc-04e3bafc1d9b32bb7 --cidr-block 192.168.0.0/25 --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=Workstation-subnet}]'

## Create Security Groups - one for LB HTTPS access, second for SSH and Internal access (Deny Any implicitly exists by default)
aws ec2 create-security-group --group-name Workstation-Sec-Group-LB  --description "Workstation-Sec-Group-LB" --vpc-id vpc-04e3bafc1d9b32bb7
aws ec2 create-security-group --group-name Workstation-Sec-Group-Common  --description "Workstation-Sec-Group-Common" --vpc-id vpc-04e3bafc1d9b32bb7

## Create Security rules
aws ec2 authorize-security-group-ingress --group-id sg-07bc61a695f05c454 --protocol tcp --port 80 --cidr 13.48.192.221/32
aws ec2 authorize-security-group-ingress --group-id sg-00add92595d237da7 --protocol tcp --port 22 --cidr 13.48.192.221/32
aws ec2 authorize-security-group-ingress --group-id sg-00add92595d237da7 --protocol all --cidr 192.168.0.0/25

## Create Internet GW and associate it with VPC
aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=my-igw}]'
aws ec2 attach-internet-gateway --internet-gateway-id igw-099c4a3a547c185d4 --vpc-id vpc-04e3bafc1d9b32bb7

## Create Route-table, assotiate it with VPC and Subnet, Create Default route towards Internet GW.
aws ec2 create-route-table --vpc-id vpc-04e3bafc1d9b32bb7
aws ec2 create-tags --resources "rtb-0b6dfc6617198bac5" --tags Key=Name,Value="linux-route-table"
aws ec2 associate-route-table --route-table-id rtb-0b6dfc6617198bac5 --subnet-id subnet-0369a4eb615cb2f56
aws ec2 create-route --route-table-id rtb-0b6dfc6617198bac5 --destination-cidr-block 0.0.0.0/0 --gateway-id igw-099c4a3a547c185d4



----------------------------------------
# Install Terraform
mkdir terraform
cd terraform/
sudo yum install -y yum-utils shadow-utils
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Configure main.tf and variables.tf files
# Create bash environment variable to keep keys values save:
export TF_VAR_env_ak=*key_value*
export TF_VAR_env_sk=*key_value*

# Create VMs with help of terraform
terraform init
terraform plan
terraform apply


----------------------------------------
#Install Ansible
pip install ansible
mkdir ansible
cd ansible

# Upload inventory and playbook files to the folder

# Run ansible playbook with "-i inventory.yml" or create "~/.ansible.cfg file" with new default inventory path.
ansible-playbook playbook.yml -i inventory.yml



