## Licensed to the Apache Software Foundation (ASF) under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  The ASF licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
## http:# www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

<%!
  from django.utils.translation import ugettext as _
  from kafka.conf import CLUSTERS
%>

<%!
def is_selected(section, matcher):
  if section == matcher:
    return "active"
  else:
    return ""
%>

<%def name="header(breadcrumbs, withBody=True)">  
  <div class="container-fluid">
  <div class="row-fluid">
    <div class="card card-small">
      <h1 class="card-heading simple">
        <div class="btn-group pull-right">
          <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
            ${ _('Go to cluster') }
            <span class="caret"></span>
          </a>
          <ul class="dropdown-menu">
            % for cluster in CLUSTERS.get().keys(): 
              <li>
                <a href="${ url('kafka:cluster', cluster_id=cluster) }">
                  ${cluster}
                </a>
              </li>
            % endfor
          </ul>
        </div>
      % for idx, crumb in enumerate(breadcrumbs):
        %if crumb[1] != "":
          <a href="${crumb[1]}">${crumb[0]}</a>
        %else:
          ${crumb[0]}
        %endif
        %if idx < len(breadcrumbs) - 1:
          &gt;
        %endif
      % endfor
      </h1>
      %if withBody:
      <div class="card-body">
        <p>
      %endif
</%def>

<%def name="menubar(section='', c_id='')">
  <div class="navbar navbar-inverse navbar-fixed-top nokids">
    <div class="navbar-inner">
      <div class="container-fluid">
        <div class="nav-collapse">
          <ul class="nav">
            <li class="currentApp">
              <a href="/${app_name}"><img src="${ static('kafka/art/icon_kafka_24.png') }" /> Kafka </a>
             </li>
             <li class="${is_selected(section, 'Topology')}"><a href="${ url('kafka:cluster', cluster_id=c_id) }">${ _('Topology') }</a></li>
             <li class="${is_selected(section, 'Consumer Groups')}"><a href="${url('kafka:consumer_groups', cluster_id=c_id)}">${ _('Consumer Groups') }</a></li>
             <li class="${is_selected(section, 'Topics')}"><a href="${url('kafka:topics', cluster_id=c_id)}">${ _('Topics') }</a></li>
             <li class="${is_selected(section, 'Dashboard')}"><a href="${url('kafka:dashboard', cluster_id=c_id)}">${ _('Dashboard') }</a></li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</%def>