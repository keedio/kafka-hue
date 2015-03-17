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
<%namespace name="graphsHUE" file="common_dashboard.mako" />

${commonheader("Dashboard", app_name, user) | n,unicode}

<link href="/kafka/static/css/kafka.css" rel="stylesheet">
<script type="text/javascript" src="/kafka/static/js/jquery.smart_autocomplete.js"></script>

${ graphsHUE.import_charts() }

<style>
    ul.smart_autocomplete_container li {list-style: none; cursor: pointer;}
    li.smart_autocomplete_highlight {background-color: #F6F6F6;}
    ul.smart_autocomplete_container { margin: 0; padding: 5px; background-color: #DBDBDB; min-height: 100px;}
</style>

<script type="text/javascript" charset="utf-8">  

   $(function(){
         
        $("#txtHost").smartAutoComplete({ 
          source: "/kafka/${ cluster['id'] }/getjson/broker", 
          maxResults: 5,
          delay: 100,
          forceSelect: true
        });

        $("#txtTopic").smartAutoComplete({
          source: "/kafka/${ cluster['id'] }/getjson/topic",  
          maxResults: 5, 
          delay: 100 ,
          forceSelect: true
        });

        $("#txtMetric").smartAutoComplete({ 
          source: "/kafka/${ cluster['id'] }/getjson/metric", 
          maxResults: 5,
          delay: 100,
          forceSelect: true
        });
    });

   

   $(document).ready(function () {
      $("a.btn-date").click(function () {
          $("a.btn-date").not(this).removeClass("active");
          $(this).toggleClass("active");
      });
   });

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
         $("#imgLoading").show();
         $("#btnSubmit").hide();

         if (sTopic == '${ _('All topics') }') {
            sTopic = '*';
         };

         $.ajax({
              url: "/kafka/${ cluster['id'] }/dashboard/",           
              dataType: 'json',   
              data: { txtHost: sHost,
                      txtTopic: sTopic,
                      txtMetric: sMetric,
                      txtGranularity: sGranularity},
              method: 'POST',
              success: function(response) {                           
                          if (response.status === undefined) {
                            $("#imgLoading").hide();    
                            $("#btnSubmit").show(); 
                            $("#divGraphs").hide();
                            $("#divURLError").show();
                          }
                          else {
                            sGranularity = response.sGranularity;
                            jsonDumps0 = response.jsonDumps0;
                            jsonDumps1 = response.jsonDumps1;
                            jsonDumps2 = response.jsonDumps2;
                            jsonDumps3 = response.jsonDumps3;
                            jsonDumps4 = response.jsonDumps4;
                            sGraphs = response.sGraphs;
                            aGraphs = sGraphs.split(",");
                            getGraph0(jsonDumps0, aGraphs[0], getGranularity(sGranularity));
                            getGraph1(jsonDumps1, aGraphs[1], getGranularity(sGranularity));
                            getGraph2(jsonDumps2, aGraphs[2], getGranularity(sGranularity));
                            getGraph3(jsonDumps3, aGraphs[3], getGranularity(sGranularity));
                            getGraph4(jsonDumps4, aGraphs[4], getGranularity(sGranularity));
                            document.getElementById('fHost').innerHTML = document.getElementById('txtHost').value;
                            document.getElementById('fTopic').innerHTML = document.getElementById('txtTopic').value;
                            document.getElementById('fMetric').innerHTML = document.getElementById('txtMetric').value;
                            document.getElementById('fGranularity').innerHTML = document.getElementById('txtGranularity').value;
                            //Show results.
                            $("#divURLError").hide();
                            $("#divGraphs").show();
                            $("#imgLoading").hide();    
                            $("#btnSubmit").show();                            
                          }  
                       },
              error: function(xhr, status, error) {
                         $("#imgLoading").hide();    
                         $("#btnSubmit").show(); 
                         $("#divGraphs").hide();
                         $("#divURLError").show();                         
                     }    
          });
       }; // ELSE.          
   };
   
   function getGranularity(psInterval) {
    var sResult = "";
    if (psInterval == "hour"){
      sResult = "%H:%M";
    };
    if (psInterval == "2hr"){
      sResult = "%H:%M";
    }
    if (psInterval == "4hr"){
      sResult = "%H:%M";
    }
    if (psInterval == "day"){
      sResult = "%a %H:%M";
    }
    if (psInterval == "week"){
      sResult = "%a";
    }
    if (psInterval == "month"){
      sResult = "${ _('Week') } %U";
    }
    if (psInterval == "year"){
      sResult = "%b";
    }
    return sResult;
   }

   function getGraph0(pjson, psName, psInterval) {
      var aValues0 = [];  
      var iMax0 = 1;    
      var jsonValues = JSON.parse(pjson);   
   
      if (jsonValues.length > 0) {  
         for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
            var data0 = new Date(1000 * jsonValues[0].datapoints[i][1]);
            aValues0.push({x: data0, y: jsonValues[0].datapoints[i][0].toFixed(2)});
            if (jsonValues[0].datapoints[i][0] > iMax0) {
              iMax0 = jsonValues[0].datapoints[i][0];
            }
         };
      };
   
      aData0 = [{
         values: aValues0,
         key: psName,
         area: true
       }];
      
      if (aData0[0].values.length > 0){
        $("#divNoData0").hide();
        $("#graph0").show();

        nv.addGraph(function() {
          var graph0 = nv.models.lineChart()
                         .noData("${ _('No data available') }")
                         .margin({top: 15, right:50, left:60, bottom: 40})  //Adjust graph margins to give the x-axis some breathing room.                                  
                         .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                         .transitionDuration(350)        //how fast do you want the lines to transition?
                         .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                         .tooltips(true)                 //Show tooltip.
                         .showYAxis(true)                //Show the y-axis                       
                         .showXAxis(true)               //Show the x-axis
                         .forceY([0,iMax0]); 

             graph0.yAxis                     
                   .axisLabel('Messages')                     
                   .tickFormat(d3.format('.1s'));

             graph0.xAxis                     
                   .tickFormat(function(d) { return d3.time.format(psInterval)(new Date(d)); });

             d3.select('#graph0 svg') //Select the <svg> element you want to render the graph in.   
               .datum(aData0)         //Populate the <svg> element with graph data...
               .call(graph0);         //Finally, render the graph!

             //Update the graph when window resizes.
             nv.utils.windowResize(function() { graph0.update() });
             return graph0;
        });
      }
      else{
          $("#divNoData0").show();
          $("#graph0").hide();
      }   
   }; // END getGraph0.
   
   function getGraph1(pjson, psName, psInterval) {
      var aValues1 = [];  
      var iMax1 = 1;
      jsonValues = JSON.parse(pjson);   
   
      if (jsonValues.length > 0) {
         for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
            var data1 = new Date(1000 * jsonValues[0].datapoints[i][1]);
            aValues1.push({x: data1, y: jsonValues[0].datapoints[i][0].toFixed(2)});
            if (jsonValues[0].datapoints[i][0] > iMax1) {
              iMax1 = jsonValues[0].datapoints[i][0];
            }
         };
      };

      aData1 = [{
         values: aValues1,
         key: psName,
         area: true
       }];

      if (aData1[0].values.length > 0){
        $("#divNoData1").hide();
        $("#graph1").show();
      
        nv.addGraph(function() {
          var graph1 = nv.models.lineChart()
                         .noData("${ _('No data available') }")
                         .margin({top: 15, right:50, left:60, bottom: 40})            //Adjust graph margins to give the x-axis some breathing room.
                         .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                         .transitionDuration(350)        //how fast do you want the lines to transition?
                         .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                         .tooltips(true)                 //Show tooltip.
                         .showYAxis(true)                //Show the y-axis
                         .showXAxis(true)               //Show the x-axis 
                         .forceY([0,iMax1]);  
                                                       
             graph1.yAxis 
                   .axisLabel('Messages')
                   .tickFormat(d3.format('.1s'));

             graph1.xAxis                     
                   .tickFormat(function(d) { return d3.time.format(psInterval)(new Date(d)); });
  
             d3.select('#graph1 svg') //Select the <svg> element you want to render the graph in.   
               .datum(aData1)         //Populate the <svg> element with graph data...
               .call(graph1);         //Finally, render the graph!

             //Update the graph when window resizes.
             nv.utils.windowResize(function() { graph1.update() });
             return graph1;
        });
      }
      else {
          $("#divNoData1").show();
          $("#graph1").hide();
      }
   }; // END getGraph1.  

   function getGraph2(pjson, psName, psInterval) {   
      var aValues2 = [];  
      var iMax2 = 1;
      jsonValues = JSON.parse(pjson);   
   
      if (jsonValues.length > 0) {
         for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
            var data2 = new Date(1000 * jsonValues[0].datapoints[i][1]);
            aValues2.push({x: data2, y: jsonValues[0].datapoints[i][0].toFixed(2)});
            if (jsonValues[0].datapoints[i][0] > iMax2) {
              iMax2 = jsonValues[0].datapoints[i][0];
            }
         };
      };
   
      aData2 = [{
         values: aValues2,
         key: psName,
         area: true
       }];
    
      if (aData2[0].values.length > 0){
          $("#divNoData2").hide();
          $("#graph2").show();

          nv.addGraph(function() {
            var graph2 = nv.models.lineChart()
                           .noData("${ _('No data available') }")
                           .margin({top: 15, right:50, left:60, bottom: 40})            //Adjust graph margins to give the x-axis some breathing room.
                           .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                           .transitionDuration(350)        //how fast do you want the lines to transition?
                           .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                           .tooltips(true)                 //Show tooltip.
                           .showYAxis(true)                //Show the y-axis
                           .showXAxis(true)                //Show the x-axis                                       
                           .forceY([0,iMax2]); 

             graph2.yAxis 
                   .axisLabel('Messages')
                   .tickFormat(d3.format('.1s'));

             graph2.xAxis                  
                   .tickFormat(function(d) { return d3.time.format(psInterval)(new Date(d)); });
  
             d3.select('#graph2 svg') //Select the <svg> element you want to render the graph in.   
               .datum(aData2)         //Populate the <svg> element with graph data...
               .call(graph2);         //Finally, render the graph!

             //Update the graph when window resizes.
             nv.utils.windowResize(function() { graph2.update() });
             return graph2;
        });
      }
      else {
          $("#divNoData2").show();
          $("#graph2").hide();
      }
   }; // END getGraph2.  
   
   function getGraph3(pjson, psName, psInterval) {   
      var aValues3 = []; 
      var iMax3 = 1; 
      jsonValues = JSON.parse(pjson);   

      if (jsonValues.length > 0) {
         for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
            var data3 = new Date(1000 * jsonValues[0].datapoints[i][1]);
            aValues3.push({x: data3, y: jsonValues[0].datapoints[i][0].toFixed(2)});             
            if (jsonValues[0].datapoints[i][0] > iMax3) {
              iMax3 = jsonValues[0].datapoints[i][0];
            }    
         };
      };

      
      aData3 = [{
         values: aValues3,
         key: psName,
         area: true
       }];

      if (aData3[0].values.length > 0){
          $("#divNoData3").hide();
          $("#graph3").show();
           
          nv.addGraph(function() {
            var graph3 = nv.models.lineChart()
                           .noData("${ _('No data available') }")
                           .margin({top: 15, right:50, left:60, bottom: 40})            //Adjust graph margins to give the x-axis some breathing room.
                           .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                           .transitionDuration(350)        //how fast do you want the lines to transition?
                           .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                           .tooltips(true)                 //Show tooltip.
                           .showYAxis(true)                //Show the y-axis
                           .showXAxis(true)                //Show the x-axis                                       
                           .forceY([0,iMax3]); 

             graph3.yAxis 
                   .axisLabel('Messages')
                   .tickFormat(d3.format('.1s'));

             graph3.xAxis                  
                   .tickFormat(function(d) { return d3.time.format(psInterval)(new Date(d)); });
  
             d3.select('#graph3 svg') //Select the <svg> element you want to render the graph in.   
               .datum(aData3)         //Populate the <svg> element with graph data...
               .call(graph3);         //Finally, render the graph!

             //Update the graph when window resizes.
             nv.utils.windowResize(function() { graph3.update() });
             return graph3;
        });
      }
      else {
          $("#divNoData3").show();
          $("#graph3").hide();
      }
   }; // END getGraph3.  
   
   function getGraph4(pjson, psName, psInterval) {
      var aValues4 = []; 
      var iMax4 = 1; 
      jsonValues = JSON.parse(pjson);   
   
      if (jsonValues.length > 0) {
         for (var i=0; i<Object.keys(jsonValues[0].datapoints).length; i++) {
            var data4 = new Date(1000 * jsonValues[0].datapoints[i][1]);
            aValues4.push({x: data4, y: jsonValues[0].datapoints[i][0].toFixed(2)});
            if (jsonValues[0].datapoints[i][0] > iMax4) {
              iMax4 = jsonValues[0].datapoints[i][0];
            }
         };
      }; 
   
      aData4 = [{
         values: aValues4,
         key: psName,
         area: true
       }];

      if (aData4[0].values.length > 0){
          $("#divNoData4").hide();
          $("#graph4").show();

          nv.addGraph(function() {
            var graph4 = nv.models.lineChart()
                           .noData("${ _('No data available') }")
                           .margin({top: 15, right:50, left:60, bottom: 40})            //Adjust graph margins to give the x-axis some breathing room.
                           .useInteractiveGuideline(true)  //We want nice looking tooltips and a guideline!
                           .transitionDuration(350)        //how fast do you want the lines to transition?
                           .showLegend(true)               //Show the legend, allowing users to turn on/off line series.
                           .tooltips(true)                 //Show tooltip.
                           .showYAxis(true)                //Show the y-axis
                           .showXAxis(true)                //Show the x-axis                                       
                           .forceY([0,iMax4]); 
                  
             graph4.yAxis 
                   .axisLabel('Messages')
                   .tickFormat(d3.format('.1s'));

             graph4.xAxis                                        
                   .tickFormat(function(d) { return d3.time.format(psInterval)(new Date(d)); });
  
             d3.select('#graph4 svg') //Select the <svg> element you want to render the graph in.   
               .datum(aData4)         //Populate the <svg> element with graph data...
               .call(graph4);         //Finally, render the graph!

             //Update the graph when window resizes.
             nv.utils.windowResize(function() { graph4.update() });
             return graph4;
        });
      }
      else {
          $("#divNoData4").show();
          $("#graph4").hide();
      }
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

<!-- Div Error when no data in some graph. -->
<%def name="divErrorNoData(psGraph, psName)">
  <div id="divNoData${psGraph}" class="alert hide">
    <table align="center" valign="middle" width="90%" height="100%" border="0" cellpadding="6" cellspacing="0">
       <tr>
          <td>
              <i class="fa fa-exclamation-triangle"></i>
              ${ _('No data available for ') } <b>${psName} ${ _('Graph. ') }</b>${ _('Suggestions') }
          </td>
       </tr>
       <tr>
          <td>
            <ul>
              <li>${ _('Try different host.') }</li>
              <li>${ _('Try different topic.') }</li>
              <li>${ _('Try different metric.') }</li>
              <li>${ _('Try different granularity.') }</li>
            </ul>
          </td>
       </tr>
    </table>    
  </div>
</%def>

<div class="container-fluid">
  <div class="card">
     <h2 class="card-heading simple">${ _('Dashboard of Kakfa cluster:') } ${ cluster['id'] }</h2>
     <div class="card-body">
          % if error_zk_topics == 0 and error_zk_brokers == 0:
            <div class="alert alert-info">${ _('The zookeper REST server:') } <b>${cluster['zk_rest_url']}</b></div>
            % if not brokers:
              <div class="alert alert-error">
                ${ _('Can\'t retrive brokers list.') } <br>
              </div>
            % endif
            % if not topics:
              <div class="alert alert-error">
                ${ _('Can\'t retrive topics list.') } <br>
              </div>
            % endif
            % if metrics == []:
              <div class="alert alert-error">
                ${ _('Can\'t retrive metrics list.') } <br>
              </div>
            % endif    
          % else:
            <div class="alert alert-error">
              ${ _('Error connecting to the zookeper REST server:') } <b>${cluster['zk_rest_url']}</b><br>
              % if error_zk_brokers == 1:
                ${ _('Can\'t retrive brokers list.') } <br>
              % endif
              % if error_zk_topics == 1:
                ${ _('Can\'t retrive topics list.') } <br>
              % endif
              ${ _('Please contact your administrator to solve this.') }
            </div>  
          % endif
        <form id="frmFilterMetric" method="post" enctype="multipart/form-data" action="/kafka/${ cluster['id'] }/dashboard/">
        <table width="100%" height="100%" border="0" cellpadding="6" cellspacing="0">
           <tr valign="top">
              <td width="20%" rowspan="2">
                 <div class="panel panel-default">
                    <div class="panel-heading">
                       <i class="fa fa-desktop fa-fw"></i> ${ _('Host')}
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
                       <i class="fa fa-desktop fa-fw"></i> ${ _('Topics') }
                    </div>
                    <div class="panel-body">
                       <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                          <tr>
                             <td>
                                <input id="txtTopic" name="txtTopic" type="text" autocomplete="off" placeholder="${ _('Search for topic(s)') }" style="width:90%;">
                             </td>
                          </tr>
                          <tr>
                             <td>
                                <select name="idTopics" id="idTopics" style="width:100%;" multiple>
                                   % if topics:
                                      <option value="*" onclick="changeValue('topic', '${ _('All topics') }')">
                                        ${ _('All Topics') }
                                      </option>
                                   % endif
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
                 <button id="btnSubmit" type="button" class="btn btn-primary" onclick="SetFilterMetric()">${ _('Submit') }</button>   
                 <img id="imgLoading" src="/static/art/spinner.gif" class="hide"/>                         
              </td>
           </tr> 
           </table>   

           <div id="divURLError" class="alert hide">
              <i class="fa fa-exclamation-triangle"></i>
                 ${ _('Possible errors, please contact your administrator to solve this:') }
                 <ul>
                    <li>${ _('Could not connect to Ganglia Server.') }</li>
                    <li>${ _('Metrics are missing or incorrect.') }</li>
                 </ul>
           </div>

           <div id="divGraphs" class="hide">
              <table width="100%" border="0" cellpadding="0" cellspacing="0">
                 <tr valign="top">
                    <td colspan="4">
                       <div class="panel panel-default">
                          <div class="panel-heading">
                             <i class="fa fa-tachometer fa-fw"></i>${ _('Metrics of Kakfa cluster') }                             
                          </div>
                          <div class="panel-body">
                             <table width="100%" border="0" cellpadding="10" cellspacing="0">
                                <tr>
                                   <td colspan="3">
                                      <table width="100%" border="0" cellpadding="10" cellspacing="0">
                                         <tr>
                                            <td width="50%">
                                              <div style="position:relative">
                                                 <div id="graph0"><svg style="min-height: 180px; margin: 10px auto"></svg></div>                                                 
                                                 ${divErrorNoData(0, 'Count')}
                                              </div>
                                            </td>                                   
                                            <td width="50%">
                                              <div style="position:relative">
                                                <div id="graph4"><svg style="min-height: 180px; margin: 10px auto"></svg></div>
                                                ${divErrorNoData(4, 'MeanRate')}
                                              </div>
                                            </td>
                                         </tr>
                                      </table>         
                                   </td>
                                </tr>
                                <tr>
                                   <td width="33%">
                                      <div style="position:relative">
                                        <div id="graph1"><svg style="min-height: 180px; margin: 10px auto"></svg></div>
                                        ${divErrorNoData(1, 'OneMinuteRate')}
                                      </div>
                                   </td>
                                   <td width="34%">
                                    <div style="position:relative">
                                      <div id="graph2"><svg style="min-height: 180px; margin: 10px auto"></svg></div>
                                      ${divErrorNoData(2, 'FiveMinuteRate')}
                                    </div>
                                   </td>
                                   <td width="33%">
                                    <div style="position:relative">
                                      <div id="graph3"><svg style="min-height: 180px; margin: 10px auto"></svg></div>
                                      ${divErrorNoData(3, 'FifteenMinuteRate')}
                                    </div>
                                   </td>
                                </tr>
                                <tr>
                                   <td colspan="3" align="center">
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
