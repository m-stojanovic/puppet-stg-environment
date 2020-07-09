# es - elasticsearch module

#### Table of Contents

1. [Description](#description)
2. [WARNING](#warning)
1. [Setup - The basics of getting started with elasticsearch](#setup)
    * [What elasticsearch affects](#what-elasticsearch-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with elasticsearch](#beginning-with-elasticsearch)

## Description

Create and run elastic search docker images. 

Currently functionality does not allow to confogure physical hosts.

## WARNING

This module contain modified pipework script https://github.com/jpetazzo/pipework.
Due to the nature of systemd we cannot define custom exit codes so all operations returning 1
but with informative / correct status had been modified to 0.

Module creates additional service of oneshot type. Since puppetlabs docker module does not allow
for running command after container is started and we use pipeworks to expose network systemd unit
prepared by docker module will not allow for easy restart of separate container.
Separate service is depended and required by docker container service and will run 10 secosnds
after container start.

## Setup

### What elasticsearch affects **OPTIONAL**

Requires:
  - puppetlabs/docker
  - puppetlabs/firewall
  - https://gitlab01.muc.ecircle.de/puppetmaster_puppet5/bigdata-motd


### Setup Requirements **OPTIONAL**

Module does not contain any default values.

Following has to be provided in hiera (keep in mind that this may change over time):
  - cluster_name - name of ES cluster
  - unicast_hosts - self explanatory
  - logs_path - path to es logs
  - data_path - standard data path mounts

Additionally to use es::docker module:
  - gateway - gateway address for pipework script (ussually host local network gateway)
  - definition of image as per example below(pls note that es::docker::<docker engine hostname>: is required option - if lookup will not find it then puppet will fail.
    Any number of instances (as es1 may be defined. Name of instance will be hostname-instancename)

        es::docker::gateway: '192.168.138.1'
        es::docker::os13dses01:
          es1:
            d_image: 'docker-public.muc.domeus.com/devops/ds-es-node-v6:201805021542' - name of image
            d_volumes: [ '/data1:/data1','/data2:/data2' ] - volumes to mouns
            d_ipaddr: '192.168.139.101' - ip address of image used by pipework script
            d_path: '/data1/es-data,/data2/es-data' - path to data for image
            heapsizemb: 8g - heap size for elastic search java
            is_master: true - if node is master
            is_node: true - if node is data node
            auto_create_index: false - auto creating index

