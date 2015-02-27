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
  from desktop.views import commonheader, commonfooter 
  from django.utils.translation import ugettext as _
  from kafka.conf import CLUSTERS
  import socket
  from kafka.utils import test_connection
%>
<%namespace name="kafka" file="navigation_bar.mako" />

${commonheader("Kafka > %s" % (cluster['cluster']['nice_name']), app_name, user) | n,unicode}

## DATATABLE SECTION FOR CONSUMER GROUPS AND BROKERS

<link href="/kafka/static/css/kafka.css" rel="stylesheet">

<script src="/static/ext/js/datatables-paging-0.1.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript" charset="utf-8">
	$(document).ready(function() {
	    $('#consumerGroupsTable').dataTable( {
	    	"sPaginationType":"bootstrap",
	    	"bLengthChange":true,
	        "sDom": "<'row-fluid'<l><f>r>t<'row-fluid'<'dt-pages'p><'dt-records'i>>",
	        "oLanguage":{
	            "sLengthMenu":"${_('Show _MENU_ entries')}",
	            "sSearch":"${_('Search')}",
		        "sEmptyTable":"${_('No data available')}",
		        "sInfo":"${_('Showing _START_ to _END_ of _TOTAL_ entries')}",
		        "sInfoEmpty":"${_('Showing 0 to 0 of 0 entries')}",
		        "sInfoFiltered":"${_('(filtered from _MAX_ total entries)')}",
		        "sZeroRecords":"${_('No matching records')}",
		        "oPaginate":{
		          "sFirst":"${_('First')}",
		          "sLast":"${_('Last')}",
		          "sNext":"${_('Next')}",
		          "sPrevious":"${_('Previous')}"
		        }
		    }
	    } );
	} );
	$(document).ready(function() {
	    $('#brokersTable').dataTable( {
	    	"sPaginationType":"bootstrap",
	    	"bLengthChange":true,
	        "sDom": "<'row-fluid'<l><f>r>t<'row-fluid'<'dt-pages'p><'dt-records'i>>",
	        "oLanguage":{
	            "sLengthMenu":"${_('Show _MENU_ entries')}",
	            "sSearch":"${_('Search')}",
		        "sEmptyTable":"${_('No data available')}",
		        "sInfo":"${_('Showing _START_ to _END_ of _TOTAL_ entries')}",
		        "sInfoEmpty":"${_('Showing 0 to 0 of 0 entries')}",
		        "sInfoFiltered":"${_('(filtered from _MAX_ total entries)')}",
		        "sZeroRecords":"${_('No matching records')}",
		        "oPaginate":{
		          "sFirst":"${_('First')}",
		          "sLast":"${_('Last')}",
		          "sNext":"${_('Next')}",
		          "sPrevious":"${_('Previous')}"
		        }
		    }
	    } );
	} );
</script>

<%
  _breadcrumbs = [
    ["Clusters", url('kafka:index')],
    [cluster['cluster']['nice_name'].lower(), url('kafka:cluster', cluster_id=cluster['cluster']['id'])]
  ]
%>

% if not cluster:
  <div class="container-fluid">
    <div class="card">
      <h1 class="card-heading simple">${ _('There are currently no clusters to browse.') }</h1>
    <div class="card-body">
      <p>
        ${ _('Please contact your administrator to solve this.') }
        <br/>
        <br/>
      </p>
    </div>
    </div>
  </div>
% else:
  ${ kafka.header(_breadcrumbs) }
% endif 

${ kafka.menubar(section='Topology',c_id=cluster['cluster']['id']) }

<div class="container-fluid">
  <div class="card">

    		<h2 class="card-heading simple">${ _('Topology of Kakfa cluster:') } ${ cluster['cluster']['nice_name'] }</h2>
			<div class="card-body">
		  	% if cluster['error'] == 0 :
		  		<div class="alert alert-info">${ _('The zookeper REST server:') } <b>${cluster['cluster']['zk_rest_url']}</b></div>
		  	% else:
		  		<div class="alert alert-error">
		  			${ _('Error connecting to the zookeper REST server:') } <b>${cluster['cluster']['zk_rest_url']}</b><br>
		  			${ _('Please contact your administrator to solve this.') }
		  		</div>	
		  	% endif			
		  	<h4 class="card-heading simple">${ _('Zookepers') }</h4>
		    </br>
		    <table class="table table-hover table-striped table-condensed">
		    	<thead>
			      <tr>
			        <th>${ _('Hostname') }</th>
			        <th>${ _('Port') }</th>
			        <th>${ _('Status') }</th>
			      </tr>
			    </thead>
			    <tbody>
			    % for zookeeper in cluster['cluster']['zk_host_ports'].split(','):
			    	<tr>
			    		<td>${zookeeper.split(':')[0]}</td>
			    		<td>${zookeeper.split(':')[1]}</td>
			    		<% 
							error = test_connection(zookeeper.split(':')[0],int(zookeeper.split(':')[1]))
						%>
			    		<td>
			    			% if not error:
			    				<span class="label label-success">${ _('ONLINE') }</span>
			    			% else:
			    				<span class="label label-warning">${ _('OFFLINE') }</span>
			    			% endif
			    		</td>
			    	</tr>
			    % endfor
			    </tbody>
			</table>
			</br>
			% if cluster['error'] == 0 :
				<h4 class="card-heading simple">${ _('Brokers') }</h4>
				</br>
			    <table class="table datatables table-striped table-hover table-condensed" id="brokersTable" data-tablescroller-disable="true">
			    	  <thead>
				      <tr>
				        <th>${ _('Broker ID') }</th>
				        <th>${ _('Hostname') }</th>
				        <th>${ _('Port') }</th>
				        <th>${ _('Status') }</th>
				      </tr>
				    </thead>
				    <tbody>
			    	% for broker in cluster['brokers']:
						<tr>
							<td>${broker['id']}</td>
							<td>${broker['host']}</td>
							<td>${broker['port']}</td>
							<% 
								error = test_connection(broker['host'],broker['port'])
							%>
				    		<td>
				    			% if not error:
				    				<span class="label label-success">${ _('ONLINE') }</span>
				    			% else:
				    				<span class="label label-warning">${ _('OFFLINE') }</span>
				    			% endif
				    		</td>
						</tr>
					% endfor
					</tbody>
				</table>
				</br>
			    <h4 class="card-heading simple">${ _('Consumer Groups') }</h4>
				</br>
			    <table class="table datatables table-striped table-hover table-condensed" id="consumerGroupsTable" data-tablescroller-disable="true">
			    	<thead>
				      <tr>
				        <th>${ _('Name') }</th>
				        <th>${ _('Status') }</th>
				      </tr>
				    </thead>
				    <tbody>
				    	% for consumer in cluster['consumer_groups']:
				    		<tr>
				    			<td><a href="${url('kafka:consumer_group', cluster_id=cluster['cluster']['id'], group_id=consumer)}">${consumer}</a></td>
				    			<td>
				    				% if cluster['consumer_groups_status'][consumer] == 0:
				    					<span class="label label-warning">${ _('OFFLINE') }</span>
				    				% else:
				    					<span class="label label-success">${ _('ONLINE') }</span>
				    				% endif
				    			</td>
				    		</tr>
						% endfor
				    </tbody>
			    </table>
			% else:
				<h4 class="card-heading simple">${ _('Brokers') }</h4>
				</br>
				<div class="alert alert-error">${ _('No data available') }</div>
				<br>
				<h4 class="card-heading simple">${ _('Consumer Groups') }</h4>
				</br>
				<div class="alert alert-error">${ _('No data available') }</div>
				<br>

			% endif

	</div>
  </div>
</div>
${commonfooter(messages) | n,unicode}
