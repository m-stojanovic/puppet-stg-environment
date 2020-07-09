class roles::dockers {

  include 'dockers'
  include 'dockers::containers::burrow'
  include 'dockers::containers::kafkamanager'
  include 'dockers::containers::cerebro'
  
  Class['dockers'] -> Class['dockers::containers::burrow'] -> Class['dockers::containers::kafkamanager'] -> Class['dockers::containers::cerebro']
  
}