#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/

date > /etc/vagrant_box_build_time

fail()
{
  echo "FATAL: $*"
  exit 1
}

echo "installing epel RPM"
rpm -Uvh http://dl.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
#kernel source is needed for vbox additions
yum -y install vim-enhanced git screen curl gcc gcc-c++ bzip2 make kernel-devel-`uname -r`
yum -y erase gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts
#yum -y update
#yum -y upgrade

#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm VBoxGuestAdditions_$VBOX_VERSION.iso

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -i "s/^\(.*env_keep = \"\)/\1PATH /" /etc/sudoers

#install chef and ruby requirements
#yum -y install gcc-c++ patch readline readline-devel zlib zlib-devel \
#    libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake \
#    libtool bison dmidecode


#Installing ruby
echo "Installing ruby"
cd /tmp
wget http://4ad0a2808a2c43e9d0d6-330deec3c994fad5a61c9255051a5d28.r28.cf1.rackcdn.com/ruby-1.9.3-p194.x86_64.rpm
yum -y --nogpgcheck install ruby-1.9.3-p194.x86_64.rpm
ln -s /bin/ruby /usr/bin/ruby
ln -s /bin/gem /usr/bin/gem

#Installing chef
echo "Installing chef"
gem install chef --no-ri --no-rdoc || fail "Could not install chef"

ln -s /usr/local/bin/chef-solo /bin/chef-solo
ln -s /usr/local/bin/chef-client /bin/chef-client

#Get the bootstrap cookbooks to configure chef
mkdir -p /tmp/chef-solo/cookbooks
cd /tmp/chef-solo/cookbooks
git clone git://github.com/opscode-cookbooks/apache2.git
git clone git://github.com/opscode-cookbooks/apt.git
git clone git://github.com/opscode-cookbooks/bluepill.git
git clone git://github.com/opscode-cookbooks/build-essential.git
git clone git://github.com/opscode-cookbooks/chef-client.git
git clone --branch iptables-and-permission-fixes git://github.com/RSEmail/chef-server.git
#pushd chef-server
#git checkout 1.1.0
#popd
git clone git://github.com/opscode-cookbooks/chef.git
git clone git://github.com/opscode-cookbooks/couchdb.git
git clone git://github.com/opscode-cookbooks/daemontools.git
#git clone git://github.com/opscode-cookbooks/erlang.git
git clone --branch package-retries git://github.com/RSEmail/erlang.git
#git clone git://github.com/opscode-cookbooks/gecode.git
git clone --branch redhat-package git://github.com/RSEmail/gecode.git
git clone git://github.com/RSEmail/iptables.git
git clone git://github.com/opscode-cookbooks/java.git
git clone git://github.com/opscode-cookbooks/nginx.git
git clone git://github.com/opscode-cookbooks/openssl.git
git clone git://github.com/opscode-cookbooks/rabbitmq.git
git clone git://github.com/opscode-cookbooks/runit.git
git clone git://github.com/opscode-cookbooks/ucspi-tcp.git
git clone git://github.com/opscode-cookbooks/xml.git
#git clone git://github.com/opscode-cookbooks/yum.git
git clone --branch rbel-repo git://github.com/RSEmail/yum.git
git clone git://github.com/opscode-cookbooks/zlib.git

mkdir /etc/chef

cat > /etc/chef/solo.rb <<-EOF
file_cache_path "/tmp/chef-solo"
cookbook_path "/tmp/chef-solo/cookbooks"
EOF

cat > /tmp/chef-server.json <<-EOF
{
  "chef_server": {
    "server_url": "http://localhost:4000",
    "webui_enabled": true,
    "init_style": "init"
  },
  "run_list": [ "recipe[chef-server::rubygems-install]" ]
}
EOF

chef-solo -c /etc/chef/solo.rb -j /tmp/chef-server.json

cat > /tmp/chef-client.json <<-EOF
{
  "chef-client": {
    "server_url": "http://localhost:4000",
    "validation_client_name": "chef-admin",
    "init_style": "init"
  },
  "run_list": [ "recipe[chef-client::config]", "recipe[chef-client]" ]
}
EOF

chef-solo -c /etc/chef/solo.rb -j /tmp/chef-client.json

mkdir -p /root/.chef
touch /root/.chef/knife.rb

#Configure knife
knife configure \
    --initial \
    --server-url "http://localhost:4000" \
    --user "chef-admin" \
    --repository "/tmp/cookbook-repos" \
    --admin-client-name chef-webui \
    --admin-client-key /etc/chef/webui.pem \
    --validation-client-name chef-validator \
    --validation-key /etc/chef/validation.pem \
    --yes \
    --disable-editing \
    || { echo "Failed to configure knife."; exit 1; }

yum -y clean all

#poweroff -h

exit
