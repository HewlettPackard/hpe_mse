# Set convenient variables from attributes
engineIso=node['mse']['install']['iso']['engine']
isoImages=node['mse']['install']['iso']['product']+[engineIso]
mseLabDrops=node['mse']['install']['iso']['labdrops']
mseBinaries=isoImages+mseLabDrops
isoUrl=node['mse']['install']['isoUrl']
yumRepo = node['mse']['install']['yumRepo']
sshKeysUrl=node['mse']['install']['sshKeysUrl']
mandatoryServices=node['mse']['install']['mandatoryServices']

# MSE constants
isoRepo='/var/opt/OC/iso/'
isoMountPoint='/media/cdrom/'

theNode=node['name']
theNodeHostname=node['cloud']['local_hostname']
theNodeIpAddress=node['cloud']['local_ipv4']
# if the local hostname is undefined, switch to the public interface (eg Azure)
if !theNodeHostname
  theNodeHostname="$(hostname)"
  theNodeIpAddress=node['cloud']['public_ipv4']
end
log "MSE node:"+theNode+" at ipAddress:"+theNodeIpAddress+" is named:"+theNodeHostname

log "Enable root at the console prompt"
execute "echo 'root:hwroot' | chpasswd"

log "Enforce name resolution to *not* use myhostname in /etc/nsswitch.conf for getent"
execute "sed -i -e 's%myhostname%%' /etc/nsswitch.conf"

log "Create the MSE directories"
[isoRepo,isoMountPoint].each do |mseDir|
  directory "#{mseDir}" do
    recursive true
  end
end

# Resource used to trigger a refresh on the EMS node, in case of ISO image(s) change
# Defined to no-operation on a base node, overridden on ems node, see ems.rb
log 'RefreshOnIsoChange' do
  action :nothing
end

log "(optional) Get the MSE ISO images and lab drops in #{isoRepo} from local cache"
mseBinaries.each do |_binaryFile| 
  cookbook_file isoRepo+"#{_binaryFile}" do
    source _binaryFile
    notifies :write,'log[RefreshOnIsoChange]',:immediately  
    ignore_failure true
  end
end

log "Get the MSE ISO images and lab drops in #{isoRepo} from remote #{isoUrl}"
mseBinaries.each do |_binaryFile| 
  remote_file isoRepo+"#{_binaryFile}" do
    source isoUrl+"#{_binaryFile}"
    notifies :write,'log[RefreshOnIsoChange]',:immediately  
  end
end

log "Remove unused ISO images"
execute "ls "+isoRepo+"*.iso | grep -v -e "+isoImages.join(" -e ")+" | xargs rm -f "

log "Install MSE engine"
mount isoMountPoint do
  device isoRepo+engineIso
  options 'loop'
  action [:mount]
end

['cluster-manager','tas'].each do |theInstaller|
  remote_file isoRepo+"install-#{theInstaller}.sh" do
    source "file://"+isoMountPoint+"utils/install-#{theInstaller}.sh"
    mode 0755
    ignore_failure true
  end
end

mount isoMountPoint do
  device isoRepo+engineIso
  action [:unmount]
end

log "Install versionlock plugin for yum"
package 'yum-plugin-versionlock'

log "Install createrepo for labdrops management"
package 'createrepo'

bash 'getInstaller' do 
  user 'root'
  cwd  isoRepo
  code <<-EOH
    test -f install-cluster-manager.sh && _theInstaller=cluster-manager || _theInstaller=tas 
    ./install-${_theInstaller}.sh --yes --install hpe-install-${_theInstaller} --disableplugin=yum-plugin-versionlock --iso #{engineIso} && 
    ./install-${_theInstaller}.sh --yes --install --with-hpoc-tls-certificates --with-hpe-mse-nfv --with-hpoc-uspm-nfv --enablerepo='#{yumRepo}' --iso #{engineIso}
  EOH
end

log "Create a yum version lock file for lab drops"
bash 'labdropsVersionLock' do
  cwd isoRepo
  code <<-EOH
    test -f install-cluster-manager.sh && _theInstaller=cluster-manager || _theInstaller=tas
    find *.rpm -exec rpm -qp {} --qf '%{epoch}:%{name}-%{version}-%{release}.*\\n' \\; > /etc/opt/OC/hpe-install-${_theInstaller}/versionlock.d/hpe-mse-nfv-999-versionlock.list || echo no lab drops
  EOH
end

log "Create a labdrops yum repository for rpm packages in #{isoRepo}"
execute "createrepo --database #{isoRepo}"
file '/etc/yum.repos.d/labdrops.repo' do
  owner'root'
  content "[labdrops]\nname=lab drops\nbaseurl=file://#{isoRepo}\nenabled=1\ngpgcheck=0"
end

log "Upgrade with lab drops from #{isoRepo}"
bash 'upgradeLabDrops' do
  user 'root'
  cwd  isoRepo
  code <<-EOH
    test -f install-cluster-manager.sh && _theInstaller=cluster-manager || _theInstaller=tas &&
    ./install-${_theInstaller}.sh --yes --upgrade --enablerepo='#{yumRepo}' --iso #{engineIso}
  EOH
end

log "Start mandatory explicit services #{mandatoryServices}"
mandatoryServices.each do |aService|
  service "#{aService}" do
    action [:enable,:start]
  end
end

log "Make sure the host is in /etc/hosts"
execute 'updateHosts' do 
  command "grep "+theNodeHostname+" /etc/hosts || echo "+theNodeIpAddress+" "+theNodeHostname+" >> /etc/hosts"
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
    owner 'ocadmin'
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
    # ignore start error, as this can mean that the service is already running
    start_command "service #{vnfc}-nfv status || service #{vnfc}-nfv start || echo started"
    action :start
  end
end

# (C) Copyright 2018 Hewlett Packard Enterprise Development LP.