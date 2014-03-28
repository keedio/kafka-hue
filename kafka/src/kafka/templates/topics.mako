<%!
  from desktop.views import commonheader, commonfooter 
  from django.utils.translation import ugettext as _
%>
<%namespace name="kafka" file="navigation_bar.mako" />

${commonheader("%s > Topics" % (cluster['nice_name']), app_name, user) | n,unicode}

## DATATABLE SECTION FOR TOPICS

<script src="/static/ext/js/datatables-paging-0.1.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript" charset="utf-8">
	$(document).ready(function() {
	    $('#topicsTable').dataTable( {
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
    ["Topics", url('kafka:topics', cluster_id=cluster['id'])],
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

${ kafka.menubar(section='Topics',c_id=cluster['id']) }

<div class="container-fluid">
  <div class="card">
    <h2 class="card-heading simple">Topics of Kakfa cluster: ${ cluster['id'] }</h2>
    <div class="card-body">
    	<div class="alert alert-info">Searching topics from path: <b>${cluster['topics_path']}</b></div>
    	<h4 class="card-heading simple">Topics</h4>
    	</br>
    	<table class="table datatables table-striped table-hover table-condensed" id="topicsTable" data-tablescroller-disable="true">
    	  <thead>
	      	<tr>
		        <th>Name</th>
		        <th># Partitions</th>
		        <th>Partitions ids</th>
		        <th># Replicas / Partition</th>
		        <th>Partition - Replicas ids in isr</th>
		        <th>Partition - Leader
		        <th>Status</th>
		      </tr>
		    </thead>
		    <tbody>
	    	% for topic in topics:
				<tr>
					<td>${topic['id']}</td>
					<td><span class="badge">${len(topic['partitions'])}</span></td>
					<td>[
						% for partition in topic['partitions']:
							${partition}
						% endfor
						]
					</td>
					<td><span class="badge">${len(topic['topic_partitions_data'][topic['partitions'][0]])}</span</td>
					<td>
						% for partition in topic['partitions']:
							${partition} - ${topic['topic_partitions_states'][partition]['isr']}<br>
						% endfor
					</td>
					<td>
						% for partition in topic['partitions']:
							${partition} - ${topic['topic_partitions_states'][partition]['leader']}<br>
						% endfor
					</td>
		    		<td><span class="label label-success">OK</span></td>
				</tr>
			% endfor
			</tbody>
		</table>
		</br>
	</div>
  </div>
</div>
${commonfooter(messages) | n,unicode}