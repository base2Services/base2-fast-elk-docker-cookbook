docker_service 'default' do
  action [:create, :start]
end

['elasticsearch', 'logstash', 'kibana', 'nginx'].each do | image |
  docker_image image do
    action :pull
  end
end
