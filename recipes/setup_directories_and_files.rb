%w{logstash elasticsearch nginx}.each do | dir |
  directory "/var/config/#{dir}" do
    recursive true
  end
end

%w{ 01-input.conf 10-windows-event-vwr.conf 10-iis.conf 99-logstash.conf }.each do | template|
  template "/var/config/logstash/#{template}" do
    source "logstash/#{template}.erb"
  end
end

%w{elasticsearch.yml docker-entrypoint.sh}.each do | template |
  template "/var/config/elasticsearch/#{template}" do
    source "elasticsearch/#{template}.erb"
  end
end

file "/var/config/elasticsearch/docker-entrypoint.sh" do
  mode '0755'
end

template "/var/config/nginx/nginx.conf" do
  source "nginx/nginx.conf.erb"
end

case node['platform_family']
when 'debian'
  package 'apache2-utils'
when 'rhel'
  package 'httpd-tools'
end

#refactor here for passwd
kibana_password = node['base2-fast-elk-docker']['kibana']['user']
kibana_user = node['base2-fast-elk-docker']['kibana']['password']

execute "mk passwd" do
  command "sudo htpasswd -b -c /var/config/nginx/htpasswd.users #{kibana_password} #{kibana_user} "
end
