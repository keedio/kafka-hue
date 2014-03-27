<%!
  from desktop.views import commonheader, commonfooter 
  from django.utils.translation import ugettext as _
  from kafka.conf import CLUSTERS
  import socket
  from kafka.utils import test_connection
%>
<%namespace name="kafka" file="navigation_bar.mako" />

${commonheader("Topology", app_name, user) | n,unicode}

## DATATABLE SECTION FOR CONSUMER GROUPS AND BROKERS

<script src="/static/ext/js/datatables-paging-0.1.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript" charset="utf-8">
	$(document).ready(function() {
	    $('#consumerGroupsTable').dataTable( {
	    	"sPaginationType":"bootstrap",
	    	"bLengthChange":true,
	        "sDom": "<'row-fluid'<l><f>r>t<'row-fluid'<'dt-pages'p><'dt-records'i>>",
	        "oLanguage":{
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
    ["Clusters", url('kafka:index')]
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
    	<h2 class="card-heading simple">Topology of Kakfa cluster: ${ cluster['cluster']['nice_name'] }</h2>
			<div class="card-body">
		  	<div class="alert alert-info">The zookeper REST server: <b>${cluster['cluster']['zk_rest_url']}</b></div>

		  	<h4 class="card-heading simple">Zookeepers</h4>
		    </br>
		    <table class="table table-hover table-striped table-condensed">
		    	<thead>
			      <tr>
			        <th>Hostname</th>
			        <th>Port</th>
			        <th>Status</th>
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
			    				<span class="label label-success">ONLINE</span>
			    			% else:
			    				<span class="label label-warning">OFFLINE</span>
			    			% endif
			    		</td>
			    	</tr>
			    % endfor
			    </tbody>
			</table>
			</br>
			<h4 class="card-heading simple">Brokers</h4>
			</br>
		    <table class="table datatables table-striped table-hover table-condensed" id="brokersTable" data-tablescroller-disable="true">
		    	  <thead>
			      <tr>
			        <th>Hostname</th>
			        <th>Port</th>
			        <th>Status</th>
			      </tr>
			    </thead>
			    <tbody>
		    	% for broker in cluster['brokers']:
					<tr>
						<td>${broker['host']}</td>
						<td>${broker['port']}</td>
			    		<% 
							error = test_connection(broker['host'],broker['port'])
						%>
			    		<td>
			    			% if not error:
			    				<span class="label label-success">ONLINE</span>
			    			% else:
			    				<span class="label label-warning">OFFLINE</span>
			    			% endif
			    		</td>
					</tr>
				% endfor
				</tbody>
			</table>
			</br>
		    <h4 class="card-heading simple">Consumer groups</h4>
			</br>
		    <table class="table datatables table-striped table-hover table-condensed" id="consumerGroupsTable" data-tablescroller-disable="true">
		    	<thead>
			      <tr>
			        <th>Name</th>
			        <th>Status</th>
			      </tr>
			    </thead>
			    <tbody>
			    	% for consumer in cluster['consumer_groups']:
			    		<tr>
			    			<td><a href="${url('kafka:consumer_group', cluster_id=cluster['cluster']['id'], group_id=consumer)}">${consumer}</a></td>
			    			<td>
			    				% if cluster['consumer_groups_status'][consumer] == 0:
			    					<span class="label label-warning">OFFLINE</span>
			    				% else:
			    					<span class="label label-success">ONLINE</span>
			    				% endif
			    			</td>
			    		</tr>
					% endfor
			    </tbody>
		    </table>
	</div>
  </div>
</div>
${commonfooter(messages) | n,unicode}
