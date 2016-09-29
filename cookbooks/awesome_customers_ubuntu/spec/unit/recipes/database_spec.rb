#
# Cookbook Name:: awesome_customers_ubuntu
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'

describe 'awesome_customers_ubuntu::database' do
  context 'When all attributes are default, on an unspecified platform' do
    before do
      stub_command("mysql -h fake_host -u fake_admin -pfake_admin_password -D fake_database -e 'describe customers;'").and_return(false)
    end

    let(:create_tables_script_path) { File.join(Chef::Config[:file_cache_path], 'create-tables.sql') }

    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '14.04') do |node|
        node.override['awesome_customers_ubuntu']['database']['root_password'] = 'fake_root_password'
        node.override['awesome_customers_ubuntu']['database']['admin_password'] = 'fake_admin_password'
        node.override['awesome_customers_ubuntu']['database']['dbname'] = 'fake_database'
        node.override['awesome_customers_ubuntu']['database']['host'] = 'fake_host'
        node.override['awesome_customers_ubuntu']['database']['root_username'] = 'fake_root'
        node.override['awesome_customers_ubuntu']['database']['admin_username'] = 'fake_admin'
      end.converge(described_recipe)
    end

    let(:connection_info) do
      { host: 'fake_host', username: 'fake_root', password: 'fake_root_password' }
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end

    it 'sets the MySQL service root password'  do
       expect(chef_run).to start_mysql_service('default')
    .with(initial_root_password: 'fake_root_password')
    end

    it 'should run the MySQL server ' do
       expect(chef_run).to create_mysql_service('default')
    .with(initial_root_password: 'fake_root_password')
    end

    it 'creates the database instance' do
      expect(chef_run).to create_mysql_database('fake_database')
        .with(connection: connection_info)
    end

     it 'creates the database user' do
      expect(chef_run).to create_mysql_database_user('fake_admin')
        .with(connection: connection_info, password: 'fake_admin_password', database_name: 'fake_database', host: 'fake_host')
    end

     it 'seeds the database with a table and test data' do
       expect(chef_run).to run_execute('initialize fake_database database')
         .with(command: "mysql -h fake_host -u fake_admin -pfake_admin_password -D fake_database < #{create_tables_script_path}")
     end
  end
end
