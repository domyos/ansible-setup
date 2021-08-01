# Script to setup ansible-pull

1. Create a PAT with write:public_key that expires after one day
2. Run the following command to run setup script. Don't forget to replace variables.
    
    `sudo curl https://raw.githubusercontent.com/domyos/ansible-setup/main/install.sh | sudo bash -s $GITHUB_USERNAME $ANSIBLE_GIT_REPO $PERSONAL_ACCESS_TOKEN`
