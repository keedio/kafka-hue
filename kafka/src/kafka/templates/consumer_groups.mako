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

${commonheader("%s > Consumer Groups" % (cluster['nice_name']), app_name, user) | n,unicode}

## DATATABLE SECTION FOR CONSUMERS

<link href="${ static('kafka/css/kafka.css') }" rel="stylesheet" >
<script src="${ static('desktop/ext/js/datatables-paging-0.1.js') }" type="text/javascript" charset="utf-8"></script>

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
	
</script>

<%
  _breadcrumbs = [
    ["Clusters", url('kafka:index')],
    [cluster['nice_name'].lower(), url('kafka:cluster', cluster_id=cluster['id'])],
    [_('Consumer Groups'), url('kafka:consumer_groups', cluster_id=cluster['id'])],
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

${ kafka.menubar(section='Consumer Groups',c_id=cluster['id']) }

<div class="container-fluid">
  <div class="card">
    <h2 class="card-heading simple">${ _('Consumer Groups of Kakfa cluster:') } ${ cluster['id'] }</h2>
    <div class="card-body">
    	
    	% if error == 1 :
			${Templates.divConnectionError(cluster['topics_path'])}				  		
		% elif error == 2 :
			${Templates.divNoNodeError(cluster['zk_host_ports'])}
		% else:	

	    	<div class="alert alert-info">${ _('Searching Consumer Groups from path:') } <b>${cluster['consumers_path']}</b></div>

	    	<table style="width: 100%">
		  		<tr>
		  			<td>
		  				<h4 class="card-heading simple">${ _('Consumer Groups') }</h4>
		  			</td>
		  		</tr>
		  		<tr>
		  			<td>
		  				${Templates.frmExport(consumers_groups)}
		  			</td>
		  		</tr>
		  		<tr>
		  			<td>
		  				<table class="table datatables table-striped table-hover table-condensed" id="consumerGroupsTable" data-tablescroller-disable="true">
					    	<thead>
						      <tr>
						        <th>${ _('Name') }</th>
						        <th>${ _('Status') }</th>
						        <th># ${ _('Consumers active') }</th>
						        <th># ${ _('Topics Subscribed') }</th>
						      </tr>
						    </thead>
						    <tbody>
						    	% for consumer_group in consumers_groups:
						    		<tr>
						    			<td><a href="${url('kafka:consumer_group', cluster_id=cluster['id'], group_id=consumer_group['id'])}">${consumer_group['id']}</a></td>
						    			<td>
						    				% if len(consumer_group['consumers']) == 0:
						    					<span class="label label-warning">${ _('OFFLINE') }</span>
						    				% else:
						    					<span class="label label-success">${ _('ONLINE') }</span>
						    				% endif
						    			</td>
						    			<td><span class="badge">${len(consumer_group['consumers'])}</span></td>
						    			<td><span class="badge">${len(consumer_group['offsets'])}</span></td>
						    		</tr>
								% endfor
						    </tbody>
					    </table>
		  			</td>
		  		</tr>
		  	</table>

		% endif
		</br>
	</div>
  </div>
</div>
${commonfooter(messages) | n,unicode}