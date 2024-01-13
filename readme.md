# Local VS Code Server Using Docker and Terraform

I wanted a portable dev environment, liked code-server, and got sick of installing the same utilities all the time.
Working on getting roaming profile support working without the need for a cloud service....

### This container will spin up a VS code server with the following components:
* Terraform
* GitHub CLI
* kubectl
* 1password
* Powershell
* Python 3.10
* Ping, netcat, and a few other network utilities

### The server will be available on http://localhost:port where port is provided as an output at tf apply

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
Configured out of the box, add a file called `secrets.tf` (or `literally_anything.tf`) and add local variables for `op_token` pointing to your 1password API token and `op_vault` to your vault ID. If you copy a link to any item in the vault `v=blah` will be part of the link, `blah` is your vault ID. Using this same method you can also find the Item UUID of any item by looking at `i=blah`. You can find out how to generate an API token here https://developer.1password.com/docs/service-accounts/get-started/

### Adding and Subtracting Utilities
Any package available by way of the APT repository can be added to the install list in `code-server-setup.sh` otherwise add your install script to the end of the file, just make sure `/init` is always the last line of the file.

Any Utility can be removed from the script, the script can even be removed altogether, the VS code server relies on it in no way, it is simply a way to pre-install commonly needed tools.

Base Image: https://docs.linuxserver.io/images/docker-code-server/