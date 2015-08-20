Kafka-HUE: Apache Kafka HUE Application
=======================================

Kafka-HUE is a [HUE](http://www.gethue.com) application to admin and manage a pool of [Apache Kafka](http://kafka.apache.org/) clusters. 

Features
--------
   * Multi cluster support
   * Cluster Overview (Brokers, Topics, Consumers, etc.)
   * Kafka topics administration (add)
   * Custom Dashboards based on Ganglia metrics. Configure Kafka to export JMX metrics to Ganglia and Kafka-HUE will be able to show all of those metrics specifiying them in a config file (metrics.ini).

Requirements
------------
- [HUE 3.7.1](http://www.gethue.com)
- [Ganglia](http://ganglia.sourceforge.net/)
- [Kazoo 2.2.1](http://github.com/python-zk/kazoo)
- [ReportLab 2.X](http://www.reportlab.com/) for Python 2.5 or 2.6. ReportLab 3.X requires Python versions 2.7 or higher.
- [Apache Kafka](http://kafka.apache.org/) local installation is needed. It is not necessary that kafka services are up. It only needs kafka scripts

Main Stack
----------
   * Python 
   * Django 
   * Mako
   * jQuery
   * Bootstrap

Installation
------------
To get the Kafka-HUE app integrated and running in your HUE deployment:

    $ sudo $HUE_HOME/build/env/bin/python $HUE_HOME/build/env/bin/pip install kazoo
    $ git clone https://github.com/keedio/kafka-hue.git
    $ mv kafka-hue/kafka $HUE_HOME/apps
    $ cd $HUE_HOME/apps
    $ sudo ../tools/app_reg/app_reg.py --install kafka --relative-paths
    $ chown -R hue: kafka/

Modify the hue.ini config file as follows and restart HUE. 

HUE.ini Config section
----------------------
Configs needed in hue.ini config file.

    [kafka]

     [[clusters]]

      [[[default]]]
        # Zookeeper ensemble. Comma separated list of Host/Port.
        # e.g. localhost:2181,localhost:2182,localhost:2183
        zk_host_ports=localhost:2181,localhost:2182,localhost:2183
  
        # Path to brokers info in Zookeeper Znode hierarchy
        brokers_path=/brokers/ids
  
        # Path to consumers info in Zookeeper Znode hierarchy
        consumers_path=/consumers

        # Ganglia Server
        # e.g. http://localhost
        ganglia_server=http://localhost

        # Ganglia Data Source
        # e.g. GangliaCluster
        ganglia_data_source=GangliaCluster


Metrics.ini Config file
-----------------------
Metrics example

	[BrokerTopicMetrics.BytesInPerSec]
	key = Count,OneMinuteRate,FiveMinuteRate,FifteenMinuteRate,MeanRate

	[BrokerTopicMetrics.BytesOutPerSec]
	key = Count,OneMinuteRate,FiveMinuteRate,FifteenMinuteRate,MeanRate

	[BrokerTopicMetrics.FailedFetchRequestPerSec]
	key = Count,OneMinuteRate,FiveMinuteRate,FifteenMinuteRate,MeanRate

	[BrokerTopicMetrics.FailedProduceRequestPerSec]
	key = Count,OneMinuteRate,FiveMinuteRate,FifteenMinuteRate,MeanRate

	[BrokerTopicMetrics.MessagesInPerSec]
	key = Count,OneMinuteRate,FiveMinuteRate,FifteenMinuteRate,MeanRate


Compile locales
---------------
To compile the locales:

Set the ROOT variable in the Makefile file pointing to the HUE installation path.

Compile with make.

    $ cd $HUE_HOME/apps/kafka
    $ sudo make compile-locale

Restart HUE.

License
-------
Apache License, Version 2.0
http://www.apache.org/licenses/LICENSE-2.0

--
Daniel Tardón <dtardon@keedio.org>
