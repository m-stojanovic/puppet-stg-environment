class roles::hadoopmaster {
  include hadoop::roles::dfsmaster
  include hbase::roles::master
}
