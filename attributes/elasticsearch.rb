default['base2-fast-elk-docker']['elasticsearch']['data_path'] = '/data/elasticsearch'
default['base2-fast-elk-docker']['elasticsearch']['heapsize'] = '2g'
default['base2-fast-elk-docker']['elasticsearch']['cluster_name'] = "elk_#{node.chef_environment}"
default['base2-fast-elk-docker']['elasticsearch']['discovery']['aws'] = true
default['base2-fast-elk-docker']['elasticsearch']['discovery']['role'] = 'search'
default['base2-fast-elk-docker']['elasticsearch']['discovery']['role_name'] = 'Role'

default['base2-fast-elk-docker']['elasticsearch']['plugins'] = [ 'lmenezes/elasticsearch-kopf',
                                                                  'cloud-aws'
                                                                ]
