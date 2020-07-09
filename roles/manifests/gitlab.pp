class roles::gitlab {

  motd::register { 'roles::gitlab': }

  include 'gitlab'
  
}