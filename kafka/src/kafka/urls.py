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

try:
  from django.conf.urls.defaults import patterns, url
except:
  from django.conf.urls import patterns, url

IS_URL_NAMESPACED = True

urlpatterns = patterns('kafka.views',
  url(r'^$', 'index', name="index"),
  url(r'^(?P<cluster_id>\w+)$', 'cluster', name="cluster"),
  url(r'^(?P<cluster_id>\w+)/topics/$', 'topics', name="topics"),
  url(r'^(?P<cluster_id>\w+)/consumer_groups/$', 'consumer_groups', name="consumer_groups"),
  url(r'^(?P<cluster_id>\w+)/consumer_group/(?P<group_id>.+)$', 'consumer_group', name="consumer_group"),
  url(r'^(?P<cluster_id>\w+)/dashboard/$', 'dashboard', name="dashboard"),
  url(r'^(?P<cluster_id>\w+)/getjson/(?P<type>.+)/$', '_get_json_type', name="_get_json_type"),
  url(r'^_create_topic/$','_create_topic', name= "_create_topic"),
  url(r'^download/$', 'download', name='download'),
)
