docker_service 'default' do
  action [:create, :start]
end

['elasticsearch', 'logstash', 'kibana'].each do | image |
  docker_image image do
    action :pull
  end
end
