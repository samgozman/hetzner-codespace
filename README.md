# hetzner-codespace

Your personal VS code codespace running on Hetzner server

ssh-keygen -t rsa -b 4096 -f ./id_rsa_github

TF_VAR_HCLOUD_TOKEN

## TODO:
- Run tunnel on server by action (`code tunnel --name linux-space --accept-server-license-terms`)
- Store terraform state in s3
- Get terraform state from s3 before update/delete action
- Create delete action
- Provide documentation
