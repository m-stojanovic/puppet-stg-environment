# empty name space to maintain hiera to host connection
class roles::jumphost{

  include 'reporting::reports::datausage'
  include 'reporting::reports::bdapps'

}