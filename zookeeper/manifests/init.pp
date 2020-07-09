class zookeeper{

  require 'java'

  contain 'zookeeper::install'
  contain 'zookeeper::config'
  
  Class['zookeeper::install'] -> Class['zookeeper::config']

}
