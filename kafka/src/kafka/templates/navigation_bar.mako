<%!
  from django.utils.translation import ugettext as _
%>

<%!
def is_selected(section, matcher):
  if section == matcher:
    return "active"
  else:
    return ""
%>

<%def name="header(breadcrumbs, clusters, withBody=True)">
  <div class="container-fluid">
  <div class="row-fluid">
    <div class="card card-small">
      <h1 class="card-heading simple">
        <div class="btn-group pull-right">
          <a class="btn dropdown-toggle" data-toggle="dropdown" href="#">
            ${ _('Go to cluster') }
            <span class="caret"></span>
          </a>
          <ul class="dropdown-menu">
            % for cluster in clusters:
              <li>
                ##<a href="${ url('zookeeper:view', id=cluster['cluster']) }">
                ## TODO - Link to a index (topology) view of the cluster. Modify view input params
                <a href="#">
                  ${ cluster['cluster'] }
                </a>
              </li>
            % endfor
          </ul>
        </div>
      % for idx, crumb in enumerate(breadcrumbs):
        %if crumb[1] != "":
          <a href="${crumb[1]}">${crumb[0]}</a>
        %else:
          ${crumb[0]}
        %endif

        %if idx < len(breadcrumbs) - 1:
          &gt;
        %endif
      % endfor
      </h1>
      %if withBody:
      <div class="card-body">
        <p>
      %endif
</%def>

<%def name="menubar(section='')">
  <div class="navbar navbar-inverse navbar-fixed-top nokids">
    <div class="navbar-inner">
      <div class="container-fluid">
        <div class="nav-collapse">
          <ul class="nav">
            <li class="currentApp">
              <a href="/${app_name}">
                <img src="/kafka/static/art/icon_kafka_24.png" />
                Kafka
              </a>
             </li>
             <li class="${is_selected(section, 'Topology')}"><a href=${url('kafka:index')}>Topology</a></li>
             <li class="${is_selected(section, 'Consumer Groups')}"><a href="#">Consumer Groups</a></li>
             <li class="${is_selected(section, 'Topics')}"><a href="#">Topics</a></li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</%def>
