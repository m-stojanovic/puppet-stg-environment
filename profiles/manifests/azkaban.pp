class profiles::azkaban {

  motd::register { 'profiles::azkaban':}

  contain '::azkaban::executor'
  contain '::azkaban::web'
  contain '::azkaban::cli'

  Class['::azkaban::executor'] -> Class['::azkaban::web'] -> Class['::azkaban::cli']

}
