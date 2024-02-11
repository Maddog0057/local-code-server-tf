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
* Keybase CLI
* Ping, netcat, and a few other network utilities

Utilities without a version are updated automatically

### The server will be available on http://localhost:port where port saved as part of the server URL in 1Password

## Installation

### Requirements:
* Git - https://git-scm.com/downloads
* Docker - https://docs.docker.com/get-docker/
* Terraform - https://developer.hashicorp.com/terraform/install
* 1Password CLI - https://developer.1password.com/docs/cli/get-started/

### Procedure:
* `git clone https://github.com/Maddog0057/local-code-server-tf`
* `cd local-code-server-tf`
* `terraform plan`
* `terraform apply -auto-approve`

## Customize Your Environment

### Windows Support
Out of the box this script is configured for MacOS/Unix, in order to run on Widows update the docker provider in `providers.tf` to `host = "tcp://127.0.0.1:2376"`

### Apple Silicon
There is no additional action items for Apple Silicon so long as Rosetta supprt is enabled in Docker, all packages are universal.

### 1Password Support
Configured out of the box, add a file called `secrets.tf` (or `literally_anything.tf`) and add local variables for `op_token` pointing to your 1password API token and `op_vault` to your vault ID. If you copy a link to any item in the vault `v=blah` will be part of the link, `blah` is your vault ID. Using this same method you can also find the Item UUID of any item by looking at `i=blah`. You can find out how to generate an API token here https://developer.1password.com/docs/service-accounts/get-started/

### PKI Support
TF will generate an ed25519 key pair and upload the public key along with it's SHA256 fingerprint to the same 1password object as your sudo password. Enabling `copy-public-key.tf` (remove `.off`) and configuring the `remote_docker_host` data source in `providers.tf` to point to a 1password object containing login informaton for your remote host will automatically trust your code server on that host on apply and remove access on destroy.

This key can also be uploaded to GitHub, GitLab, or both so long as a personal access token from each site is saved as a 1password item and the item UUID is provided as a local variable in `secrets.tf` as either `gl_token` or `gh_token`. 

I also have a working-ish bitbucket solution but its hacky and doesn't remove the key on destroy (just sets the expiration really low), I may add it as a branch at some point if there's interest.

For my own sanity: 
```
git config --global user.name "username"
git config --global user.email "email address"
```

### Remote Docker Daemon Access
Seemed like a pain to try and get this to run docker in docker, and passing through the local socket sounds like a bad idea so this seemed like a cool middle ground, you will *essentially* have root access on the target machine but the connection is encrypted and you need root to achieve this anyway. 
On the target machine (make sure you have root) allow a user access to the docker daemon socket (`/var/run/docker.sock` usually) this can be done in a variety of ways (almost all carry increased risk!), simply `sudo usermod -aG docker <your_user>` usually works nicely (and is highly risky! Do this within an internal network only!!!), you can also mess around with simlinks, docker as a local user, etc. but this method will work with what I have built.

#### To Enable remote docker access complete the following
* On your target machine verify access to the docker daemon by running `docker info` as your target user
* In 1Password create a login item with the username and password of the target account and set the website to the IP/hostname of your target machine
* Add a local varible for `op_ssh_id` in `secrets.tf` pointing to the UUID of the 1Password item
* Uncomment the last section of `copy-public-key.tf`

If you are running your code server local start it at this point, if not, you have one last step
* In `providers.tf` Uncomment the remote host line and comment the local docker host line

Once your server is running perfrom the last step above for access to remote docker daemon within your code server container

### Adding and Subtracting Utilities
Any package available by way of the APT repository can be added to the install list in `code-server-setup.sh` otherwise add your install script to the end of the file, just make sure `/init` is always the last line of the file.

Any Utility can be removed from the script, the script can even be removed altogether, the VS code server relies on it in no way, it is simply a way to pre-install commonly needed tools.

Base Image: https://docs.linuxserver.io/images/docker-code-server/

> All actions are taken at your own risk, I am not responsible for any damage or harm that may come of you related or unrelated to this repository 
