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
import json
from kafka.conf import CLUSTERS
from kafka.utils import get_cluster_or_404
from kafka.rest import ZooKeeper
import base64


def _get_topology():
	topology = CLUSTERS.get()
	clusters = []
	for c in topology:
		cluster = get_cluster_or_404(c)
		zk = ZooKeeper(cluster['zk_rest_url'])
		brokers = _get_brokers(zk,cluster)
		consumer_groups = _get_consumer_groups(zk,cluster)
		consumer_groups_status = {} # 0 = offline, (not 0) =  online
		for consumer_group in consumer_groups:
			consumers_path = cluster['consumers_path'] + "/" + consumer_group + "/ids"
			consumer_groups_status[consumer_group] = zk.get(consumers_path)['numChildren']
		c = {'cluster':cluster,'brokers':brokers,'consumer_groups':consumer_groups,'consumer_groups_status':consumer_groups_status}
		clusters.append(c)
	return clusters

def _get_cluster_topology(cluster):
	zk = ZooKeeper(cluster['zk_rest_url'])
	brokers = _get_brokers(zk,cluster)
	consumer_groups = _get_consumer_groups(zk,cluster)
	consumer_groups_status = {} # 0 = offline, (not 0) =  online
	for consumer_group in consumer_groups:
		consumers_path = cluster['consumers_path'] + "/" + consumer_group + "/ids"
		consumer_groups_status[consumer_group] = zk.get(consumers_path)['numChildren']

	cluster_topology = {'cluster':cluster,'brokers':brokers,'consumer_groups':consumer_groups, 'consumer_groups_status':consumer_groups_status}
	return cluster_topology

def _get_brokers(zk,cluster):
    brokers=[]
    children = sorted(zk.get_children_paths(cluster['brokers_path']))
    for child in children:
        path = cluster['brokers_path'] + "/" + child
        data = json.loads(base64.b64decode(zk.get(path)['data64']))
        broker = {'host':data['host'],'port':data['port'], 'id':child}
        brokers.append(broker)
    return brokers

def _get_consumer_groups(zk, cluster):
	consumer_groups =[]
	try:
		consumer_groups = sorted(zk.get_children_paths(cluster['consumers_path']))
	except ZooKeeper.NotFound:
		return consumer_groups
	return consumer_groups

def _get_topics(cluster):
	zk = ZooKeeper(cluster['zk_rest_url'])
	topic_list = []
	try:
		topics = zk.get_children_paths(cluster['topics_path'])
	except ZooKeeper.NotFound:
		return topic_list
	else:
		for topic in topics:
			t = {'id':topic}
			topic_path = cluster['topics_path'] + "/" + topic

			data = json.loads(base64.b64decode(zk.get(topic_path)['data64']))

			t['topic_partitions_data']=data['partitions']
			
			partitions_path = topic_path + "/partitions"
			partitions = zk.get_children_paths(partitions_path)
			t['partitions']=partitions
			tpp = {}
			p =[]
			for partition in partitions:
				tps = {}
				p.append(partition.encode('ascii'))
				partition_path = partitions_path + "/" + partition + "/state"
				data = json.loads(base64.b64decode(zk.get(partition_path)['data64']))
				tps['isr'] = data['isr']
				tps['leader'] = data['leader']
				tpp[partition.encode('ascii')]=tps
			t['partitions']=p	
			t['topic_partitions_states']=tpp
			topic_list.append(t)
	return topic_list

def _get_consumers(cluster):
	zk = ZooKeeper(cluster['zk_rest_url'])
	groups = _get_consumer_groups(zk,cluster)

	consumer_groups = []
	for group in groups:
		consumer_groups.append(_get_consumer_group(zk=zk,cluster=cluster,group_id=group))
	return consumer_groups

def _get_offsets(zk, cluster, group):
    offsets_path = cluster['consumers_path'] + "/" + group + "/offsets"
    offsets = []
    try:
        topics = zk.get_children_paths(offsets_path)
    except ZooKeeper.NotFound:
        return offsets 
    else:
        for topic in topics:
            topic_offset = {'topic':topic.encode('ascii')}            
            topic_partitions_path = offsets_path + "/" + topic
            topic_partitions = zk.get_children_paths(topic_partitions_path)
            partition_offset = {}
            for topic_partition in topic_partitions:

               	data = json.loads(base64.b64decode(zk.get(topic_partitions_path+"/"+topic_partition)['data64']))

                partition_offset[topic_partition]= data
            topic_offset['offsets']=partition_offset
            offsets.append(topic_offset)
    return offsets

def _get_owners(zk, cluster, group):
    owners_path = cluster['consumers_path'] + "/" + group + "/owners"
    owners = []
    try:
        topics = zk.get_children_paths(owners_path)
    except ZooKeeper.NotFound:
    	return owners
    else:
        for topic in topics:
            topic_owner = {'topic':topic}
            topic_partitions_path = owners_path + "/" + topic
            topic_partitions = zk.get_children_paths(topic_partitions_path)
            partition_owner = {}
            for topic_partition in topic_partitions:
                partition_owner[topic_partition]= base64.b64decode(zk.get(topic_partitions_path+"/"+topic_partition)['data64'])
            topic_owner['owners']=partition_owner
            owners.append(topic_owner)
    return owners

def _get_consumer_group(zk,cluster,group_id):
	consumer_group = {'id':group_id.encode('ascii')}
	consumers_path = cluster['consumers_path'] + "/" + group_id + "/ids"
	try:
		consumers = sorted(zk.get_children_paths(consumers_path))

	except ZooKeeper.NotFound:
		consumer_group['consumers']=""
	else:
		consumer_subscription = {}
		for consumer in consumers:
			data = json.loads(base64.b64decode(zk.get(consumers_path+"/"+consumer)['data64']))
			consumer_subscription[consumer]= data['subscription']
		consumer_group['consumers']=consumer_subscription
	consumer_group['offsets']=_get_offsets(zk=zk, cluster=cluster, group=group_id)
	consumer_group['owners']=_get_owners(zk=zk, cluster=cluster, group=group_id)
	return consumer_group



def index(request):
	# return by default the first cluster in the hue.ini config file
	return render('index.mako', request, {'clusters':_get_topology()})

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
	zk = ZooKeeper(cluster['zk_rest_url'])
	consumer_group = _get_consumer_group(zk=zk,cluster=cluster,group_id=group_id)
	return render('consumer_group.mako', request, {'cluster': cluster, 'consumer_group':consumer_group})



