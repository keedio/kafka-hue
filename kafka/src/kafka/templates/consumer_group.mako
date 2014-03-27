<%!
  from desktop.views import commonheader, commonfooter 
  from django.utils.translation import ugettext as _
%>
<%namespace name="kafka" file="navigation_bar.mako" />

${commonheader("%s > Consumer Group > %s" % (cluster['nice_name'], consumer_group['id'] ), app_name, user) | n,unicode}

## DATATABLE SECTION FOR CONSUMERS

<script src="/static/ext/js/datatables-paging-0.1.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript" charset="utf-8">
	$(document).ready(function() {
	    $('#consumerGroupTable').dataTable( {
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
	    $('#consumerGroupTopicsTable').dataTable( {
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
    ["Clusters", url('kafka:index')],
    [cluster['nice_name'].lower(), url('kafka:cluster', cluster_id=cluster['id'])],
    ["Consumer Groups", url('kafka:consumer_groups', cluster_id=cluster['id'])],
    [consumer_group['id'], url('kafka:consumer_group', cluster_id=cluster['id'], group_id=consumer_group['id'])],
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
    <h2 class="card-heading simple">${consumer_group['id']}</h2>
    <div class="card-body">
    	<div class="alert alert-info">Searching Consumer Groups from path: <b>${cluster['consumers_path']}/${consumer_group['id']}</b></div>
    	<h4 class="card-heading simple">Consumers</h4>
    	</br>
    	<table class="table datatables table-striped table-hover table-condensed" id="consumerGroupTable" data-tablescroller-disable="true">
		    	<thead>
			      <tr>
			        <th>Name</th>
			        <th>Topics Subscribed</th>
			        <th>Status</th>
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
				    			<td><span class="label label-success">OK</span></td>
				    		</tr>
						% endfor
					% endif
			    </tbody>
		    </table>
		</br>
		<h4 class="card-heading simple">Topics Subscribed</h4>
    	</br>
		<table class="table datatables table-striped table-hover table-condensed" id="consumerGroupTopicsTable" data-tablescroller-disable="true">
		    	<thead>
			      <tr>
			        <th>Topic</th>
			        <th>Partition - Offset</th>
			        <th>Partition - Owner</th>
			        <th>Status</th>
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
			    			<td><span class="label label-success">OK</span></td>
			    		</tr>
					% endfor
			    </tbody>
	    </table>
	</div>
  </div>
</div>
${commonfooter(messages) | n,unicode}