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

${commonheader("%s > Topics" % (cluster['nice_name']), app_name, user) | n,unicode}

## DATATABLE SECTION FOR TOPICS

<link href="/kafka/static/css/kafka.css" rel="stylesheet">

<script src="/static/ext/js/datatables-paging-0.1.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript" charset="utf-8">
	$(document).ready(function() {
	    $('#topicsTable').dataTable( {
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
	
	function create_topic() {
		var sError = "";
		var sZookeepers = document.getElementById("sZookeepers").value;
		var iReplicationFactor = document.getElementById("iReplicationFactor").value;
		var iPartitions = document.getElementById("iPartitions").value;
		var sTopicName = document.getElementById("sTopicName").value;
		
		$("#divResult").hide();
		$("#divError").hide();
		$("#divErrorTopic").hide();
		$("#divErrorZookeeper").hide();
		$("#divErrorReplication").hide();
		$("#divErrorPartition").hide();
		
		if (sTopicName == "") {
			$("#divErrorTopic").show();
		}
		else if (sZookeepers == "") {
			$("#divErrorZookeeper").show();
		}   
		else if (iReplicationFactor == "") {
			$("#divErrorReplication").show();
		}
		else if (iPartitions == "") {
			$("#divErrorPartition").show();
		}
		else  {
			$("#imgLoading").show();
			$("#btnSubmit").hide();
			$.ajax({
	              url: "/kafka/_create_topic/",           
	              dataType: 'json',   
	              data: {   psZookeepers: sZookeepers,
							piReplicationFactor: iReplicationFactor,
							piPartitions: iPartitions,
							psTopicName: sTopicName },
	              method: 'POST',
	              success: function(response) {
	              			$("#imgLoading").hide();
	              			$("#btnSubmit").show();
	              			console.log(response.status);
							if (response.status == 0) {   
								$("#divResult").show();								
								$("#spnResult").text(response.output);
								window.location.reload();
							}
							else {
								$("#divError").show();
								$("#spnError").text("ERROR in create topic \n" + response.output);
							};
							$("#imgLoading").hide();
	              			$("#btnSubmit").show(); 
							$("#divErrorTopic").hide();
							$("#divErrorZookeeper").hide();
							$("#divErrorReplication").hide();
							$("#divErrorPartition").hide();  
	                       },
	              error: function(xhr, status, error) {                        
	              			$("#imgLoading").hide();
	              			$("#btnSubmit").show(); 
	                        $("#divError").show();                         
	                     }    
	          });
		};
	}; //function create_topic
</script>

<%
  _breadcrumbs = [
    ["Clusters", url('kafka:index')],
    [cluster['nice_name'].lower(), url('kafka:cluster', cluster_id=cluster['id'])],
    [_('Topics'), url('kafka:topics', cluster_id=cluster['id'])],
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
	${Templates.tblCreateTopic()}
	${ kafka.header(_breadcrumbs) }
% endif 

${ kafka.menubar(section='Topics',c_id=cluster['id']) }

<div class="container-fluid">
  <div class="card">
  	<div id="create-topic" class="btn-group pull-right" style="vertical-align: top; right: 10px;">
    	<button id="btnCreateTopic" data-target="#tblCreateTopic" class="btn" data-toggle="modal">
			<i class="fa fa-plus-circle"></i>
			${ _('Create topic') } 
		</button>
    </div>
    <h2 class="card-heading simple">${ _('Topics of Kakfa cluster:') } ${ cluster['nice_name'] }</h2>
    <div class="card-body">

    	% if error == 1 :
			<div class="alert alert-error">
	  			${ _('Error connecting to the zookeper REST server:') } <b>${cluster['zk_rest_url']}</b><br>
	  			${ _('Please contact your administrator to solve this.') }
	  		</div>		

		% else:
	    	<div class="alert alert-info">${ _('Searching topics from path:') } <b>${cluster['topics_path']}</b></div>
	    	
			<table style="width: 100%">
		  		<tr>
		  			<td>
						<h4 class="card-heading simple">${ _('Topics') }</h4>		  				
		  			</td>
		  		</tr>
		  		<tr>
		  			<td>
		  				${Templates.frmExport(topics)}
		  			</td>
		  		</tr>
		  		<tr>
		  			<td>
		  				<table class="table datatables table-striped table-hover table-condensed" id="topicsTable" data-tablescroller-disable="true">
				    	  <thead>
					      	<tr>
						        <th>${ _('Name') }</th>
						        <th># ${ _('Partitions') }</th>
						        <th>${ _('Partitions ids') }</th>
						        <th># ${ _('Replicas / Partition') }</th>
						        <th>${ _('Partition - Replicas ids in isr') }</th>
						        <th>${ _('Partition - Leader') }</th>
						        <th>${ _('Status') }</th>
						      </tr>
						    </thead>
						    <tbody>
					    	% for topic in topics:
								<tr>
									<td>${topic['id']}</td>
									<td><span class="badge">${len(topic['partitions'])}</span></td>
									<td>
										[
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
						    		<td><span class="label label-success">${ _('OK') }</span></td>
								</tr>
							% endfor
							</tbody>
						</table>
		  			</td>
		  		</tr>
		  	</table>

		% endif
	</div>
  </div>
</div>
${commonfooter(messages) | n,unicode}