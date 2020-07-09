class roles::dsapimaintainer {

  include profiles::firewall
  
  include datastore::applications::userread
  include datastore::applications::userwrite
  include datastore::applications::userreadbatch
  include datastore::applications::userresponseread
  include datastore::applications::userresponsewrite
  include datastore::applications::messagestatsread
  include datastore::applications::mobileresponseread
  include datastore::applications::mobileresponsewrite
  include datastore::applications::relateddataread
  include datastore::applications::relateddatawrite
  include datastore::applications::membershipwrite
  include datastore::applications::dsreader
  include datastore::applications::selectionengine
  include datastore::applications::etlservicemaintainer
  include datastore::applications::relateddatareadbatch
  include datastore::applications::lockingservicequeryserver
  include datastore::applications::schemarepository
  include datastore::applications::smoketestexport
  include datastore::applications::smoketestmember
  include datastore::applications::smoketestrelateddata
  include datastore::applications::smoketeststatistics
  include datastore::applications::smoketestuser
  include datastore::applications::smoketestuserresponse
  include datastore::applications::statscollector
  include datastore::applications::kpiread
  include datastore::applications::mobilewrite
  include datastore::applications::mobileread
  include datastore::applications::metadatawrite
  include datastore::applications::connectwrite
  include filebeat
}
