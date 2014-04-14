Changelog
=========

1.0 (14-04-2014)
----------------

Features
********

- Show Apache Kafka Clusters Topology.

- Show Consumers Groups info.

- Show Consumer Group detailed info.

- Show Consumer instance detailed info.

- Show Topics info.

- Show Zookeepers, Brokers, Consumer Groups and Consumers Status.

- Multicluster support. 

Bug Handling
************

- Issue #4: Topics view error when no topics in cluster
- Issue #5: Error 500 when trying to access a Consumer Group detail view w/o consumers active neither topics
- Issue #6: Error when a topic has exactly 1 partition and 1 replica (default by kafka)
