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


import csv
import logging

import sys
import subprocess

#NoNodeError: If the parent node does not exist in ZooKeeper or If the zNode has expired before the zk.get() can be called.
from kazoo.client import KazooClient, KazooState
from kazoo.exceptions import NoNodeError, ZookeeperError

from reportlab.lib.pagesizes import A4, inch, portrait, landscape
from reportlab.platypus import SimpleDocTemplate, Table
from reportlab.lib import colors

from desktop.lib.django_util import render
import json
from kafka.conf import CLUSTERS
from kafka.utils import get_cluster_or_404

import base64
from kafka import settings
import requests
import ConfigParser
from django.http import HttpResponse


METRICS_INI = settings.METRICS_INI
logger = logging.getLogger(__name__)

def _get_topology():
	""" Method to get the entire Kafka clusters (defined in hue.ini) topology """
	topology = CLUSTERS.get()
	clusters = []
	error = 0
	error_brokers = 0
	error_consumer_groups = 0

	for c in topology:
		cluster = get_cluster_or_404(c)
		try:
			zk = KazooClient(hosts=CLUSTERS[c].ZK_HOST_PORTS.get())
			zk.start()
			brokers, error_brokers = _get_brokers(zk,cluster['id'])
			consumer_groups, error_consumer_groups = _get_consumer_groups(zk,cluster['id'])
			consumer_groups_status = {} 

			for consumer_group in consumer_groups:
				# 0 = offline, (not 0) =  online
				consumers_path = CLUSTERS[c].CONSUMERS_PATH.get() + "/" + consumer_group + "/ids"
				try:
					consumers = zk.get_children(consumers_path)
				except NoNodeError:
					consumer_groups_status[consumer_group]=0
				else:
					consumer_groups_status[consumer_group]=len(consumers)
			
			c = {'cluster':cluster,
				'brokers':brokers,
				'consumer_groups':consumer_groups,
				'consumer_groups_status':consumer_groups_status,
				'error_brokers':error_brokers,
				'error_consumer_groups':error_consumer_groups,
				'error':0}
			
		except NoNodeError:
			c = {'cluster':cluster,'brokers':[],
				'consumer_groups':[],
				'consumer_groups_status':[],
				'error_brokers':error_brokers,
				'error_consumer_groups':error_consumer_groups,
				'error':2}
		except:
			c = {'cluster':cluster,
				'brokers':[],
				'consumer_groups':[],
				'consumer_groups_status':[],
				'error_brokers':error_brokers,
				'error_consumer_groups':error_consumer_groups,
				'error':1}

		clusters.append(c)
		zk.stop()
	return clusters

def _get_cluster_topology(cluster):
	""" Method to get the topology of a given cluster """
	error_brokers = 0
	error_consumer_groups = 0
	try:
		zk = KazooClient(hosts=cluster['zk_host_ports'])
		zk.start()
		brokers, error_brokers = _get_brokers(zk,cluster['id'])
		consumer_groups, error_consumer_groups = _get_consumer_groups(zk,cluster['id'])
		consumer_groups_status = {} 
		for consumer_group in consumer_groups:
			# 0 = offline, (not 0) =  online
			consumers_path = cluster['consumers_path'] + "/" + consumer_group + "/ids"
			try:
				consumers = zk.get_children(consumers_path)
			except NoNodeError:
				consumer_groups_status[consumer_group]=0 # 0 = offline
			else:
				consumer_groups_status[consumer_group]=len(consumers) # (not 0) =  online

		cluster_topology = {'cluster':cluster,
							'brokers':brokers,
							'consumer_groups':consumer_groups,
							'consumer_groups_status':consumer_groups_status,
							'error_brokers':error_brokers,
							'error_consumer_groups':error_consumer_groups,
							'error':0}
	except NoNodeError:
		cluster_topology = {'cluster':cluster,
							'brokers':[],
							'consumer_groups':[],
							'consumer_groups_status':[],
							'error_brokers':error_brokers,
							'error_consumer_groups':error_consumer_groups,
							'error':2}
	except:
		cluster_topology = {'cluster':cluster,
							'brokers':[],
							'consumer_groups':[],
							'consumer_groups_status':[],
							'error_brokers':error_brokers,
							'error_consumer_groups':error_consumer_groups,
							'error':1}
	
	return cluster_topology

def _get_brokers(zk,cluster):
	""" Method to get the brokers of a given cluster """
	brokers=[]
	error = 0
	try:		
		children = zk.get_children(CLUSTERS[cluster].BROKERS_PATH.get())	
		for child in children:
			path = CLUSTERS[cluster].BROKERS_PATH.get() + "/" + child
			data, stat = zk.get(path)
			d=json.loads(data)
			broker = {'host':d['host'],'port':d['port'], 'id':child}
			brokers.append(broker)
	except NoNodeError:
		error = 2
	except:
		error = 1

	return brokers, error

def _get_consumer_groups(zk, cluster):
	""" Method to get the consumers groups ids of a given cluster """
	consumer_groups =[]
	error = 0
	try:
		consumer_groups = zk.get_children(CLUSTERS[cluster].CONSUMERS_PATH.get())
	except NoNodeError:
		error = 2
	except:
		error = 1

	return consumer_groups, error

def _get_topics(cluster):
	""" Method to get the topic list of a given cluster """
	topic_list = []
	error = 0
	try:
		zk = KazooClient(hosts=cluster['zk_host_ports'])
		zk.start()
		topics = zk.get_children(cluster['topics_path'])
	except NoNodeError:
		error = 2
		return topic_list, error
	except:
		error = 1
		return topic_list, error
	else:
		for topic in topics:
			t = {'id':topic}
			topic_path = cluster['topics_path'] + "/" + topic
			data, stat = zk.get(topic_path)
			d=json.loads(data)
			t['topic_partitions_data']=d['partitions']
			partitions_path = topic_path + "/partitions"			
			
			try:
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
			except NoNodeError:
				topic_list = []
				error = 2
				return topic_list, error 
			except:
				topic_list = []
				error = 1
				return topic_list, error

	zk.stop()
	return topic_list, error 

def _get_consumers(cluster):
	""" Method to get the consumers of a given cluster """
	consumer_groups = []
	error=0

	try:
		zk = KazooClient(hosts=cluster['zk_host_ports'])
		zk.start()
		groups, error = _get_consumer_groups(zk,cluster['id'])
		for group in groups:
			consumer_groups.append(_get_consumer_group(zk=zk,cluster=cluster,group_id=group))
	except NoNodeError:
		error = 2
	except:
		error = 1
	
	zk.stop()
	return consumer_groups,error

def _get_offsets(zk, cluster, group):
	""" Method to get the offsets of a given cluster and consumers group """
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
	""" Method to get the partitions owners of a given cluster and consumers group """
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
	""" Method to get the consumers group info of a given cluster and consumers gruoup id """
	consumer_group = {'id':group_id.encode('ascii')}
	consumers_path = cluster['consumers_path'] + "/" + group_id + "/ids"
	try:
		consumers = zk.get_children(consumers_path)
	except NoNodeError:
		consumer_group['consumers']=""
	else:
		consumer_subscription = {}		
		for consumer in consumers:
			data,stat = zk.get(consumers_path+"/"+consumer)
			d = json.loads(data)
			consumer_subscription[consumer]= d['subscription']
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
	except ConfigParser.Error:
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
			logger.exception("Exception on %s!" % option)
			dict = []

	return dict

def _get_json_type(request, cluster_id, type):
	data = []
	error_brokers = 0
	try:	
		cluster = get_cluster_or_404(id=cluster_id)

		zk = KazooClient(hosts=cluster['zk_host_ports'])
		zk.start()

		if type == "broker":			
			brokers, error_brokers = _get_brokers(zk,cluster_id)
			for broker in brokers:
				data.append(broker['host'])
		if type == "topic":
			topics, error_zk_topics = _get_topics(cluster)
			for topic in topics:
				data.append(topic['id'])
		if type == "metric":
			data = _get_sections_ini()
	except KazooException:
		error_zk_brokers = 1

	zk.stop()
	return HttpResponse(_get_dumps(data), content_type = "application/json")

def _create_topic(request):
	sCmd = ''

	if request.method == 'POST' and request.is_ajax():
		sZookeepers = request.POST['psZookeepers']
		iReplicationFactor = request.POST['piReplicationFactor']
		iPartitions = request.POST['piPartitions']
		sTopicName = request.POST['psTopicName']
		response = {'status': -1, 'output': "", 'error': ""}		
		sCmd = ('/usr/lib/kafka/bin/kafka-topics.sh --create ' 
				'--zookeeper %s '
				'--replication-factor %s '
				'--partitions %s '
				'--topic %s' % (sZookeepers, iReplicationFactor, iPartitions, sTopicName))

		output,err = subprocess.Popen([sCmd], shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()		
		response['output'] = output
		response['error'] = err

		if response['error'] == "":
			response['status'] = 0
		else:
			logger.exception(response['error'])
			
		return HttpResponse(json.dumps(response), content_type = "text/plain")

	return render('topics.mako', request, {})

def download(request):  
	if request.method == 'POST':
		aHeaders = []
		aData = []
		aLine = []
		elements = []
		tmpDict = []
		bIsString = False
		response = HttpResponse('')

		data = request.POST['pData'] \
			.replace("u", "") \
			.replace("'", '"') \
			.replace("None", '"None"') \
			.replace("False", '"False"') \
			.replace("True", '"True"') \
			.replace("Tre", '"Tre"')

		file_format = 'csv' if 'csv' in request.POST else 'xls' if 'xls' in request.POST else 'json' if 'json' in request.POST else 'pdf'

		try:
			if len(json.loads(data)) == 0:
				jsonData = [{"Data": "No data available"}]
				aHeaders = ["NoData"]
			else:
				jsonData = json.loads(data)

				
				for element in jsonData[0]:
					aHeaders.append(element)
		except Exception, e:
			logger.exception("Exception while processing data type")
			bIsString = True

		#Output File Format.
		if file_format in ('csv','xls'):      
			if file_format == 'csv':
				contenttype = 'text/csv'
			else:
				contenttype = 'application/ms-excel'

			response = HttpResponse(content_type=contenttype)
			response['Content-Disposition'] = 'attachment; filename=%s_%s.%s' % ('file', file_format, file_format)        
			writer = csv.writer(response)

			if bIsString == False:
				writer.writerow(aHeaders)
				for element in jsonData:        
					aLine = []
					for line in element:
						aLine.append(element[line])
					writer.writerow(aLine)
			else:				
				writer.writerow([data])

		if file_format == 'json':
			contenttype = 'application/json'
			response = HttpResponse(data, content_type=contenttype)
			response['Content-Disposition'] = 'attachment; filename=%s_%s.%s' % ('file', file_format, file_format)

		if file_format == 'pdf':        
			contenttype = 'application/pdf'
			response = HttpResponse(content_type=contenttype)
			doc = SimpleDocTemplate(response, pagesize = landscape(A4))
			elements = []
			aStyle = [('INNERGRID', (0,0), (-1,-1), 0.25, colors.black),
						('BOX', (0,0), (-1,-1), 0.25, colors.black),
						('ALIGN',(0,-1),(-1,-1),'CENTER'),
						('VALIGN',(0,-1),(-1,-1),'MIDDLE'),]

			#For incorrect data. 
			if bIsString == False:
				if str(jsonData).find("[", 1) == -1: 
					aData.append(aHeaders)

					for element in jsonData:        
						aLine = []
						for line in element:
							aLine.append(element[line])            
						aData.append(aLine)
		
					t = Table(aData, style = aStyle)
				else:
					t = Table([['ERROR'],['ERROR in table format']], style = aStyle)
			else:
				t = Table([['Header'],[data]], style = aStyle)

			elements.append(t)
			doc.build(elements)

	return response 

def index(request):
	""" Main view. Returns the topology of every kafka cluster defined in the hue.ini file """
	#return render('index.mako', request, {'cluster':_get_topology()[0]})
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
		zk = KazooClient(hosts=cluster['zk_host_ports'])
		zk.start()
		consumer_group = _get_consumer_group(zk=zk,cluster=cluster,group_id=group_id)
	except NoNodeError:
		error = 1
	except:
		error = 2
	zk.stop()

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
	error_brokers = 0

	cluster = get_cluster_or_404(id=cluster_id)
	topics, error_zk_topics = _get_topics(cluster)
	error_zk_brokers = 0
	brokers=[]

	try:	
		zk = KazooClient(hosts=cluster['zk_host_ports'])
		zk.start()
		brokers, error_brokers = _get_brokers(zk,cluster['id'])
		zk.stop()
	except NoNodeError:
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
