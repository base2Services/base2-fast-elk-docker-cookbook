docker_service 'default' do
  action [:create, :start]
  not_if { "which docker" }
end

['elasticsearch', 'logstash', 'kibana', 'nginx'].each do | image |
  docker_image image do
    action :pull
  end
  #execute "docker pull #{image}"
end
