directory node['base2-fast-elk-docker']['elasticsearch']['data_path'] do
  recursive true
end


# export ES_HEAP_SIZE
# export ES_HEAP_NEWSIZE
# export ES_DIRECT_SIZE
# export ES_JAVA_OPTS
# export ES_GC_LOG_FILE
docker_container 'elasticsearch' do
  tag 'latest'
  command '/entrypoint.sh'
  port [ '9200:9200', '9300:9300']
  env [
    "ES_HEAP_SIZE=#{node['base2-fast-elk-docker']['elasticsearch']['heapsize']}"
  ]
  volumes [
    "/data/elasticsearch:/usr/share/elasticsearch/data",
    "/var/config/elasticsearch/elasticsearch.yml:/etc/elasticsearch/elasticsearch.yml",
    "/var/config/elasticsearch/docker-entrypoint.sh:/entrypoint.sh"
  ]
  log_driver = "json-file"
  log_opts "max-size=1g" #log_opts ["max-size=1g", "max-file=2", "labels=label1,label2", "env=evn1,env2"]
  detach true
  restart_policy 'always'
  action ["redeploy"]
end

docker_container 'logstash' do
  tag 'latest'
  command 'logstash -f /etc/logstash/conf.d/logstash.conf'
  volumes [ '/var/config/logstash:/etc/logstash/conf.d' ]
  port [ '5000:5000' ]
  links [ 'elasticsearch:elasticsearch' ]
  log_driver = "json-file"
  log_opts "max-size=1g" #log_opts ["max-size=1g", "max-file=2", "labels=label1,label2", "env=evn1,env2"]
  detach true
  restart_policy 'always'
  action ["redeploy"]
end

docker_container 'kibana' do
  tag 'latest'
  port [ '5601:5601' ]
  links [ 'elasticsearch:elasticsearch' ]
  env [ 'ELASTICSEARCH_URL=http://elasticsearch:9200' ]
  log_driver = "json-file"
  log_opts "max-size=1g" #log_opts ["max-size=1g", "max-file=2", "labels=label1,label2", "env=evn1,env2"]
  detach true
  restart_policy 'always'
  action ["redeploy"]
end

node['base2-fast-elk-docker']['elasticsearch']['plugins'].each do | plugin |
  docker_execute 'plugin' do
    container 'elasticsearch'
    command %w{gosu elasticsearch /usr/share/elasticsearch/bin/plugin install} << plugin << "-b"
  end
end

docker_container "elasticsearch" do
  action :restart
end
