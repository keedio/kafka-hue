Changelog
=========

4.0.0 (01-09-2015)
----------------

Features
********

- Support for HUE 3.8 or higher.
- Config validator at HUE start.

3.0.0 (20-08-2015)
----------------

Features
********

- Kafka topics administration (add).
- Kazoo Higher Level Zookeeper Client usage.

2.1.0 (23-06-2015)
----------------

Features
********

- Export dataTables in JSON, XLS, CSV and PDF formats.

2.0.0 (20-02-2015)
----------------

Features
********

- Zookeeper REST server API usage. 
- Custom Dashboard based on Kafka JMX metrics published in Ganglia

Bug Handling
************
- Issue #18: Justify Right for "Search" DataTable Box
- Issue #21: Show X-Axis Legend
- Issue #23: Header don't show name correctly
- Issue #24: Block submit button while not show graphics in dashboard.
- Issue #25: Fix internalization messages
- Issue #26: Format/Size in Y-Axis in dashboard
- Issue #28: Error in "FifteenMinuteRate Graph" in date format
- Issue #29: Error in dashboard when Ganglia URL is not correct.
- Issue #30: In dashboard, filter "All topics" not working correctly
- Issue #32: Fix compile locales
- Issue #33: Ganglia URL incorrect
- Issue #34: Tests - Fix compile locales
- Issue #38: Include name of Ganglia Cluster in Hue.ini


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
