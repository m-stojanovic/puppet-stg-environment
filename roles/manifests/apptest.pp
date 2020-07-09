# class providing test role - testing app,, settings etc on specific hosts.
class roles::apptest{

  include datastore::applications::mobilewrite
  include datastore::applications::kpiread
  
}