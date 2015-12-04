require 'spec_helper'

describe 'resource_tree', :type => :class do
  #let(:default_facts) do
  #  {
  #    :concat_basedir => '/dne',
  #    :ipaddress      => '10.10.10.10'
  #  }
  #end
  
  #it { should compile }
  it { should contain_class('resource_tree')}
  
  context 'with static content' do
    let(:params) { 
      {
        :collections => {
          "static_content" => {
            "file" => {
              "/tmp/date_test" => {
                "content" => Time.now.day
              }
            }
          }
        }, 
        :apply => ["static_content"]
      }
    }

    it 'should contain a file with the current day number' do
      should contain_file('/tmp/date_test') \
        .with_content(Time.now.day)
    end
  end
  
  context 'with dynamic content' do
    let(:params) {
      {
        :collections => {
          "dynamic_content" => {
            "file" => {
              "/tmp/date_test" => "{ 'content' => Time.now.day }"
            }
          }
        },
        :apply => ["dynamic_content"]
      }
    }

    it 'should contain a file with the current day number' do
      should contain_file('/tmp/date_test') \
        .with_content(Time.now.day)
    end
  end
  
  context 'with dynamic resources' do
    let(:params) {
      {
        :collections => {
          "dynamic_resources" => %q({
              'file' => Hash[(1..5).map {|n|
                [
                  "/tmp/test-file-" + n.to_s,
                  { "content" => rand(500).to_s }
                ]
              }]
            })
        },
        :apply => ["dynamic_resources"]
      }
    }

    it 'should contain 5 files' do
      #Puppet::Util::Log.level = :debug
      #Puppet::Util::Log.newdestination(:console)
      
      should contain_file('/tmp/test-file-1')
      should contain_file('/tmp/test-file-2')
      should contain_file('/tmp/test-file-3')
      should contain_file('/tmp/test-file-4')
      should contain_file('/tmp/test-file-5')
    end
  end
  
  context 'with dynamic resource' do
    let(:params) {
      {
        :collections => {
          "dynamic_resource" => {
            "host" => %q(
              Hash[(1..5).map {|n|
                [
                  "test-node-0" + n.to_s,
                  {"ip" => "192.168.1." + n.to_s, "ensure" => "present" }
                ]
              }]
            )
          }
        },
        :apply => ["dynamic_resource"]
      }
    }

    it 'should contain 5 hosts entries' do
      should contain_host('test-node-01') \
        .with({ 'ip' => '192.168.1.1', 'ensure' => 'present' })
      should contain_host('test-node-02') \
        .with({ 'ip' => '192.168.1.2', 'ensure' => 'present' })
      should contain_host('test-node-03') \
        .with({ 'ip' => '192.168.1.3', 'ensure' => 'present' })
      should contain_host('test-node-04') \
        .with({ 'ip' => '192.168.1.4', 'ensure' => 'present' })
      should contain_host('test-node-05') \
        .with({ 'ip' => '192.168.1.5', 'ensure' => 'present' })
    end
  end
  
  context 'with dynamic resources and dependencies' do
    let(:params) {
      {
        :collections => {
          "dynamic_resources" => {
            'file' => {
              '/tmp/test' => {
                'ensure' => 'directory',
                'rt_resources' => %q({
                  'file' => Hash[(1..5).map {|n|
                     [
                       "/tmp/test/test-file-" + n.to_s,
                       { "content" => rand(500).to_s }
                     ]
                   }]
                })
              }
            }
          }
        },
        :apply => ["dynamic_resources"]
      }
    }

    it 'should contain 5 files dependent on 1 file' do
      should contain_file('/tmp/test').that_comes_before('Resource_tree::Placeholder[file-/tmp/test]')
      should contain_resource_tree__resource('file-/tmp/test/test-file-1').that_requires('Resource_tree::Placeholder[file-/tmp/test]')
      should contain_resource_tree__resource('file-/tmp/test/test-file-2').that_requires('Resource_tree::Placeholder[file-/tmp/test]')
      should contain_resource_tree__resource('file-/tmp/test/test-file-3').that_requires('Resource_tree::Placeholder[file-/tmp/test]')
      should contain_resource_tree__resource('file-/tmp/test/test-file-4').that_requires('Resource_tree::Placeholder[file-/tmp/test]')
      should contain_resource_tree__resource('file-/tmp/test/test-file-5').that_requires('Resource_tree::Placeholder[file-/tmp/test]')
    end
  end
  
  context 'with multiple collections' do
    let(:params) {
      {
        :collections => {
          "static_content1" => {
            "file" => {
              "/tmp/date_test1" => {
                "content" => Time.now.day
              }
            }
          },
          "static_content2" => {
            "file" => {
              "/tmp/date_test2" => {
                "content" => Time.now.day
              }
            }
          }
        },
        :apply => ["static_content1", "static_content2"]
      }
    }

    it 'should contain two files with the current day number' do
      should contain_file('/tmp/date_test1') \
        .with_content(Time.now.day)
      should contain_file('/tmp/date_test2') \
        .with_content(Time.now.day)
    end
  end
end