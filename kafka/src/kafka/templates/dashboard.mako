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
<%namespace name="graphsHUE" file="common_dashboard.mako" />

${commonheader("Dashboard", app_name, user) | n,unicode}

<link href="/kafka/static/css/kafka.css" rel="stylesheet">
<script src="/static/ext/js/datatables-paging-0.1.js" type="text/javascript" charset="utf-8"></script>

${ graphsHUE.import_charts() }

<script type="text/javascript" charset="utf-8">      
   function SetFilterMetric() {      
      var sHost = document.getElementById("txtHost").value;
      var sTopic = document.getElementById("txtTopic").value;
      var sMetric = document.getElementById("txtMetric").value;
      var sGranularity = document.getElementById("txtGranularity").value;
      var jsonDumps0;
      
      $("#divErrorH").hide();
      $("#divErrorT").hide();
      $("#divErrorM").hide();
      $("#divErrorG").hide();
           
      if (sHost == "") {
         $("#divErrorH").show();
      }   
      else if (sTopic == "") {
         $("#divErrorT").show();
      }
      else if (sMetric == "") {
         $("#divErrorM").show();
      }
      else if (sGranularity == "") {
         $("#divErrorG").show();
      }
      else  {                          
         $.ajax({
              url: "/kafka/${ cluster['id'] }/dashboard/",           
              dataType: 'json',   
              data: { txtHost: sHost,
                      txtTopic: sTopic,
                      txtMetric: sMetric,
                      txtGranularity: sGranularity},
              method: 'POST',
              success: function(response) {                           
                          jsonDumps0 = response.jsonDumps0;
                          jsonDumps1 = response.jsonDumps1;
                          jsonDumps2 = response.jsonDumps2;
                          jsonDumps3 = response.jsonDumps3;
                          jsonDumps4 = response.jsonDumps4;
                          sGraphs = response.sGraphs;
                          aGraphs = sGraphs.split(",");
                          getGraph0(jsonDumps0, aGraphs[0]);
                          getGraph1(jsonDumps1, aGraphs[1]);
                          getGraph2(jsonDumps2, aGraphs[2]);
                          getGraph3(jsonDumps3, aGraphs[3]);
                          getGraph4(jsonDumps4, aGraphs[4]);
                          document.getElementById('iMetricName').innerHTML = response.sMetric;
                          document.getElementById('fHost').innerHTML = document.getElementById('txtHost').value;
                          document.getElementById('fTopic').innerHTML = document.getElementById('txtTopic').value;
                          document.getElementById('fMetric').innerHTML = document.getElementById('txtMetric').value;
                          document.getElementById('fGranularity').innerHTML = document.getElementById('txtGranularity').value;
                          //Show results.
                          $("#divGraphs").show();                                               
                       },
              error: function(xhr, status, error) {
                         console.log('Status: ' + status);
                         console.log('ERROR: ' + error);
                         console.log('InText: ' + xhr.responseText);                         
                     }    
          });
       }; // ELSE.          
   };
   
   function getGraph0(pjson, psName) {
      var aValues0 = [];      
      var jsonValues = JSON.parse(pjson);   
   
      if (jsonValues.length > 0) {  
         for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
            var d0 = new Date(1000 * jsonValues[0].datapoints[i][1]);
            aValues0.push({x: d0, y: jsonValues[0].datapoints[i][0]});
         };
      };
   
      aData0 = [{
         values: aValues0,
         key: psName,
         area: true
       }];
    
      nv.addGraph(function() {
         var graph0 = nv.models.lineChart()
                       .margin({top: 15, right:20, left:60, bottom: 40})            //Adjust graph margins to give the x-axis some breathing room.
                       .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                       .transitionDuration(350)        //how fast do you want the lines to transition?
                       .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                       .showYAxis(true)                //Show the y-axis
                       .showXAxis(false);               //Show the x-axis                             
                     
             graph0.yAxis                     
                   .axisLabel('Messages')                     
                   .tickFormat(d3.format('s'));
  
             d3.select('#graph0 svg') //Select the <svg> element you want to render the graph in.   
               .datum(aData0)         //Populate the <svg> element with graph data...
               .call(graph0);         //Finally, render the graph!

             //Update the graph when window resizes.
             nv.utils.windowResize(function() { graph0.update() });
             return graph0;
      });   
   }; // END getGraph0.
   
   function getGraph1(pjson, psName) {
      var aValues1 = [];  
      jsonValues = JSON.parse(pjson);   
   
      if (jsonValues.length > 0) {
         for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
            var d1 = new Date(1000 * jsonValues[0].datapoints[i][1]);
            aValues1.push({x: d1, y: jsonValues[0].datapoints[i][0]});
         };
      };
   
      aData1 = [{
         values: aValues1,
         key: psName,
         area: true
       }];
    
      nv.addGraph(function() {
         var graph1 = nv.models.lineChart()
                       .margin({top: 15, right:20, left:60, bottom: 40})            //Adjust graph margins to give the x-axis some breathing room.
                       .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                       .transitionDuration(350)        //how fast do you want the lines to transition?
                       .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                       .showYAxis(true)                //Show the y-axis
                       .showXAxis(false);               //Show the x-axis 
                                                       
             graph1.yAxis 
                   .axisLabel('Messages')
                   .tickFormat(d3.format('s'));
  
             d3.select('#graph1 svg') //Select the <svg> element you want to render the graph in.   
               .datum(aData1)         //Populate the <svg> element with graph data...
               .call(graph1);         //Finally, render the graph!

             //Update the graph when window resizes.
             nv.utils.windowResize(function() { graph1.update() });
             return graph1;
      });
   }; // END getGraph1.  

   function getGraph2(pjson, psName) {   
      var aValues2 = [];  
      jsonValues = JSON.parse(pjson);   
   
      if (jsonValues.length > 0) {
         for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
            var d2 = new Date(1000 * jsonValues[0].datapoints[i][1]);
            aValues2.push({x: d2, y: jsonValues[0].datapoints[i][0]});
         };
      };
   
      aData2 = [{
         values: aValues2,
         key: psName,
         area: true
       }];
    
      nv.addGraph(function() {
         var graph2 = nv.models.lineChart()
                       .margin({top: 15, right:20, left:60, bottom: 40})            //Adjust graph margins to give the x-axis some breathing room.
                       .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                       .transitionDuration(350)        //how fast do you want the lines to transition?
                       .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                       .showYAxis(true)                //Show the y-axis
                       .showXAxis(false);               //Show the x-axis                                       

             graph2.yAxis 
                   .axisLabel('Messages')
                   .tickFormat(d3.format('s'));
  
             d3.select('#graph2 svg') //Select the <svg> element you want to render the graph in.   
               .datum(aData2)         //Populate the <svg> element with graph data...
               .call(graph2);         //Finally, render the graph!

             //Update the graph when window resizes.
             nv.utils.windowResize(function() { graph2.update() });
             return graph2;
      });
   }; // END getGraph2.  
   
   function getGraph3(pjson, psName) {
      var aValues3 = [];  
      jsonValues = JSON.parse(pjson);   
   
      if (jsonValues.length > 0) {
         for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
            aValues3.push({x: jsonValues[0].datapoints[i][1], y: jsonValues[0].datapoints[i][0]});
         };
      };
   
      aData3 = [{
         values: aValues3,
         key: psName,
         area: true
       }];
    
      nv.addGraph(function() {
         var graph3 = nv.models.lineChart()
                       .margin({top: 15, right:20, left:60, bottom: 40})            //Adjust graph margins to give the x-axis some breathing room.
                       .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                       .transitionDuration(350)        //how fast do you want the lines to transition?
                       .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                       .showYAxis(true)                //Show the y-axis
                       .showXAxis(false);               //Show the x-axis                                       

             graph3.yAxis 
                   .axisLabel('Messages')
                   .tickFormat(d3.format('s'));
  
             d3.select('#graph3 svg') //Select the <svg> element you want to render the graph in.   
               .datum(aData3)         //Populate the <svg> element with graph data...
               .call(graph3);         //Finally, render the graph!

             //Update the graph when window resizes.
             nv.utils.windowResize(function() { graph3.update() });
             return graph3;
      });
   }; // END getGraph3.  
   
   function getGraph4(pjson, psName) {
      var aValues4 = [];  
      jsonValues = JSON.parse(pjson);   
   
      if (jsonValues.length > 0) {
         for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
            var d4 = new Date(1000 * jsonValues[0].datapoints[i][1]);
            aValues4.push({x: d4, y: jsonValues[0].datapoints[i][0]});
         };
      }; 
   
      aData4 = [{
         values: aValues4,
         key: psName,
         area: true
       }];
    
      nv.addGraph(function() {
         var graph4 = nv.models.lineChart()
                        .margin({top: 15, right:20, left:60, bottom: 40})            //Adjust graph margins to give the x-axis some breathing room.
                        .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                        .transitionDuration(350)        //how fast do you want the lines to transition?
                        .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                        .showYAxis(true)                //Show the y-axis
                        .showXAxis(false);               //Show the x-axis                                       
                  
             graph4.yAxis 
                   .axisLabel('Messages')
                   .tickFormat(d3.format('s'));
  
             d3.select('#graph4 svg') //Select the <svg> element you want to render the graph in.   
               .datum(aData4)         //Populate the <svg> element with graph data...
               .call(graph4);         //Finally, render the graph!

             //Update the graph when window resizes.
             nv.utils.windowResize(function() { graph4.update() });
             return graph4;
      });
   }; // END getGraph4.  
   
   function changeValue(psType, psValue) {
      var sElement = ''; 
      
      if (psType == 'host'){
         sElement = 'txtHost';    
      }
      if (psType == 'topic'){
         sElement = 'txtTopic';
      }
      if (psType == 'metric'){
         sElement = 'txtMetric';
      }
      if (psType == 'granularity'){
         sElement = 'txtGranularity';
      }
      document.getElementById(sElement).value = psValue;
   };
</script>

<%
  _breadcrumbs = [
    ["Clusters", url('kafka:index')],
    [cluster['nice_name'].lower(), url('kafka:cluster', cluster_id=cluster['id'])],
    ["Dashboard", url('kafka:dashboard', cluster_id=cluster['id'])]
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

${ kafka.menubar(section='Dashboard',c_id=cluster['id']) }

<div class="container-fluid">
  <div class="card">
     <h2 class="card-heading simple">${ _('Dashboard of Kakfa cluster:') } ${ cluster['id'] }</h2>
     <div class="card-body">
        <form id="frmFilterMetric" method="post" enctype="multipart/form-data" action="/kafka/${ cluster['id'] }/dashboard/">
        <table width="100%" height="100%" border="0" cellpadding="6" cellspacing="0">
           <tr valign="top">
              <td width="20%" rowspan="2">
                 <div class="panel panel-default">
                    <div class="panel-heading">
                       <i class="fa fa-desktop fa-fw"></i> ${ _(' Host List ')}
                    </div>
                    <div class="panel-body">
                       <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                          <tr>
                             <td>
                                <input id="txtHost" name="txtHost" type="text" placeholder="${ _('Search for host(s)') }" style="width:90%;">
                             </td>
                          </tr>
                          <tr>
                             <td>
                                <select name="idHosts" id="idHosts" style="width:100%;" multiple>
                                   % for broker in brokers:
                                      <option value="${broker['host']}" onclick="changeValue('host', '${broker['host']}')">${broker['host']}</option>
                                   % endfor                                      
                                </select>
                             </td>
                          </tr>
                          <div id="divErrorH" class="hide">
                             <span class="label label-important"> ${ _('ERROR in HOST') } </span>
                          </div>
                       </table>                                          
                    </div>
                 </div>
              </td>
              <td width="20%" rowspan="2">
                 <div class="panel panel-default">
                    <div class="panel-heading">
                       <i class="fa fa-desktop fa-fw"></i> ${ _('Topic List') }
                    </div>
                    <div class="panel-body">
                       <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                          <tr>
                             <td>
                                <input id="txtTopic" name="txtTopic" type="text" placeholder="${ _('Search for topic(s)') }" style="width:90%;">
                             </td>
                          </tr>
                          <tr>
                             <td>
                                <select name="idTopics" id="idTopics" style="width:100%;" multiple>
                                   <option value="All Topics" onclick="changeValue('topic', 'All Topics')">${ _('All Topics') }</option>
                                   % for topic in topics:
                                      <option value="${topic['id']}" onclick="changeValue('topic', '${topic['id']}')">${topic['id']}</option>
                                   % endfor                                         
                                </select>
                             </td>
                          </tr>
                          <div id="divErrorT" class="hide">
                             <span class="label label-important"> ${ _('ERROR in TOPIC') } </span>
                          </div>
                       </table>                                                       
                    </div>
                 </div>
              </td>
              <td width="30%" rowspan="2">
                 <div class="panel panel-default">
                    <div class="panel-heading">
                       <i class="fa fa-tachometer fa-fw"></i> ${ _('Kafka Metrics') }
                    </div>
                    <div class="panel-body">
                       <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                          <tr>
                             <td>
                                <input id="txtMetric" name="txtMetric" type="text" placeholder="${ _('Search for metric(s)') }" style="width: 90%">
                             </td>
                          </tr>
                          <tr>
                             <td>
                                <select name="txtMetrics" id="txtMetrics" style="width: 100%" multiple>
                                   % for metric in metrics:
                                      <option value="${metric}" onclick="changeValue('metric', '${metric}')">${metric}</option>
                                   % endfor                                      
                                </select>
                             </td>
                          </tr>
                          <div id="divErrorM" class="hide">
                             <span class="label label-important"> ${ _('ERROR in METRICS') } </span>
                          </div>
                       </table>                       
                    </div>
                 </div>
              </td>
              <td width="30%">
                 <div class="panel panel-default">
                    <div class="panel-heading">
                       <i class="fa fa-calendar fa-fw"></i> ${ _('Granularity') }
                    </div>
                    <div class="panel-body">
                       <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                          <tr>
                             <td>
                                <span class="btn-group" style="float:left">
                                   <a class="btn btn-date btn-info" onclick="changeValue('granularity', 'hour')">${ _('Hour') }</a>
                                   <a class="btn btn-date btn-info" onclick="changeValue('granularity', '2hr')">${ _('2Hour') }</a>
                                   <a class="btn btn-date btn-info" onclick="changeValue('granularity', '4hr')">${ _('4Hour') }</a>                                                     
                                   <a class="btn btn-date btn-info" onclick="changeValue('granularity', 'day')">${ _('Day') }</a>
                                   <a class="btn btn-date btn-info" onclick="changeValue('granularity', 'week')">${ _('Week') }</a>
                                   <a class="btn btn-date btn-info" onclick="changeValue('granularity', 'month')">${ _('Month') }</a>
                                   <a class="btn btn-date btn-info" onclick="changeValue('granularity', 'year')">${ _('Year') }</a>
                                   <input type="hidden" id="txtGranularity" name="txtGranularity" value="">
                                </span>
                             </td>
                          </tr>
                          <div id="divErrorG" class="hide">
                             <span class="label label-important"> ${ _('ERROR in GRANULARITY') } </span>
                          </div>
                       </table>                           
                    </div>
                 </div>
              </td>
           </tr>
           <tr valign="top" align="right">
              <td colspan="4">
                 <button type="button" class="btn btn-primary" onclick="SetFilterMetric()">${ _('Submit') }</button>                            
              </td>
           </tr> 
           </table>          
           <div id="divGraphs" class="hide">
              <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                 <tr valign="top">
                    <td colspan="4">
                       <div class="panel panel-default">
                          <div class="panel-heading">
                             <i id="iMetricName" class="fa fa-tachometer fa-fw"></i>                             
                          </div>
                          <div class="panel-body">
                             <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                                <tr>
                                   <td width="20%">
                                      <div id="graph0"><svg style="min-height: 180px; margin: 10px auto"></svg></div>
                                   </td>
                                   <td width="20%">
                                      <div id="graph1"><svg style="min-height: 180px; margin: 10px auto"></svg></div>
                                   </td>
                                   <td width="20%">
                                      <div id="graph2"><svg style="min-height: 180px; margin: 10px auto"></svg></div>
                                   </td>
                                   <td width="20%">
                                      <div id="graph3"><svg style="min-height: 180px; margin: 10px auto"></svg></div>
                                   </td>
                                   <td width="20%">
                                      <div id="graph4"><svg style="min-height: 180px; margin: 10px auto"></svg></div>
                                   </td>
                                </tr>
                                <tr>
                                   <td colspan="5" align="center">
                                      <span class="btn-group">
                                         <a id="fHost" class="btn btn-date btn-info disabled"></a>
                                         <a id="fTopic" class="btn btn-date btn-info disabled"></a>
                                         <a id="fMetric" class="btn btn-date btn-info disabled"></a>                                                     
                                         <a id="fGranularity" class="btn btn-date btn-info disabled"></a>
                                      </span>
                                   </td>
                                </tr>   
                             </table>
                          </div>
                       </div>               
                    </td>
                 </tr>
              </table>
           </div>   
        
        </form>                                                                                               
     </div>
  </div>
</div>
${commonfooter(messages) | n,unicode}
