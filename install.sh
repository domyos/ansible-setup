username=$1
repo=$2
pat=$3

# Update pacman and install required packages for this script
pacman -Syu --noconfirm
pacman -Sy --noconfirm git ansible

# Create ssh key
ssh-keygen \
  -f ~/.ssh/id_rsa \
  -N "" \
  -t ed25519

# Create ssh config so root can clone git repo
cat >~/.ssh/config <<'EOL'
Host github
  Hostname github.com
  User git
  IdentityFile ~/.ssh/id_rsa
EOL

# Add github to known hosts
ssh-keyscan -H github.com >> ~/.ssh/known_hosts

# Configure root ssh key in github
root_key_id=$(curl -i -u "$username:$pat"   --data '{"title":"root-key","key":"'"$(cat ~/.ssh/id_rsa.pub)"'"}'   https://api.github.com/user/keys | grep \"id\" | cut -d' ' -f4- | head -c -2)

# Initially apply ansible config
ansible-pull -o -U $repo

# Remove root ssh key from github
curl -i -u "$username:$pat" \
  -X DELETE \
  https://api.github.com/user/keys/$root_key_id

# Remove unnecessary root ssh config files
rm /root/.ssh/known_hosts /root/.ssh/config

# Create ssh key for ansible user
sudo -u ansible ssh-keygen \
  -f /home/ansible/.ssh/id_rsa \
  -N "" \
  -t ed25519

# Creeate ssh config for ansible user
sudo -u ansible cat >/home/ansible/.ssh/config <<'EOL'
Host github
  Hostname github.com
  User git
  IdentityFile /home/ansible/.ssh/id_rsa
EOL

# Add github to ansible users known hosts file
sudo -u ansible ssh-keyscan -H github.com >> /home/ansible/.ssh/known_hosts

# Configure ansible ssh key in github
sudo -u ansible curl -i -u "$username:$pat" \
  --data '{"title":"ansible-key","key":"'"$(cat /home/ansible/.ssh/id_rsa.pub)"'"}' \
  https://api.github.com/user/keys
