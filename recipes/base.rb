# Set convenient variables from attributes
engineIso=node['mse']['install']['iso']['engine']
isoImages=node['mse']['install']['iso']['product']+[engineIso]
isoUrl=node['mse']['install']['isoUrl']
yumRepo = node['mse']['install']['yumRepo']
sshKeysUrl=node['mse']['install']['sshKeysUrl']

# MSE constants
isoRepo='/var/opt/OC/iso/'
isoMountPoint='/media/cdrom/'

log "Create the MSE directories"
[isoRepo,isoMountPoint].each do |mseDir|
  directory "#{mseDir}" do
    recursive true
  end
end
log "Get the MSE ISO images"
isoImages.each do |isoImage| 
  remote_file isoRepo+"#{isoImage}" do
    source isoUrl+"#{isoImage}"
  end
end
log "Install MSE engine"
mount isoMountPoint do
  device isoRepo+engineIso
  options 'loop'
  action [:mount]
end
remote_file isoRepo+'install-tas.sh' do
  source 'file://'+isoMountPoint+'utils/install-tas.sh'
  mode 0755
end
log "Install versionlock plugin for yum"
package 'yum-plugin-versionlock' do
  action :upgrade
end
execute 'getInstaller' do
  command 'umount '+isoMountPoint+' ; '+isoRepo+'install-tas.sh'+' --yes --install hpe-install-tas --disableplugin=yum-plugin-versionlock --iso '+isoRepo+engineIso
end
execute "hpe-install-tas.sh --yes --install --with-hpoc-tls-certificates --with-hpe-mse-nfv --with-hpoc-uspm-nfv --enablerepo='"+yumRepo+"' --iso "+isoRepo+engineIso
log" Apply patches"
remote_file '/opt/OC/sbin/nivr-nfv-util.sh' do
  source isoUrl+'nivr-nfv-util.sh'
  mode 0755
end

log "Make sure the host is in /etc/hosts"
execute 'updateHosts' do 
  command "grep "+node['cloud']['public_ipv4']+" /etc/hosts || echo "+node['cloud']['public_ipv4']+" $(hostname) $(hostname -s) >> /etc/hosts"
end

log "Enable ssh for root and ocadmin with fixed keys"
execute 'enableRootSsh' do
  command 'sed -i "/^PasswordAuthentication.*no/d" /etc/ssh/sshd_config'
  command 'sed -i "s/#PasswordAuthentication.*/PasswordAuthentication yes/" /etc/ssh/sshd_config'
  command 'sed -i "/^PermitRootLogin.*no/d" /etc/ssh/sshd_config'
  command 'sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/" /etc/ssh/sshd_config'
end
directory '/root/.ssh' do
    recursive true
end
directory '/home/ocadmin/.ssh' do
    recursive true
end
directory '/etc/ssh' do
    recursive true
end
remote_file "/root/.ssh/id_rsa.pub" do
  source sshKeysUrl+'id_rsa.pub'
  mode 0600
end
remote_file "/root/.ssh/id_rsa" do
  source sshKeysUrl+'id_rsa'
  mode 0600
end
remote_file "/root/.ssh/authorized_keys" do
  source sshKeysUrl+'id_rsa.pub'
  mode 0600
end
remote_file "/home/ocadmin/.ssh/id_rsa.pub" do
  source sshKeysUrl+'id_rsa.pub'
  mode 0600
  owner 'ocadmin'
end
remote_file "/home/ocadmin/.ssh/id_rsa" do
  source sshKeysUrl+'id_rsa'
  mode 0600
  owner 'ocadmin'
end
remote_file "/home/ocadmin/.ssh/authorized_keys" do
  source sshKeysUrl+'id_rsa.pub'
  mode 0600
  owner 'ocadmin'
end
['ecdsa','ed25519'].each do |aKeyType|
  remote_file "/etc/ssh/ssh_host_#{aKeyType}_key" do
    source sshKeysUrl+"ssh_host_#{aKeyType}_key"
    mode 0640
  end
end
['rsa'].each do |aKeyType|
  remote_file "/etc/ssh/ssh_host_#{aKeyType}_key" do
    source sshKeysUrl+"ssh_host_#{aKeyType}_key"
    mode 0600
  end
end
['ecdsa','ed25519','rsa'].each do |aKeyType|
  remote_file "/etc/ssh/ssh_host_#{aKeyType}_key.pub" do
    source sshKeysUrl+"ssh_host_#{aKeyType}_key.pub"
    mode 0644
  end
end
service 'sshd' do
  action :restart
end

log "Start all MSE engines services"
['nivr','ocmp','ocsnf','uspm'].each do |vnfc|
  service "#{vnfc}-nfv" do
    # mse nfv services needs to be started only if not already successfully completed
    start_command "service #{vnfc}-nfv status || service #{vnfc}-nfv start"
    action :start
  end
end