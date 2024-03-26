sudo dnf install python3.11 -y
sudo dnf install python3.11-pip -y
python3.11 -m pip install --user virtualenv
virtualenv -p /usr/bin/python3.11 env
source env/bin/activate
sudo dnf install git -y
git clone https://github.com/mastodon/mastodon-ansible.git
cd mastodon-ansible
pip install -r requirements.txt
cp templates/secrets.yml.tpl secrets.yml
# do this from "~/mastodon-ansible":
# when you vi, fix the passwords and stuff, then type ":x" to save
# vi secrets.yml
# copy-paste this into secrets.yml
# encrypt secrets.yml with the following
echo "local_domain: 'guschat'
mastodon_db_password: 'gus'
redis_pass: 'gus'
letsencrypt_email: ''
mastodon_host: 'guschat'
run_preflight_checks: 'false'
disable_letsencrypt: 'true'" >> secrets.yml

ansible-vault encrypt secrets.yml

echo "$(hostname -I)       $(hostname -I)" >> /etc/hosts


# sudo hostnamectl set-hostname guschat

# for our puposes we also need to add our own key to .ssh/authorized_keys "ssh-keygen -t ed25519 -C gus" because we'll use localhost
# ssh into the thing and vi bare/vars/common.yml and set the "run_preflight_checks" to "false":
ansible-playbook bare/playbook.yml --ask-vault-pass -i localhost, -u gus --ask-become-pass -e 'ansible_python_interpreter=/usr/bin/python3' --extra-vars="@secrets.yml"
# run this to update necessary npx browserslist
npx update-browserslist-db@latest
# then we run the thing again
ansible-playbook bare/playbook.yml --ask-vault-pass -i localhost, -u gus --ask-become-pass -e 'ansible_python_interpreter=/usr/bin/python3' --extra-vars="@secrets.yml"

# add localhost to the hosts whitelist:
sudo vi /home/mastodon/live/config/environments/production.rb
# [root@localhost environments]# grep config.hosts /home/mastodon/live/config/environments/production.rb -B 1
#Rails.application.configure do
#  config.hosts << "localhost"

# to allow any ip to avoid the 403 append the following as well and restart:
#  config.hosts << "0.0.0.0"
# and restart mastodon:
sudo systemctl restart mastodon-web