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
import json
from kafka.conf import CLUSTERS
from kafka.utils import get_cluster_or_404
from kafka.rest import ZooKeeper
import base64
from kafka import settings
import requests
import ConfigParser
from django.http import HttpResponse


METRICS_INI = settings.METRICS_INI

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

def _get_json(psUrl):
	rJSON = requests.get(psUrl)
	jsonObject = rJSON.json()      

	try:
		if len(jsonObject) > 0:
			return jsonObject
		else:
			return []
	except:
		return []    

def _get_dumps(psObject):    
	jsonDumps = json.dumps(psObject).replace("\\", "\\\\")
	return jsonDumps

def _get_sections_ini():
	Config = ConfigParser.ConfigParser() 
	Config.read(METRICS_INI)

	try:
		return Config.sections()
	except ZooKeeper.NotFound:
		return ""

def _get_options_ini(section):
	dict = []
	Config = ConfigParser.ConfigParser() 
	Config.read(METRICS_INI)
	options = Config.options(section)

	for option in options:
		try:
			dict = Config.get(section, option)
		except:
			print("exception on %s!" % option)
			dict = []

	return dict

def _get_json_type(request, cluster_id, type):
	data = []
	try:	
		cluster = get_cluster_or_404(id=cluster_id)

		if (type == "broker"):
			zk = ZooKeeper(cluster['zk_rest_url'])
			brokers = _get_brokers(zk,cluster)
			for broker in brokers:
				data.append(broker['host'])
		if (type == "topic"):
			topics, error_zk_topics = _get_topics(cluster)
			for topic in topics:
				data.append(topic['id'])
		if (type == "metric"):
			data = _get_sections_ini()
	except ZooKeeper.RESTError:
		error_zk_brokers = 1

	return HttpResponse(_get_dumps(data), content_type = "application/json")

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

def dashboard(request, cluster_id):
	aURL = []
	aMetrics = []
	aOptions = ""
	sHost = ""
	sTopic = ""
	sMetric = ""
	sMetricComplete = ""
	sGranularity = ""
	sDataSource = ""

	cluster = get_cluster_or_404(id=cluster_id)
	topics, error_zk_topics = _get_topics(cluster)
	
	error_zk_brokers = 0
	brokers=[]

	try:	
		zk = ZooKeeper(cluster['zk_rest_url'])
		brokers = _get_brokers(zk,cluster)
	except ZooKeeper.RESTError:
		error_zk_brokers = 1

	sections = _get_sections_ini()
	
	if request.method == 'POST' and request.is_ajax():
		sHost = request.POST['txtHost']
		sTopic = request.POST['txtTopic']	
		sMetric = request.POST['txtMetric']        
		sGranularity = request.POST['txtGranularity']
		aOptions = _get_options_ini(sMetric)
		aMetric = sMetric.split(".")
		sTopic = "AllTopics" if sTopic == "*" else sTopic + "-"
		sMetricComplete = aMetric[0] + "." + sTopic + aMetric[1]
        
		for element in aOptions.split(","):
			aMetrics = aMetrics + [sMetricComplete + "." + element]

		sDataSource = cluster['ganglia_data_source'].replace(" ", "+")

		for metric in aMetrics:
			aURL = aURL + [cluster['ganglia_server'] + "/ganglia/graph.php?" + "r=" + sGranularity + "&c=" + sDataSource + "&h=" + sHost + "&m=" + metric + "&json=1"]

		data = {}
		data['sMetric'] = sMetricComplete
		data['sGraphs'] = aOptions
		data['sGranularity'] = sGranularity
		data['jsonDumps0'] =  _get_dumps(_get_json(aURL[0]))
		data['jsonDumps1'] =  _get_dumps(_get_json(aURL[1]))
		data['jsonDumps2'] =  _get_dumps(_get_json(aURL[2]))
		data['jsonDumps3'] =  _get_dumps(_get_json(aURL[3]))
		data['jsonDumps4'] =  _get_dumps(_get_json(aURL[4]))
		data['status'] = 0

		return HttpResponse(json.dumps(data), content_type = "application/json")
    
	return render('dashboard.mako', request, {'cluster': cluster,
												'topics': topics,
												'brokers': brokers,
												'metrics': sections,
												'error_zk_topics':error_zk_topics,
												'error_zk_brokers':error_zk_brokers})
