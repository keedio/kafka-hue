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
%>

<%namespace name="kafka" file="navigation_bar.mako" />
<%namespace name="Templates" file="templates.mako" />

% if error == 0:
		${commonheader("%s > Consumer Group > %s" % (cluster['nice_name'], consumer_group['id'] ), app_name, user) | n,unicode}
% else:
		${commonheader("%s > Consumer Group " % (cluster['nice_name']), app_name, user) | n,unicode}
% endif

## DATATABLE SECTION FOR CONSUMERS

<link href="/kafka/static/css/kafka.css" rel="stylesheet">

<script src="/static/ext/js/datatables-paging-0.1.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript" charset="utf-8">
	$(document).ready(function() {
	    $('#consumerGroupTable').dataTable( {
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
	    $('#consumerGroupTopicsTable').dataTable( {
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


	% if error == 0:
		<%
			_breadcrumbs = [
				["Clusters", url('kafka:index')],
				[cluster['nice_name'].lower(), url('kafka:cluster', cluster_id=cluster['id'])],
				["Consumer Groups", url('kafka:consumer_groups', cluster_id=cluster['id'])],
				[consumer_group['id'], url('kafka:consumer_group', cluster_id=cluster['id'], group_id=consumer_group['id'])],
			]
		%>
	% else:
		<%
			_breadcrumbs = [
				["Clusters", url('kafka:index')],
				[cluster['nice_name'].lower(), url('kafka:cluster', cluster_id=cluster['id'])],
				["Consumer Groups", url('kafka:consumer_groups', cluster_id=cluster['id'])],
				
			]
		%>
	% endif

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

${ kafka.menubar(section='Consumer Groups',c_id=cluster['id']) }

<div class="container-fluid">
  <div class="card">
  	% if error == 0:
    	<h2 class="card-heading simple">${consumer_group['id']}</h2>
    % endif
    <div class="card-body">

    	% if error == 1 :
			<div class="alert alert-error">
	  			${ _('Error connecting to zookeper server(s):') } <b>${cluster['zk_host_ports']}</b><br>
	  			${ _('Please contact your administrator to solve this.') }
	  		</div>		
	  	% else:

	    	<div class="alert alert-info">${ _('Searching Consumer Groups from path:') } <b>${cluster['consumers_path']}/${consumer_group['id']}</b></div>

	    	<table style="width: 100%">
		  		<tr>
		  			<td>
						<h4 class="card-heading simple">${ _('Consumers') }</h4>		  				
					<td>
				</tr>
				<tr>
		  			<td>
		  				${Templates.frmExport(consumer_group['consumers'].keys())}
					<td>
				</tr>
				<tr>
		  			<td>
		  				<table class="table datatables table-striped table-hover table-condensed" id="consumerGroupTable" data-tablescroller-disable="true">
					    	<thead>
						      <tr>
						        <th>${ _('Name') }</th>
						        <th>${ _('Topics Subscribed') }</th>
						        <th>${ _('Status') }</th>
						      </tr>
						    </thead>
						    <tbody>
						    	% if consumer_group['consumers']:
							    	% for consumer in consumer_group['consumers'].keys():
							    		<tr>
							    			<td>${consumer}</td>
							    			<td>
							    				% for topic_subscribed in consumer_group['consumers'][consumer]:
							    					${topic_subscribed}<br>
							    				% endfor
							    			</td>
							    			<td><span class="label label-success">${ _('OK') }</span></td>
							    		</tr>
									% endfor
								% endif
						    </tbody>
					    </table>
					<td>
				</tr>
				<tr>
		  			<td>
		  				<h4 class="card-heading simple">${ _('Topics Subscribed') }</h4>
					<td>
				</tr>
				<tr>
		  			<td>
		  				${Templates.frmExport(consumer_group['offsets'])}
					<td>
				</tr>
				<tr>
		  			<td>
		  				<table class="table datatables table-striped table-hover table-condensed" id="consumerGroupTopicsTable" data-tablescroller-disable="true">
					    	<thead>
						      <tr>
						        <th>${ _('Topic') }</th>
						        <th>${ _('Partition - Offset') }</th>
						        <th>${ _('Partition - Owner') }</th>
						        <th>${ _('Status') }</th>
						      </tr>
						    </thead>
						    <tbody>
						    	% for topic_offset in consumer_group['offsets']:
						    		<tr>
						    			<td>${topic_offset['topic']}</td>
						    			<td>
						    				% for partition in topic_offset['offsets'].keys():
						    					${partition} - ${topic_offset['offsets'][partition]}<br>
						    				% endfor
						    			</td>
						    			<td>
						    				% for topic_owner in consumer_group['owners']:
						    					% if topic_offset['topic'] == topic_owner['topic']:
						    						% for partition in topic_owner['owners']:
						    							${partition} - ${topic_owner['owners'][partition]}<br>
						    						% endfor
						    					% else:
						    						<% continue %>
						    					% endif
						    				% endfor
						    			</td>
						    			<td><span class="label label-success">${ _('OK') }</span></td>
						    		</tr>
								% endfor
						    </tbody>
				    	</table>
					<td>
				</tr>
			</table>

		% endif
	</div>
  </div>
</div>
${commonfooter(messages) | n,unicode}