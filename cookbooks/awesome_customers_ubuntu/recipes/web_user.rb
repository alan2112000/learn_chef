group node['awesome_customers_ubuntu']['group']

user node['awesome_customers_ubuntu']['user'] do
  group node['awesome_customers_ubuntu']['group']
  system true
  shell '/bin/bash'
end


