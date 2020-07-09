Facter.add(:hostroles) do
  setcode do
    case Facter.value(:fqdn)
      when /^os13azkaban01/ then ['base','dockers','azkaban','hadoopclient','jumphost']
      when /^os13dshdm01/ then ['base','hadoopmaster','hadoop_kinga','hadoopmaster_kinga','resourcemanager','flink_kinga']
      when /^os13dshdm02/ then ['base','hadoopmaster','hadoop_kinga','hadoopmaster_kinga','resourcemanager','historyserver','flink_streaming']
      when /^os13dshdp0[1-6]/ then ['base','hadoopslave','hadoop_hbase','hadoopslave_hbase','hadoop_kinga','hadoopslave_kinga','nodemanager']
      when /^os13dses/ then ['base','elasticsearch']
      when /^os13dsapi01/ then ['base','dsapimaintainer','hadoopclient','hadoop_kinga']
      when /^os13dsapi0[2-3]/ then ['base','dsapi','kafkarest','ha','schemaregistry','nginx','nginx_confluentapp','nginx_dashboard']
      when /^os13dsqueue/ then ['base','kafka']
      when /^os13dshdz/ then ['base','zookeeper_hadoop','dfsjournal']
      when /^os13dsapz/ then ['base','zookeeper_api']
      else 'unknown'
    end
  end
end
