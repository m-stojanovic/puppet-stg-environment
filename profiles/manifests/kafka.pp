class profiles::kafka {

  motd::register{ 'profiles::kafka': }

  contain 'kafka'

}  


