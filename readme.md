# Local VS Code Server Using Docker and Terraform

I wanted a portable dev environment, liked code-server, and got sick of installing the same utilities all the time.
Working on getting roaming profile support working without the need for a cloud service....

### This container will spin up a VS code server with the following components:
* Terraform 1.6.6
* GitHub CLI
* kubectl 1.26
* helm 3.11.2
* 1password CLI
* Powershell 7.4
* Python 3
* Ping, netcat, and a few other network utilities

Utilities without a version are updated automatically

### The server URL will be provided as Terraform output

## Installation

### Requirements:
* Git - https://git-scm.com/downloads
* Docker - https://docs.docker.com/get-docker/
* Terraform - https://developer.hashicorp.com/terraform/install

### Procedure:
* `git clone https://github.com/Maddog0057/local-code-server-tf`
* `cd local-code-server-tf`
* `terraform plan`
* `terraform apply -auto-approve`

## Customize Your Environment

### Windows Support
Out of the box this script is configured for MacOS/Unix, in order to run on Widows update the docker provider in `docker.tf` to `host = "tcp://127.0.0.1:2376"`

### Apple Silicon
There is no additional action items for Apple Silicon so long as Rosetta supprt is enabled in Docker, all packages are universal.

### 1Password Support
This script is configured to allow for one password secret access. Checkout branch `1password` for instructions.

### Adding and Subtracting Utilities
Any package available by way of the APT repository can be added to the install list in `code-server-setup.sh` otherwise add your install script to the end of the file, just make sure `/init` is always the last line of the file.

Any Utility can be removed from the script, the script can even be removed altogether, the VS code server relies on it in no way, it is simply a way to pre-install commonly needed tools.

Base Image: https://docs.linuxserver.io/images/docker-code-server/