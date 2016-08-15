%w{logstash elasticsearch}.each do | dir |
  directory "/var/config/#{dir}" do
    recursive true
  end
end

%w{ logstash.conf }.each do | template|
  template "/var/config/logstash/#{template}" do
    source "logstash/#{template}"
  end
end

%w{elasticsearch.yml docker-entrypoint.sh}.each do | template |
  template "/var/config/elasticsearch/#{template}" do
    source "elasticsearch/#{template}"
  end
end
