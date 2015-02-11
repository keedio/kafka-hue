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
<script src="/static/ext/js/knockout-min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/knockout.mapping-2.3.2.js" type="text/javascript" charset="utf-8"></script>

${ graphsHUE.import_charts() }

<script type="text/javascript" charset="utf-8">
   var aValues = [];
   var sData = "${jsonDumps0}";
   var swData = sData.replace(/&quot;/ig,'"');  
   var jsonValues = JSON.parse(swData);   
   
   for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
      aValues.push({x: jsonValues[0].datapoints[i][1], y: jsonValues[0].datapoints[i][0]});
   }
   
   aData = [{
      values: aValues,
      key: 'Kafka',
      area: true
    }];
    
   nv.addGraph(function() {
      var graph0 = nv.models.lineChart()
                    .margin({left: 100})            //Adjust graph margins to give the x-axis some breathing room.
                    .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                    .transitionDuration(350)        //how fast do you want the lines to transition?
                    .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                    .showYAxis(true)                //Show the y-axis
                    .showXAxis(true);               //Show the x-axis 
                    
                  //graph x-axis settings
                  graph0.xAxis
                       .axisLabel('Time.')
                       //.rotateLabels(15)
                       //.tickFormat(d3.format('.2f'));

                  //graph y-axis settings
                  graph0.yAxis 
                       .axisLabel('Messages')
                       //.tickFormat(d3.format('.2f'));
  
                  d3.select('#graph0 svg') //Select the <svg> element you want to render the graph in.   
                    .datum(aData)         //Populate the <svg> element with graph data...
                    .call(graph0);         //Finally, render the graph!

                  //Update the graph when window resizes.
                  nv.utils.windowResize(function() { graph0.update() });
                  return graph0;
   });
   
   aValues = [];
   sData = "${jsonDumps1}";
   swData = sData.replace(/&quot;/ig,'"');  
   jsonValues = JSON.parse(swData);   
   
   for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
      aValues.push({x: jsonValues[0].datapoints[i][1], y: jsonValues[0].datapoints[i][0]});
   }
   
   aData = [{
      values: aValues,
      key: 'Kafka',
      area: true
    }];
    
   nv.addGraph(function() {
      var graph1 = nv.models.lineChart()
                    .margin({left: 100})            //Adjust graph margins to give the x-axis some breathing room.
                    .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                    .transitionDuration(350)        //how fast do you want the lines to transition?
                    .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                    .showYAxis(true)                //Show the y-axis
                    .showXAxis(true);               //Show the x-axis 
                    
                  //graph x-axis settings
                  graph1.xAxis
                       .axisLabel('Time.')
                       //.rotateLabels(15)
                       //.tickFormat(d3.format('.2f'));

                  //graph y-axis settings
                  graph1.yAxis 
                       .axisLabel('Messages')
                       //.tickFormat(d3.format('.2f'));
  
                  d3.select('#graph1 svg') //Select the <svg> element you want to render the graph in.   
                    .datum(aData)         //Populate the <svg> element with graph data...
                    .call(graph1);         //Finally, render the graph!

                  //Update the graph when window resizes.
                  nv.utils.windowResize(function() { graph1.update() });
                  return graph1;
   });
   
   aValues = [];
   sData = "${jsonDumps2}";
   swData = sData.replace(/&quot;/ig,'"');  
   jsonValues = JSON.parse(swData);   
   
   for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
      aValues.push({x: jsonValues[0].datapoints[i][1], y: jsonValues[0].datapoints[i][0]});
   }
   
   aData = [{
      values: aValues,
      key: 'Kafka',
      area: true
    }];
    
   nv.addGraph(function() {
      var graph2 = nv.models.lineChart()
                    .margin({left: 100})            //Adjust graph margins to give the x-axis some breathing room.
                    .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                    .transitionDuration(350)        //how fast do you want the lines to transition?
                    .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                    .showYAxis(true)                //Show the y-axis
                    .showXAxis(true);               //Show the x-axis 
                    
                  //graph x-axis settings
                  graph2.xAxis
                       .axisLabel('Time.')
                       //.rotateLabels(15)
                       //.tickFormat(d3.format('.2f'));

                  //graph y-axis settings
                  graph2.yAxis 
                       .axisLabel('Messages')
                       //.tickFormat(d3.format('.2f'));
  
                  d3.select('#graph2 svg') //Select the <svg> element you want to render the graph in.   
                    .datum(aData)         //Populate the <svg> element with graph data...
                    .call(graph2);         //Finally, render the graph!

                  //Update the graph when window resizes.
                  nv.utils.windowResize(function() { graph2.update() });
                  return graph2;
   });
   
   aValues = [];
   sData = "${jsonDumps3}";
   swData = sData.replace(/&quot;/ig,'"');  
   jsonValues = JSON.parse(swData);   
   
   for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
      aValues.push({x: jsonValues[0].datapoints[i][1], y: jsonValues[0].datapoints[i][0]});
   }
   
   aData = [{
      values: aValues,
      key: 'Kafka',
      area: true
    }];
    
   nv.addGraph(function() {
      var graph3 = nv.models.lineChart()
                    .margin({left: 100})            //Adjust graph margins to give the x-axis some breathing room.
                    .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                    .transitionDuration(350)        //how fast do you want the lines to transition?
                    .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                    .showYAxis(true)                //Show the y-axis
                    .showXAxis(true);               //Show the x-axis 
                    
                  //graph x-axis settings
                  graph3.xAxis
                       .axisLabel('Time.')
                       //.rotateLabels(15)
                       //.tickFormat(d3.format('.2f'));

                  //graph y-axis settings
                  graph3.yAxis 
                       .axisLabel('Messages')
                       //.tickFormat(d3.format('.2f'));
  
                  d3.select('#graph3 svg') //Select the <svg> element you want to render the graph in.   
                    .datum(aData)         //Populate the <svg> element with graph data...
                    .call(graph3);         //Finally, render the graph!

                  //Update the graph when window resizes.
                  nv.utils.windowResize(function() { graph3.update() });
                  return graph3;
   });
   
   aValues = [];
   sData = "${jsonDumps4}";
   swData = sData.replace(/&quot;/ig,'"');  
   jsonValues = JSON.parse(swData);   
   
   for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
      aValues.push({x: jsonValues[0].datapoints[i][1], y: jsonValues[0].datapoints[i][0]});
   }
   
   aData = [{
      values: aValues,
      key: 'Kafka',
      area: true
    }];
    
   nv.addGraph(function() {
      var graph4 = nv.models.lineChart()
                    .margin({left: 100})            //Adjust graph margins to give the x-axis some breathing room.
                    .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                    .transitionDuration(350)        //how fast do you want the lines to transition?
                    .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                    .showYAxis(true)                //Show the y-axis
                    .showXAxis(true);               //Show the x-axis 
                    
                  //graph x-axis settings
                  graph4.xAxis
                       .axisLabel('Time.')
                       //.rotateLabels(15)
                       //.tickFormat(d3.format('.2f'));

                  //graph y-axis settings
                  graph4.yAxis 
                       .axisLabel('Messages')
                       //.tickFormat(d3.format('.2f'));
  
                  d3.select('#graph4 svg') //Select the <svg> element you want to render the graph in.   
                    .datum(aData)         //Populate the <svg> element with graph data...
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
              <td width="20%">
                 <div class="panel panel-default">
                    <div class="panel-heading">
                       <i class="fa fa-desktop fa-fw"></i> Host List
                    </div>
                    <div class="panel-body">
                       <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                          <tr>
                             <td>
                                <input id="txtHost" name="txtHost" type="text" placeholder="Search for host(s) ..." style="width:90%;">
                             </td>
                          </tr>
                          <tr>
                             <td>
                                <select name="idHosts" id="idHosts" style="width:100%;" multiple>
                                   <option value="vm2" onclick="changeValue('host', 'vm2')">vm2</option>                                      
                                </select>
                             </td>
                          </tr>
                          <div id="divErrorH" class="hide">
                             <span class="label label-important"> ERROR in HOST </span>
                          </div>
                       </table>                                          
                    </div>
                 </div>
              </td>
              <td width="20%">
                 <div class="panel panel-default">
                    <div class="panel-heading">
                       <i class="fa fa-desktop fa-fw"></i> Topic List
                    </div>
                    <div class="panel-body">
                       <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                          <tr>
                             <td>
                                <input id="txtTopic" name="txtTopic" type="text" placeholder="Search for topic(s) ..." style="width:90%;">
                             </td>
                          </tr>
                          <tr>
                             <td>
                                <select name="idTopics" id="idTopics" style="width:100%;" multiple>
                                   % for topic in topics:
                                      <option value="${topic['id']}" onclick="changeValue('topic', '${topic['id']}')">${topic['id']}</option>
                                   % endfor                                         
                                </select>
                             </td>
                          </tr>
                          <div id="divErrorT" class="hide">
                             <span class="label label-important"> ERROR in TOPIC </span>
                          </div>
                       </table>                                                       
                    </div>
                 </div>
              </td>
              <td width="30%">
                 <div class="panel panel-default">
                    <div class="panel-heading">
                       <i class="fa fa-tachometer fa-fw"></i> Kafka Metrics
                    </div>
                    <div class="panel-body">
                       <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                          <tr>
                             <td>
                                <input id="txtMetric" name="txtMetric" type="text" placeholder="Search for metric(s) ..." style="width: 90%">
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
                             <span class="label label-important"> ERROR in METRICS </span>
                          </div>
                       </table>                       
                    </div>
                 </div>
              </td>
              <td width="30%">
                 <div class="panel panel-default">
                    <div class="panel-heading">
                       <i class="fa fa-calendar fa-fw"></i> Granularity
                    </div>
                    <div class="panel-body">
                       <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                          <tr>
                             <td>
                                <span class="btn-group" style="float:left">
                                   <a class="btn btn-date btn-info" data-value="1">${ _('Hour') }</a>
                                   <a class="btn btn-date btn-info" data-value="2">${ _('2Hour') }</a>
                                   <a class="btn btn-date btn-info" data-value="3">${ _('4Hour') }</a>                                                     
                                   <a class="btn btn-date btn-info" data-value="4">${ _('Day') }</a>
                                   <a class="btn btn-date btn-info" data-value="4">${ _('Week') }</a>
                                   <a class="btn btn-date btn-info" data-value="4">${ _('Month') }</a>
                                   <a class="btn btn-date btn-info" data-value="4">${ _('Year') }</a>
                                </span>
                             </td>
                          </tr>
                          <div id="divErrorG" class="hide">
                             <span class="label label-important"> ERROR in GRANULARITY </span>
                          </div>
                       </table>                           
                    </div>
                 </div>
              </td>
           </tr>
           <tr valign="top" align="right">
              <td colspan="4">
                 <button type="submit" class="btn btn-primary">Submit</button>                            
              </td>
           </tr>
           % if (graphName <> []):
              <tr valign="top">
                 <td colspan="4">
                    <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                       <tr>
                          <td>
                             <div id="graph0"><svg style="min-height: 180px; margin: 10px auto"></svg></div>
                          </td>
                          <td>
                             <div id="graph1"><svg style="min-height: 180px; margin: 10px auto"></svg></div>
                          </td>
                          <td>
                             <div id="graph2"><svg style="min-height: 180px; margin: 10px auto"></svg></div>
                          </td>
                          <td>
                             <div id="graph3"><svg style="min-height: 180px; margin: 10px auto"></svg></div>
                          </td>
                          <td>
                             <div id="graph4"><svg style="min-height: 180px; margin: 10px auto"></svg></div>
                          </td>
                       </tr>
                    </table>         
                 </td>
              </tr>
           % endif   
        </table>
        </form>                                                                                               
     </div>
  </div>
</div>
${commonfooter(messages) | n,unicode}
