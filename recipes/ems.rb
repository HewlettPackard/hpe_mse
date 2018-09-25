# The ems role needs the list of all deployed nodes: kitchen-nodes offers this view
MSEdescriptor='/etc/opt/OC/hpoc-nivr-nfv/nivr-cluster-nfv.properties'
gem_package 'kitchen-nodes'
require 'ipaddr'
def is_ip?(ip)
  !!IPAddr.new(ip) rescue false
end

include_recipe 'hpe_mse::base'

# Resource used to trigger a refresh on the EMS node, in case of ISO image(s) change
log 'RefreshOnIsoChange' do
  notifies :restart,'service[nivr-nfv]',:immediately
  action :nothing
end

log "Defining all MSE nodes names and IP addresses as attributes in mse.map"
# Example on Amazon: ipaddress is a public name, fqdn a private name embedding the ip address
#  "ipaddress": "ec2-18-202-81-148.eu-west-1.compute.amazonaws.com"
#  "platform": "ems",
#  "fqdn": "ip-172-31-31-176.eu-west-1.compute.internal"
# Example on Azure: ipaddress is the public address and fqdn the public DNS name
#  "ipaddress": "40.127.108.2",
#  "platform": "pgsql",
#  "fqdn": "pgsql.mse.azure.x0cb5u5qoabu1od5darsccyq5d.fx.internal.cloudapp.net",
search("node","*:*").each do |aNode|
  theNode=aNode['platform']
  theNodeHostname=aNode['fqdn'] 
  if ! theNodeHostname
    theNodeHostname="(undefined)"
  end
  theNodeIpAddress=aNode['ipaddress']
  # if the Ip address is not valid, try an Amazon format ip-x.y.z.t...
  if ! is_ip?(theNodeIpAddress)
    _ipDeco=theNodeHostname.split(".")[0].split("-")
    if _ipDeco[0] == "ip" 
      theNodeIpAddress=_ipDeco[1]+"."+_ipDeco[2]+"."+_ipDeco[3]+"."+_ipDeco[4]
    else
      raise "Node "+theNode+" has an invalid IP address "+theNodeIpAddress
    end
  end

  log "The node "+theNode+" named "+theNodeHostname+" has IP address: "+theNodeIpAddress
  node.default['mse']['map'][theNode]['hostname']=theNodeHostname
  node.default['mse']['map'][theNode]['ipaddress']=theNodeIpAddress
end

service 'nivr-nfv' do
  restart_command "service nivr-nfv status && service nivr-nfv node-reload && service nivr-nfv start || echo Refresh unavailable: skipped"
end

log "Building MSE descriptor "+MSEdescriptor+".erb template from attribute: node['mse']['deploy']['descriptor']"
file MSEdescriptor+".erb" do
  content node['mse']['deploy']['descriptor']
  mode '0755'
  owner 'root'
end
log "Turn "+MSEdescriptor+".erb to an actual Chef template"
execute 'makeErb' do
  command 'sed -i "s/_%_/%/g" '+MSEdescriptor+".erb"
end

log "Build MSE descriptor from template; restart nivr-nfv in case of change for refreshing the instance"
template MSEdescriptor do
  local true
  source MSEdescriptor+".erb"
  mode '0755'
  notifies :restart,'service[nivr-nfv]',:immediately
end

log "Wait synchronously for the consolidated status"
execute 'waitForSuccessOfFailure' do 
  command 'sleep 20s && until service nivr-nfv consolidated-status || (( $? > 127 )) ; do sleep 20s ; done && service nivr-nfv consolidated-status'
end