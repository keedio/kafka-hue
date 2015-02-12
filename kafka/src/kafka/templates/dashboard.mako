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
   var aValues0 = [];
   var sData = "${jsonDumps0}";
   var swData = sData.replace(/&quot;/ig,'"');  
   var jsonValues = JSON.parse(swData);   
   
   var sGraphs = "${graphs}"
   var sGraphsTemp = sGraphs.replace(/&quot;/ig,'"');   
   var aGraphs = sGraphsTemp.split(",");
     
   for (var i=0; i<Object.keys(jsonValues).length; i++) {
      var d0 = new Date(1000 * jsonValues[0].datapoints[i][1]);
      aValues0.push({x: d0, y: jsonValues[0].datapoints[i][0]});
   }
   
   aData0 = [{
      values: aValues0,
      key: aGraphs[0],
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

                  //graph y-axis settings
                  graph0.yAxis                     
                       .axisLabel('Messages')                     
                       .tickFormat(d3.format('.2e'));
  
                  d3.select('#graph0 svg') //Select the <svg> element you want to render the graph in.   
                    .datum(aData0)         //Populate the <svg> element with graph data...
                    .call(graph0);         //Finally, render the graph!

                  //Update the graph when window resizes.
                  nv.utils.windowResize(function() { graph0.update() });
                  return graph0;
   });
   
   var aValues1 = [];
   sData = "${jsonDumps1}";
   swData = sData.replace(/&quot;/ig,'"');  
   jsonValues = JSON.parse(swData);   
   
   for (var i=0; i<Object.keys(jsonValues).length; i++) {
      var d1 = new Date(1000 * jsonValues[0].datapoints[i][1]);
      aValues1.push({x: d1, y: jsonValues[0].datapoints[i][0]});
   }
   
   aData1 = [{
      values: aValues1,
      key: aGraphs[1],
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
                                     
                  //graph y-axis settings
                  graph1.yAxis 
                       .axisLabel('Messages')
                       .tickFormat(d3.format('d'));
  
                  d3.select('#graph1 svg') //Select the <svg> element you want to render the graph in.   
                    .datum(aData1)         //Populate the <svg> element with graph data...
                    .call(graph1);         //Finally, render the graph!

                  //Update the graph when window resizes.
                  nv.utils.windowResize(function() { graph1.update() });
                  return graph1;
   });
   
   var aValues2 = [];
   sData = "${jsonDumps2}";
   swData = sData.replace(/&quot;/ig,'"');  
   jsonValues = JSON.parse(swData);   
   
   for (var i=0; i<Object.keys(jsonValues).length; i++) {
      var d2 = new Date(1000 * jsonValues[0].datapoints[i][1]);
      aValues2.push({x: d2, y: jsonValues[0].datapoints[i][0]});
   }
   
   aData2 = [{
      values: aValues2,
      key: aGraphs[2],
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

                  //graph y-axis settings
                  graph2.yAxis 
                       .axisLabel('Messages')
                       .tickFormat(d3.format('d'));
  
                  d3.select('#graph2 svg') //Select the <svg> element you want to render the graph in.   
                    .datum(aData2)         //Populate the <svg> element with graph data...
                    .call(graph2);         //Finally, render the graph!

                  //Update the graph when window resizes.
                  nv.utils.windowResize(function() { graph2.update() });
                  return graph2;
   });
   
   var aValues3 = [];
   sData = "${jsonDumps3}";
   swData = sData.replace(/&quot;/ig,'"');  
   jsonValues = JSON.parse(swData);   
   
   for (var i=0; i<Object.keys(jsonValues).length; i++) {
      aValues3.push({x: jsonValues[0].datapoints[i][1], y: jsonValues[0].datapoints[i][0]});
   }
   
   aData3 = [{
      values: aValues3,
      key: aGraphs[3],
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

                  //graph y-axis settings
                  graph3.yAxis 
                       .axisLabel('Messages')
                       .tickFormat(d3.format('d'));
  
                  d3.select('#graph3 svg') //Select the <svg> element you want to render the graph in.   
                    .datum(aData3)         //Populate the <svg> element with graph data...
                    .call(graph3);         //Finally, render the graph!

                  //Update the graph when window resizes.
                  nv.utils.windowResize(function() { graph3.update() });
                  return graph3;
   });
   
   var aValues4 = [];
   sData = "${jsonDumps4}";
   swData = sData.replace(/&quot;/ig,'"');  
   jsonValues = JSON.parse(swData);   
   
   for (var i=0; i<Object.keys(jsonValues).length; i++) {
      var d4 = new Date(1000 * jsonValues[0].datapoints[i][1]);
      aValues4.push({x: d4, y: jsonValues[0].datapoints[i][0]});
   }
   
   aData4 = [{
      values: aValues4,
      key: aGraphs[4],
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

                  //graph y-axis settings
                  graph4.yAxis 
                       .axisLabel('Messages')
                       .tickFormat(d3.format('d'));
  
                  d3.select('#graph4 svg') //Select the <svg> element you want to render the graph in.   
                    .datum(aData4)         //Populate the <svg> element with graph data...
                    .call(graph4);         //Finally, render the graph!

                  //Update the graph when window resizes.
                  nv.utils.windowResize(function() { graph4.update() });
                  return graph4;
   });
   
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
        <form id="frmFilterMetric" method="post">
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
                 <button type="submit" class="btn btn-primary">${ _('Submit') }</button>                            
              </td>
           </tr>
           % if (graphs <> ""):
              <tr valign="top">
                 <td colspan="4">
                    <div class="panel panel-default">
                       <div class="panel-heading">
                          <i class="fa fa-tachometer fa-fw"></i> ${sMetric}
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
                                      <a class="btn btn-date btn-info disabled">${filterHost}</a>
                                      <a class="btn btn-date btn-info disabled">${filterTopic}</a>
                                      <a class="btn btn-date btn-info disabled">${filterMetric}</a>                                                     
                                      <a class="btn btn-date btn-info disabled">${filterGranularity}</a>
                                   </span>
                                </td>
                             </tr>   
                          </table>
                       </div>
                    </div>               
                 </td>
              </tr>
           % endif   
        </table>
        </form>                                                                                               
     </div>
  </div>
</div>
${commonfooter(messages) | n,unicode}
