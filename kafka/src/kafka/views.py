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
	""" Method to get the entire Kafka clusters (defined in hue.ini) topology """
	topology = CLUSTERS.get()
	clusters = []
	for c in topology:
		cluster = get_cluster_or_404(c)
		try:
			zk = ZooKeeper(cluster['zk_rest_url'])
			brokers = _get_brokers(zk,cluster)
			consumer_groups = _get_consumer_groups(zk,cluster)
			consumer_groups_status = {} 
			for consumer_group in consumer_groups:
				# 0 = offline, (not 0) =  online
				consumer_groups_status[consumer_group] = zk.get(cluster['consumers_path'] + "/" + consumer_group + "/ids")['numChildren']
			
			c = {'cluster':cluster,'brokers':brokers,'consumer_groups':consumer_groups,'consumer_groups_status':consumer_groups_status, 'error':0}
			
		except ZooKeeper.RESTError:
			c = {'cluster':cluster,'brokers':[],'consumer_groups':[],'consumer_groups_status':[], 'error':1}
		clusters.append(c)
	return clusters

def _get_cluster_topology(cluster):
	""" Method to get the topology of a given cluster """
	try:
		zk = ZooKeeper(cluster['zk_rest_url'])
		brokers = _get_brokers(zk,cluster)
		consumer_groups = _get_consumer_groups(zk,cluster)
		consumer_groups_status = {} 
		for consumer_group in consumer_groups:
			# 0 = offline, (not 0) =  online
			consumer_groups_status[consumer_group] = zk.get(cluster['consumers_path'] + "/" + consumer_group + "/ids")['numChildren']

		cluster_topology = {'cluster':cluster,'brokers':brokers,'consumer_groups':consumer_groups, 'consumer_groups_status':consumer_groups_status,'error':0}
	except ZooKeeper.RESTError:
		cluster_topology = {'cluster':cluster,'brokers':[],'consumer_groups':[], 'consumer_groups_status':[],'error':1}
	return cluster_topology

def _get_brokers(zk,cluster):
	""" Method to get the brokers of a given cluster """
	brokers=[]
	children = sorted(zk.get_children_paths(cluster['brokers_path']))
	for child in children:
		path = cluster['brokers_path'] + "/" + child
		data = json.loads(base64.b64decode(zk.get(path)['data64']))
		broker = {'host':data['host'],'port':data['port'], 'id':child}
		brokers.append(broker)
	return brokers

def _get_consumer_groups(zk, cluster):
	""" Method to get the consumers groups ids of a given cluster """
	consumer_groups =[]
	try:
		consumer_groups = sorted(zk.get_children_paths(cluster['consumers_path']))
	except ZooKeeper.NotFound:
		return consumer_groups
	return consumer_groups

def _get_topics(cluster):
	""" Method to get the topic list of a given cluster """

	topic_list = []
	error = 0
	try:
		zk = ZooKeeper(cluster['zk_rest_url'])
		topics = zk.get_children_paths(cluster['topics_path'])
	except ZooKeeper.RESTError:
		error = 1
		return topic_list, error
	except ZooKeeper.NotFound:
		return topic_list, error
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
	return topic_list, error 

def _get_consumers(cluster):
	""" Method to get the consumers of a given cluster """
	consumer_groups = []
	error=0
	try:
		zk = ZooKeeper(cluster['zk_rest_url'])
		groups = _get_consumer_groups(zk,cluster)
		for group in groups:
			consumer_groups.append(_get_consumer_group(zk=zk,cluster=cluster,group_id=group))
	except ZooKeeper.RESTError:
		error = 1
	return consumer_groups,error

def _get_offsets(zk, cluster, group):
	""" Method to get the offsets of a given cluster and consumers group """
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
	""" Method to get the partitions owners of a given cluster and consumers group """
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
	""" Method to get the consumers group info of a given cluster and consumers gruoup id """
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
	""" Main view. Returns the topology of every kafka cluster defined in the hue.ini file """
	return render('index.mako', request, {'clusters':_get_topology()})

def topics(request, cluster_id):
	""" Topics view. Returns the topics list of a given cluster """
	cluster = get_cluster_or_404(id=cluster_id)
	topics,error = _get_topics(cluster)
	return render('topics.mako', request, {'cluster': cluster, 'topics':topics, 'error':error})

def cluster(request, cluster_id):
	""" Cluster detail view. Returns the cluster detailed topology """
	c = get_cluster_or_404(id=cluster_id)
	cluster = _get_cluster_topology(cluster=c)
	return render('cluster.mako', request, {'cluster':cluster})

def consumer_groups(request, cluster_id):	
	""" Consumers groups view. Returns the consumers groups list and their info of a given cluster """
	cluster = get_cluster_or_404(id=cluster_id)
	consumers_groups, error = _get_consumers(cluster)
	return render('consumer_groups.mako', request, {'cluster': cluster, 'consumers_groups':consumers_groups, 'error':error})

def consumer_group(request, cluster_id, group_id):	
	""" Consumers Group detail view. Returns the detailed view of a given consumers group """
	cluster = get_cluster_or_404(id=cluster_id)
	consumer_group = {}
	error = 0
	try:
		zk = ZooKeeper(cluster['zk_rest_url'])
		consumer_group = _get_consumer_group(zk=zk,cluster=cluster,group_id=group_id)
	except ZooKeeper.RESTError:
		error = 1
	return render('consumer_group.mako', request, {'cluster': cluster, 'consumer_group':consumer_group, 'error':error})



