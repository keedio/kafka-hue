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

<%def name="frmExport(pData)">
  <div class="pull-right">
    <form id="frmDownload" method="post" enctype="application/json" action="/kafka/download/">
        <button type="submit" name="json" title="${ _('Download as JSON') }"><i class="fa fa-file-code-o fa-1x"></i></button>
        <button type="submit" name="csv" title="${ _('Download as CSV') }"><i class="fa fa-file-text-o"></i></button>
        <button type="submit" name="xls" title="${ _('Download as XLS') }"><i class="fa fa-file-excel-o fa-1x"></i></button>
        <button type="submit" name="pdf" title="${ _('Download as PDF') }"><i class="fa fa-file-pdf-o fa-1x"></i></button>
        <input type="hidden" name="pData" id="pData" value="${pData}">
    </form>
  </div>
</%def>

<!-- Show an error -->
<%def name="divERROR(psError)">
  <div id="divError" class="hide" style="position: absolute; left: 10px;">
    <span class="label label-important"> ${ _('ERROR in form. ') } ${psError} </span>
  </div>
</%def>

<!-- New Window Modal. Create a topic -->
<%def name="tblCreateTopic()">
   <div class="modal hide fade" id="tblCreateTopic" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
      <div class="modal-dialog">
         <form id="frmCreateTopic" method="post" enctype="multipart/form-data" action="/kafka/_create_topic/">
            <div class="modal-content">
               <div class="modal-header">
                  <h3>${ _('Create a Topic') } </b></h3>
               </div>
               <div class="modal-body controls">
                <table width="97%" height="100%" border="0" cellpadding="6" cellspacing="0">                  
                  <tr>
                    <td colspan="2">
                      <label>${ _('Topic') }</label>
                      <input type="text" id="sTopicName" class="input-large search-query" placeholder="${_('Name of the topic')}" style="width: 100%;">
                      <div id="divErrorTopic" class="hide">
                        <span class="label label-important"> ${ _('Select a name for the topic. ') } </span>
                      </div>
                    </td>                    
                  </tr>
                  <tr>
                    <td colspan="2">
                      <label>${ _('Zookeepers') }</label>
                      <input type="text" id="sZookeepers" class="input-large search-query" placeholder="${_('List of zookeepers. E.G. localhost:2181')}" style="width: 100%;">
                      <div id="divErrorZookeeper" class="hide">
                        <span class="label label-important"> ${ _('Select a zookeeper(s). ') }</span>
                      </div>
                    </td>                    
                  </tr>
                  <tr>
                    <td>
                      <label>${ _('Set Replication Factor') }</label>
                      <input type="number" id="iReplicationFactor" min="1" value=1 style="width: 90%;"/>
                      <div id="divErrorReplication" class="hide">
                        <span class="label label-important"> ${ _('Select a replication factor. By default is 1. ') }</span>
                      </div>
                    </td>
                    <td>
                      <label>${ _('Set Partitions') }</label>
                      <input type="number" id="iPartitions" min="1" value=1 style="width: 100%;"/>
                      <div id="divErrorPartitions" class="hide">
                        <span class="label label-important"> ${ _('Select partition(s). By default is 1. ') } </span>
                      </div>
                    </td>
                  </tr>
                </table>
               </div>
               <div class="modal-footer">  
                  <div id="divError" class="hide" style="position: absolute; left: 10px;">
                    <span id="spnError" class="label label-important"> ${ _('ERROR when create topic ') }  </span>                    
                  </div>
                  <div id="divResult" class="hide" style="position: absolute; left: 10px;">
                    <span id="spnResult" class="label label-info"> </span>                    
                  </div>
                  <input type="hidden" name="psAction" value="createTopic">
                  <input type="hidden" name="psURL" value="${request.get_full_path()}">                  
                  <button type="button" class="btn btn-default" data-dismiss="modal">${ _('Cancel') }</button>                  
                  <button type="button" id="btnSubmit" class="btn btn-primary" onclick="create_topic()">${ _('Create') }</button>
                  <img id="imgLoading" src="/static/art/spinner.gif" class="hide"/>
               </div>
            </div>   
         </form>      
      </div>
   </div>
</%def>