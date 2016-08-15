%w{logstash elasticsearch}.each do | dir |
  directory "/var/config/#{dir}" do
    recursive true
  end
end

template "/var/config/logstash/logstash.conf"

%w{elasticsearch.yml docker-entrypoint.sh}.each do | template |
  template "/var/config/elasticsearch/#{template}" do
    source "elasticsearch/#{template}"
  end
end
