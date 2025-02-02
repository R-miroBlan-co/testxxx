variable "vpc_id" { type = string }
variable "subnet_id" { type = string }

locals { app = "openvpn" }

source "amazon-ebs" "debian" {
  ami_name      = "${local.app}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  subnet_id     = "${var.subnet_id}"
  vpc_id        = "${var.vpc_id}"
  source_ami_filter {
    filters = {
      image-id            = "ami-06db4d78cb1d3bbf9"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["136693071363"]
  }
  associate_public_ip_address = true
  ssh_username                = "admin"
  force_deregister            = true
  force_delete_snapshot       = true
  tags = {
    Env  = "app"
    Name = "${local.app}"
  }
}

build {
  sources = ["source.amazon-ebs.debian"]

  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    user          = "admin"
    ansible_env_vars = [ "ANSIBLE_SSH_ARGS=-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedKeyTypes=+ssh-rsa", "ANSIBLE_HOST_KEY_CHECKING=False", "ANSIBLE_ROLES_PATH=../../roles/", "ANSIBLE_NOCOLOR=True" ]
  }
}

