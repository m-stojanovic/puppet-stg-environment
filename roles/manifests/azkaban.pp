class roles::azkaban{
  include 'azkaban'
  include 'azkaban::config'
  include 'azkaban::tools::speedoffsetloader'
  include 'azkaban::tools::speedoffsetwatcher'

  Class['azkaban'] -> Class['azkaban::config']
  
}
