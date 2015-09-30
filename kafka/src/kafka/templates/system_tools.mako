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

${commonheader("SystemTools", app_name, user) | n,unicode}

<link href="${ static('kafka/css/kafka.css') }" rel="stylesheet" >
<script src="${ static('desktop/ext/js/knockout.min.js') }" type="text/javascript" charset="utf-8"></script>
<script src="${ static('kafka/js/jquery.smart_autocomplete.js') }" type="text/javascript" charset="utf-8"></script>
<script src="${ static('desktop/ext/js/datatables-paging-0.1.js') }" type="text/javascript" charset="utf-8"></script>

<style>
    ul.smart_autocomplete_container li {list-style: none; cursor: pointer;}
    li.smart_autocomplete_highlight {background-color: #F6F6F6;}
    ul.smart_autocomplete_container { margin: 0; padding: 5px; background-color: #DBDBDB; min-height: 100px;}
</style>

<script type="text/javascript" charset="utf-8">   
    var SystemToolsModel = function(data){
      var self = this;
      
      self.value = ko.observable(data.value);
      self.name = ko.observable(data.name);
    }; //SystemToolsModel
  
    function ViewModel(data) {
     var self = this;     
     
     self.sBroker = ko.observable();     
     self.selectedValue = ko.observable(); 

     self.tools = ko.observableArray([
          new SystemToolsModel({value: "0", name: "${_('Choose a system tool...')}"}),
          new SystemToolsModel({value: "1", name: "kafka.tools.GetOffsetShell"})]);     

     self.changeValue = function (psType, psValue) {
        var sElement = '';         
      
        if (psType == 'broker'){
           sElement = 'txtBroker';    
        }
        if (psType == 'topic'){
           sElement = 'txtTopic';
        }      
        if (psType == 'time'){
           sElement = 'txtTime';
        }

        document.getElementById(sElement).value = psValue;
      }; //changeValue

      var setTableOffsets = function (pData) { 
        var dataTable = $('#offsetsTable').dataTable( {
          "sPaginationType":"bootstrap",
          "bLengthChange":true,
          "bRetrieve": true,
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
        });

        var aData = pData.split("\n");      
        var aTable = [];      
        dataTable.fnClearTable();
        for (var i = 0; i < aData.length - 1; i++) {        
          aTable.push([aData[i].split(":")[0],aData[i].split(":")[1], aData[i].split(":")[2]]);
        };      
        dataTable.fnAddData(aTable);
      }; //setTableOffsets

      self.GetSystemTool = function() {      
        $("#divErrorOption").hide();
        $("#divErrorBroker").hide();  
        $("#divErrorTopic").hide();      
        $("#divErrorTime").hide();
      
        if (self.selectedValue() == 0) {
          $("#divErrorOption").show();
        }   
        else if ($('#txtBroker').val() == "") {
          $("#divErrorBroker").show();
        }
        else if ($('#txtTopic').val() == "") {
          $("#divErrorTopic").show();
        }      
        else if ($('#txtTime').val() == "") {
          $("#divErrorTime").show();
        }            
        else  { 
           $("#imgLoading").show();
           $("#btnSubmit").hide();         
           $.ajax({
                url: "/kafka/${ Data['cluster']['id'] }/system_tools/",           
                dataType: 'json',   
                data: { txtOption: $("#txtOptions option[value='" + self.selectedValue() + "']").text(),
                        txtTopic: $('#txtTopic').val(),
                        txtBroker: $('#txtBroker').val(),
                        txtTime: $('#txtTime').val(),
                        numWaitTime: $('#numWaitTime').val(),
                        numOffset: $('#numOffset').val(),
                        txtPartitions: $('#txtPartitions').val()
                        },
                method: 'POST',
                success: function(response) {                
                            if (response.Data.error != "") {
                              $("#imgLoading").hide();    
                              $("#btnSubmit").show(); 
                              $("#divResults").hide();
                              $("#divCMD").hide();
                              $("#divResultErrors").show();
                              document.getElementById("divShowErrors").innerHTML = response.Data.error;
                              document.getElementById("divCMDTextErrors").innerHTML = response.Data.cmd;
                            }
                            else {                              
                              setTableOffsets(response.Data.output);
                              $("#divCMD").show();
                              document.getElementById("divCMD").innerHTML = response.Data.cmd;
                              $("#divResultErrors").hide();
                              $("#divResults").show();
                              $("#imgLoading").hide();    
                              $("#btnSubmit").show();
                            }  
                         },
                error: function(xhr, status, error) {
                           $("#divResults").hide();
                           $("#divCMD").hide();
                           $("#divResultErrors").show();
                           document.getElementById("divShowErrors").innerHTML = error;
                           document.getElementById("divCMDTextErrors").innerHTML = response.Data.cmd;
                           $("#imgLoading").hide();    
                           $("#btnSubmit").show(); 
                        
                       }    
            });
        }; // ELSE.          
      }; //GetSystemTool.
    }; // ViewModel.  

  $(document).ready(function () {
    var viewModel = new ViewModel();
    ko.applyBindings(viewModel);

    $("#txtBroker").smartAutoComplete({ 
      source: "/kafka/${ Data['cluster']['id'] }/getjson/broker", 
      maxResults: 5,
      delay: 100
    });

    $("#txtBroker").bind({
      keyIn: function(ev){
        var tag_list = ev.smartAutocompleteData.query.split(","); 
        ev.smartAutocompleteData.query = $.trim(tag_list[tag_list.length - 1]);
      },

      itemSelect: function(ev, selected_item){ 
        var options = $(this).smartAutoComplete();
        var selected_value = $(selected_item).text();
        var cur_list = $(this).val().split(","); 
        
        cur_list[cur_list.length - 1] = selected_value;
        $(this).val(cur_list.join(",") + ","); 
        options.setItemSelected(true);
        $(this).trigger('lostFocus');
        ev.preventDefault();
      },
    });

    $("#txtTopic").smartAutoComplete({
      source: "/kafka/${ Data['cluster']['id'] }/getjson/topic",  
      maxResults: 5, 
      delay: 100 ,
      forceSelect: true
    }); 

    $("a.btn-date").click(function () {
      $("a.btn-date").not(this).removeClass("active");
      $(this).toggleClass("active");
    });
  });
</script>

<%
  _breadcrumbs = [
    ["Clusters", url('kafka:index')],
    [Data['cluster']['nice_name'].lower(), url('kafka:cluster', cluster_id=Data['cluster']['id'])],
    ["System Tools", url('kafka:system_tools', cluster_id=Data['cluster']['id'])]
  ]
%>

% if not Data['cluster']:
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

${ kafka.menubar(section='SystemTools',c_id=Data['cluster']['id']) }

<div class="container-fluid">
  <div class="card">
    <h2 class="card-heading simple">${ _('System Tools of Kakfa cluster:') } ${ Data['cluster']['id'] }</h2>
    <div class="card-body">
      % if Data['error_zk_topics'] == 0 and Data['error_zk_brokers'] == 0:
        <div class="alert alert-info">${ _('Zookeper server(s):') } <b>${Data['cluster']['zk_host_ports']}</b></div>
        % if not Data['brokers']:
          <div class="alert alert-error">
            ${ _('Can\'t retrive brokers list.') } <br>
          </div>
        % endif
        % if not Data['topics']:
          <div class="alert alert-error">
            ${ _('Can\'t retrive topics list.') } <br>
          </div>
        % endif        
      % else:
        <div class="alert alert-error">
          ${ _('Error connecting to zookeper server(s):') } <b>${Data['cluster']['zk_host_ports']}</b><br>
          % if Data['error_zk_brokers'] == 1:
            ${ _('Can\'t retrive brokers list.') } <br>
          % endif
          % if Data['error_zk_topics'] == 1:
            ${ _('Can\'t retrive topics list.') } <br>
          % endif
          ${ _('Please contact your administrator to solve this.') }
        </div>  
      % endif  

      <form id="frmSystemTools" method="post" enctype="multipart/form-data" action="/kafka/${ Data['cluster']['id'] }/system_tools/">
        <table width="100%" height="100%" border="0" cellpadding="6" cellspacing="0">
          <tr valign="top">
            <td colspan="2">
              <div class="panel panel-default">
                <div class="panel-heading">
                  <i class="fa fa-wrench fa-fw"></i> ${ _('System Tool') }
                </div>
                <div class="panel-body">                                    
                  <select class="input-medium chosen-select chosen-db" id="txtOptions" 
                          data-bind="options: tools, 
                                     optionsText: 'name', 
                                     optionsValue: 'value',                                     
                                     value: selectedValue" style="width: 100%"></select>
                  <div id="divErrorOption" class="hide">
                    <span class="label label-important"> ${ _('System tool required.') } </span>
                  </div>
                </div>
              </div>
            </td>
            <td rowspan="2">
              <div class="panel panel-default">
                <div class="panel-heading">
                  <i class="fa fa-cogs fa-fw"></i> ${ _('Options') }
                </div>
                <div class="panel-body">
                  <table width="100%" height="100%" border="0" cellpadding="6" cellspacing="6">
                    <tr>
                      <td>                                   
                        <span class="btn-group" style="float:left">                                                       
                          <a class="btn btn-date btn-info" data-bind="click: function() { changeValue('time', '-2') }">${ _('Earliest') }</a>
                          <a class="btn btn-date btn-info" data-bind="click: function() { changeValue('time', '-1') }">${ _('Latest') }</a>                                   
                          <input type="hidden" id="txtTime" name="txtTime" value="">
                        </span>
                        <div id="divErrorTime" class="hide">
                          <span class="label label-important"> ${ _('Time filter required.') } </span>
                        </div>
                      </td>
                    </tr>                    
                    <tr>
                      <td>           
                        <label title="${_('The max amount of time each fetch request waits (default 1000)')}">${ _('Wait Time') }</label>
                        <input type="number" id="numWaitTime" min="1" value=1000 style="width: 96%;"/>
                      </td>
                    </tr>
                    <tr>
                      <td>           
                        <label title="${_('Number of offsets returned (default 1)')}">${ _('Offsets') }</label>
                        <input type="number" id="numOffset" min="1" value=1 style="width: 96%;"/>
                      </td>
                    </tr>
                    <tr>
                      <td>           
                        <label title="${_('Comma separated list of partition ids. If not specified, will find offsets for all partitions (default)')}">${ _('Partitions') }</label>
                        <input type="text" id="txtPartitions" class="input-large search-query" placeholder="${_('Comma separated list of partition ids...')}" style="width: 96%;">
                      </td>
                    </tr>
                  </table>                           
                </div>
              </div>
            </td>
          </tr>
          <tr valign="top">
            <td>
              <div class="panel panel-default">
                <div class="panel-heading">
                  <i class="fa fa-desktop fa-fw"></i> ${ _('Broker')}
                </div>
                <div class="panel-body">
                  <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                      <td>                        
                        <input id="txtBroker" type="text" autocomplete="off" data-bind="textInput: sBroker" placeholder="${ _('Comma separated list of broker(s)...') }" style="width:90%;"/>                        
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <select name="idBrokers" id="idBrokers" style="width:100%;" multiple="true">
                          % for broker in Data['brokers']:                          
                            <option value="${broker['host']}" data-bind="click: function() { changeValue('broker', '${broker['host']}') }">${broker['host']}</option>
                          % endfor                                      
                        </select>
                      </td>
                    </tr>
                    <div id="divErrorBroker" class="hide">
                      <span class="label label-important"> ${ _('Broker required.') } </span>
                    </div>
                  </table>                                          
                </div>
              </div>
            </td>
            <td>
               <div class="panel panel-default">
                  <div class="panel-heading">
                     <i class="fa fa-desktop fa-fw"></i> ${ _('Topics') }
                  </div>
                  <div class="panel-body">
                     <table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0">
                        <tr>
                           <td>
                              <input id="txtTopic" type="text" autocomplete="off" placeholder="${ _('Search for topic(s)') }" style="width:90%;">
                           </td>
                        </tr>
                        <tr>
                           <td>
                              <select name="idTopics" id="idTopics" style="width:100%;" multiple="true">                                 
                                % for topic in Data['topics']:                                
                                  <option value="${topic['id']}" data-bind="click: function() { changeValue('topic', '${topic['id']}') }">${topic['id']}</option>
                                % endfor                                         
                              </select>
                           </td>
                        </tr>
                        <div id="divErrorTopic" class="hide">
                           <span class="label label-important"> ${ _('Topic required.') } </span>
                        </div>
                     </table>                                                       
                  </div>
               </div>
            </td>
          </tr>
          <tr valign="top" align="right">
            <td colspan="3">              
              <button id="btnSubmit" type="button" class="btn btn-primary" data-bind="click: function() { GetSystemTool() }">${ _('Submit') }</button>
              <div id="imgLoading" class="widget-spinner" style="display:none">
                <!--[if !IE]> --><i class="fa fa-spinner fa-spin fa-2x"></i><!-- <![endif]-->
                <!--[if IE]><img src="${ static('kafka/art/spinner.gif') }" /><![endif]-->
              </div>
            </td>
          </tr> 
        </table>
      </form>

      <div id="divResultErrors" class="alert hide">
        <i class="fa fa-exclamation-triangle"></i>
        ${ _('Errors, please contact your administrator to solve this:') }
        <ul>
          <li><div id="divCMDTextErrors"></div></li>                    
          <li><div id="divShowErrors"></div></li>                    
        </ul>
      </div>

      <div id="divResults" class="hide">
        <table class="table datatables table-striped table-hover table-condensed" id="offsetsTable" data-tablescroller-disable="true">
          <thead>
            <tr>
              <th>${ _('Topic') }</th>
              <th>${ _('Start') }</th>
              <th>${ _('End') }</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td></td>
              <td></td>
              <td></td>
            </tr>
          </tbody>
        </table>
      </div>

      <div id="divCMD" class="alert alert-info hide">        
      </div>      
    </div>     
  </div>
</div>
${commonfooter(messages) | n,unicode}
