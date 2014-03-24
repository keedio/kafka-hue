#!/usr/bin/env python
# Licensed to Cloudera, Inc. under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  Cloudera, Inc. licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from desktop.lib.django_util import render
import datetime
from kazoo.client import KazooClient, KazooState
import json
from kafka.conf import CLUSTERS
from kafka.utils import get_cluster_or_404


# ZK_HOST_PORTS="hdpnode01:2181,hdpnode02:2181,hdpnode03:2181"
# BROKERS_PATH = "/brokers/ids"
# CONSUMERS_PATH = "/consumers"

def my_listener(state):
    if state == KazooState.LOST:
        # Register somewhere that the session was lost
        print("I'm Lost")
    elif state == KazooState.SUSPENDED:
        # Handle being disconnected from Zookeeper
        print("I'm Suspended")
    else:
        # Handle being connected/reconnected to Zookeeper
        print("I'm Connected/reconnected")

def _get_topology():
	topology = CLUSTERS.get()
	clusters = []
	for cluster in topology:
		brokers = _get_brokers(cluster)
		consumer_groups = _get_consumer_groups(cluster)
		c = {'cluster':cluster,'brokers':brokers,'consumer_groups':consumer_groups}
		clusters.append(c)
	return clusters

def _get_brokers(cluster):
    brokers=[]
    zk = KazooClient(hosts=CLUSTERS[cluster].ZK_HOST_PORTS.get())
    zk.add_listener(my_listener)
    zk.start()
    children = zk.get_children(CLUSTERS[cluster].BROKERS_PATH.get())
    for child in children:
        path = CLUSTERS[cluster].BROKERS_PATH.get() + "/" + child
        data, stat = zk.get(path)
        d=json.loads(data)
        broker = {'host':d['host'],'port':d['port']}
        brokers.append(broker)
    zk.stop()
    return brokers

def _get_consumer_groups(cluster):
	zk = KazooClient(hosts=CLUSTERS[cluster].ZK_HOST_PORTS.get())
	zk.add_listener(my_listener)
	zk.start()
	consumer_groups = zk.get_children(CLUSTERS[cluster].CONSUMERS_PATH.get())
	zk.stop()
	return consumer_groups


def index(request):
	# zk = KazooClient(hosts=ZK_HOST_PORTS.get())
	# zk.add_listener(my_listener)
	# zk.start()
	#clusters = CLUSTERS.get()
	# for cluster in clusters:
	# 	consumers = _get_consumers(zk)
	# 	brokers = _get_brokers(zk)
	# zk.stop()
	# return render('index.mako', request, dict(consumers=consumers,brokers=brokers))

	return render('index.mako', request, {'clusters':_get_topology()})
