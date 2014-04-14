Kafka-HUE: Apache Kafka HUE Application
=======================================

Kafka-HUE is a [HUE](http://www.gethue.com) application to admin and manage a pool of [Apache Kafka](http://kafka.apache.org/) clusters. 

Requirements
------------
- [HUE 3.5.0](http://www.gethue.com)
- [Kazoo 1.3.1](http://github.com/python-zk/kazoo)
- [Zope Interface -4.1.1](http://pypi.python.org/pypi/zope.interface/4.1.1)

Main Stack
----------
   * Python 
   * Django 
   * Mako
   * jQuery
   * Bootstrap

Installation
------------
To get the Kafka-HUE app integrated and running in your HUE deployment (assuming hue as administrator user HUE):

    $ git clone http://github.com/danieltardon/kafka-hue.git
    $ mv kafka-hue/kafka $HUE_HOME/apps
    $ cd $HUE_HOME/apps
    $ sudo -E -u hue ../build/env/bin/hue create_desktop_app kafka
    $ sudo -E -u hue ../tools/app_reg/app_reg.py --install kafka --relative-paths

HUE.ini Config section
----------------------
Configs needed in hue.ini config file.

    [kafka]

     [[clusters]]

      [[[default]]]
        # Zookeeper ensemble. Comma separated list of Host/Port.
        # e.g. localhost:2181,localhost:2182,localhost:2183
        zk_host_ports=localhost:2181,localhost:2182,localhost:2183
  
        # The URL of the REST contrib service (required for znode browsing)
        zk_rest_url=http://localhost:9998
  
        # Path to brokers info in Zookeeper Znode hierarchy
        brokers_path=/brokers/ids
  
        # Path to consumers info in Zookeeper Znode hierarchy
        consumers_path=/consumers

License
-------
Apache License, Version 2.0
http://www.apache.org/licenses/LICENSE-2.0

--
Daniel Tardón <dtardon@redoop.org>
