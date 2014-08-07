#!/usr/bin/env python
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# http:# www.apache.org/licenses/LICENSE-2.0
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
from kazoo.exceptions import NoNodeError



def my_listener(state):
    if state == KazooState.LOST:
        # Register somewhere that the session was lost
    elif state == KazooState.SUSPENDED:
        # Handle being disconnected from Zookeeper
    else:
        # Handle being connected/reconnected to Zookeeper

def _get_topology():
	topology = CLUSTERS.get()
	clusters = []
	for cluster in topology:
		zk = KazooClient(hosts=CLUSTERS[cluster].ZK_HOST_PORTS.get())
		zk.add_listener(my_listener)
		zk.start()
		brokers = _get_brokers(zk,cluster)
		consumer_groups = _get_consumer_groups(zk,cluster)
		consumer_groups_status = {} # 0 = offline, (not 0) =  online
		for consumer_group in consumer_groups:
			consumers_path = CLUSTERS[cluster].CONSUMERS_PATH.get() + "/" + consumer_group + "/ids"
			try:
				consumers = zk.get_children(consumers_path)
			except NoNodeError:
				consumer_groups_status[consumer_group]=0 # 0 = offline
			else:
				consumer_groups_status[consumer_group]=len(consumers) # (not 0) =  online
		c = {'cluster':get_cluster_or_404(id=cluster),'brokers':brokers,'consumer_groups':consumer_groups,'consumer_groups_status':consumer_groups_status}
		clusters.append(c)
		zk.stop()
	return clusters

def _get_cluster_topology(cluster):
	zk = KazooClient(hosts=cluster['zk_host_ports'])
	zk.add_listener(my_listener)
	zk.start()
	brokers = _get_brokers(zk,cluster['id'])
	consumer_groups = _get_consumer_groups(zk,cluster['id'])
	consumer_groups_status = {} # 0 = offline, (not 0) =  online
	for consumer_group in consumer_groups:
		consumers_path = cluster['consumers_path'] + "/" + consumer_group + "/ids"
		try:
			consumers = zk.get_children(consumers_path)
		except NoNodeError:
			consumer_groups_status[consumer_group]=0 # 0 = offline
		else:
			consumer_groups_status[consumer_group]=len(consumers) # (not 0) =  online

	cluster_topology = {'cluster':cluster,'brokers':brokers,'consumer_groups':consumer_groups, 'consumer_groups_status':consumer_groups_status}
	zk.stop()
	return cluster_topology

def _get_brokers(zk,cluster):
    brokers=[]
    children = zk.get_children(CLUSTERS[cluster].BROKERS_PATH.get())
    for child in children:
        path = CLUSTERS[cluster].BROKERS_PATH.get() + "/" + child
        data, stat = zk.get(path)
        d=json.loads(data)
        broker = {'host':d['host'],'port':d['port'], 'id':child}
        brokers.append(broker)
    return brokers

def _get_consumer_groups(zk, cluster):
	consumer_groups = zk.get_children(CLUSTERS[cluster].CONSUMERS_PATH.get())
	return consumer_groups

def _get_topics(cluster):
	zk = KazooClient(hosts=cluster['zk_host_ports'])
	zk.add_listener(my_listener)
	zk.start()
	topic_list = []
	try:
		topics = zk.get_children(cluster['topics_path'])
	except NoNodeError:
		return topic_list
	else:
		for topic in topics:
			t = {'id':topic}
			topic_path = cluster['topics_path'] + "/" + topic
			data, stat = zk.get(topic_path)
			d=json.loads(data)
			t['topic_partitions_data']=d['partitions']
			
			partitions_path = topic_path + "/partitions"
			partitions = zk.get_children(partitions_path)
			t['partitions']=partitions
			tpp = {}
			p =[]
			for partition in partitions:
				tps = {}
				p.append(partition.encode('ascii'))
				partition_path = partitions_path + "/" + partition + "/state"
				data, stat = zk.get(partition_path)
				d = json.loads(data)
				tps['isr'] = d['isr']
				tps['leader'] = d['leader']
				tpp[partition.encode('ascii')]=tps
			t['partitions']=p	
			t['topic_partitions_states']=tpp
			topic_list.append(t)
	zk.stop()
	return topic_list

def _get_consumers(cluster):
	zk = KazooClient(hosts=cluster['zk_host_ports'])
	zk.add_listener(my_listener)
	zk.start()
	groups = _get_consumer_groups(zk,cluster['id'])
	consumer_groups = []
	for group in groups:
		consumer_groups.append(_get_consumer_group(zk=zk,cluster=cluster,group_id=group))
	zk.stop()
	return consumer_groups

def _get_offsets(zk, cluster, group):
    offsets_path = cluster['consumers_path'] + "/" + group + "/offsets"
    offsets = []
    try:
        topics = zk.get_children(offsets_path)
    except NoNodeError:
        return offsets 
    else:
        for topic in topics:
            topic_offset = {'topic':topic.encode('ascii')}            
            topic_partitions_path = offsets_path + "/" + topic
            topic_partitions = zk.get_children(topic_partitions_path)
            partition_offset = {}
            for topic_partition in topic_partitions:
                data, stat = zk.get(topic_partitions_path+"/"+topic_partition)
                partition_offset[topic_partition]= data
            topic_offset['offsets']=partition_offset
            offsets.append(topic_offset)
    return offsets

def _get_owners(zk, cluster, group):
    owners_path = cluster['consumers_path'] + "/" + group + "/owners"
    owners = []
    try:
        topics = zk.get_children(owners_path)
    except NoNodeError:
    	return owners
    else:
        for topic in topics:
            topic_owner = {'topic':topic}
            topic_partitions_path = owners_path + "/" + topic
            topic_partitions = zk.get_children(topic_partitions_path)
            partition_owner = {}
            for topic_partition in topic_partitions:
                data, stat = zk.get(topic_partitions_path+"/"+topic_partition)
                partition_owner[topic_partition]=data
            topic_owner['owners']=partition_owner
            owners.append(topic_owner)
    return owners

def _get_consumer_group(zk,cluster,group_id):
	consumer_group = {'id':group_id.encode('ascii')}
	consumers_path = cluster['consumers_path'] + "/" + group_id + "/ids"
	try:
		consumers = zk.get_children(consumers_path)
	except NoNodeError:
		consumer_group['consumers']=""
	else:
		#consumer_group['consumers']=consumers
		consumer_subscription = {}
		for consumer in consumers:
			data,stat = zk.get(consumers_path+"/"+consumer)
			d = json.loads(data)
			consumer_subscription[consumer]= d['subscription']
		consumer_group['consumers']=consumer_subscription
	consumer_group['offsets']=_get_offsets(zk=zk, cluster=cluster, group=group_id)
	consumer_group['owners']=_get_owners(zk=zk, cluster=cluster, group=group_id)
	return consumer_group



def index(request):
	# return by default the first cluster in the hue.ini config file
	return render('index.mako', request, {'cluster':_get_topology()[0]})

def topics(request, cluster_id):
	cluster = get_cluster_or_404(id=cluster_id)
	return render('topics.mako', request, {'cluster': cluster, 'topics':_get_topics(cluster)})

def cluster(request, cluster_id):
	c = get_cluster_or_404(id=cluster_id)
	cluster = _get_cluster_topology(cluster=c)
	return render('cluster.mako', request, {'cluster':cluster})

def consumer_groups(request, cluster_id):	
	cluster = get_cluster_or_404(id=cluster_id)
	return render('consumer_groups.mako', request, {'cluster': cluster, 'consumers_groups':_get_consumers(cluster)})

def consumer_group(request, cluster_id, group_id):	
	cluster = get_cluster_or_404(id=cluster_id)
	zk = KazooClient(hosts=cluster['zk_host_ports'])
	zk.add_listener(my_listener)
	zk.start()
	consumer_group = _get_consumer_group(zk=zk,cluster=cluster,group_id=group_id)
	zk.stop()
	return render('consumer_group.mako', request, {'cluster': cluster, 'consumer_group':consumer_group})


