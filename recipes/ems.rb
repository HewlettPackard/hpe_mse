# The ems role needs the list of all deployed nodes: kitchen-nodes offers this view
gem_package 'kitchen-nodes'
MSEdescriptor='/etc/opt/OC/hpoc-nivr-nfv/nivr-cluster-nfv.properties'

include_recipe 'hpe_mse::base'

log "Defining all MSE nodes names  IP addresses as attributes in mse.map"
search("node","*:*").each do |aNode|
  log "The node "+aNode['platform']+" has IP address: "+aNode['ipaddress']
  node.default['mse']['map'][aNode['platform']]['ipaddress']=aNode['ipaddress']
end

service 'nivr-nfv' do
  restart_command "service nivr-nfv status && service nivr-nfv node-reload && service nivr-nfv start || echo Refresh unavailable: skipped"
end

log "Testing embedded descriptor: "+node['mse']['deploy']['descriptor']
file MSEdescriptor+".erb" do
  content node['mse']['deploy']['descriptor']
  mode '0755'
  owner 'root'
end
log "Turn "+MSEdescriptor+".erb to an actual Chef template"
execute 'makeErb' do
  command 'sed -i "s/@/%/g" '+MSEdescriptor+".erb"
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
