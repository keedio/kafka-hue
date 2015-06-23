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