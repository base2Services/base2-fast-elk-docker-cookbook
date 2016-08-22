directory node['base2-fast-elk-docker']['elasticsearch']['data_path'] do
  recursive true
end

execute "clear linked containers" do
  command <<-EOF
    docker ps -a | grep -q kibana && docker rm -f kibana
    docker ps -a | grep -q logstash && docker rm -f logstash
    docker ps -a | grep -q elasticsearch && docker rm -f elasticsearch
    docker ps -a | grep -q nginx && docker rm -f nginx
  EOF
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

docker_container 'nginx' do
  tag 'latest'
  port [ '80:80' ]
  links [ 'kibana:kibana' ]
  volumes [ "/var/config/nginx/nginx.conf:/etc/nginx/nginx.conf" ]
  log_driver = "json-file"
  log_opts "max-size=1g" #log_opts ["max-size=1g", "max-file=2", "labels=label1,label2", "env=evn1,env2"]
  detach true
  restart_policy 'always'
  action ["redeploy"]
end

#TODO:
#kibana: apt-get update && apt-get install apache2-utils  && htpasswd -b -c /etc/nginx/htpasswd.users kibanaadmin daihatsudomino
#logrotate
