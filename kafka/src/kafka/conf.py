# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
# http:# www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from desktop.lib.conf import Config, UnspecifiedConfigSection, ConfigSection
from django.utils.translation import ugettext_lazy as _t, ugettext as _

def coerce_string(value):
  if type(value) == list:
    return ','.join(value)
  else:
    return value

CLUSTERS = UnspecifiedConfigSection(
  key="clusters",
  help="One entry for each Zookeeper cluster",
  each=ConfigSection(
    help="Information about a single Zookeeper cluster",
    members=dict(
        ZK_HOST_PORTS=Config(
          key="zk_host_ports",
          help="Zookeeper ensemble. Comma separated list of Host/Port, e.g. localhost:2181,localhost:2182,localhost:2183",
          default="localhost:2181",
          type=coerce_string),       
        BROKERS_PATH=Config(
          key="brokers_path",
          help="Path to brokers info in Zookeeper Znode hierarchy, e.g. /brokers/ids",
          default="/brokers/ids",
          type=str),
        CONSUMERS_PATH=Config(
          key="consumers_path",
          help="Path to consumers info in Zookeeper Znode hierarchy, e.g. /consumers",
          default="/consumers",
          type=str),
        TOPICS_PATH=Config(
          key="topics_path",
          help="Path to topics info in Zookeeper Znode hierarchy, e.g. /brokers/topics",
          default="/brokers/topics",
          type=str),
        GANGLIA_SERVER = Config(
          key="ganglia_server",
          help="GANGLIA Server",
          default="http://localhost",
          type=str),
        GANGLIA_DATA_SOURCE = Config(
          key="ganglia_data_source",
          help="Ganglia Data Source",
          default="my cluster",
          type=str),
    )
  )
)

def config_validator(user):
  res = []
  
  for cluster in CLUSTERS:
    if not CLUSTERS[cluster].ZK_HOST_PORTS.get():
      res.append((CLUSTERS[cluster].ZK_HOST_PORTS, _("You must to specify Zookeeper ensemble.")))

    if not CLUSTERS[cluster].BROKERS_PATH.get():
      res.append((CLUSTERS[cluster].BROKERS_PATH, _("You must to specify path to brokers info.")))

    if not CLUSTERS[cluster].CONSUMERS_PATH.get():
      res.append((CLUSTERS[cluster].CONSUMERS_PATH, _("You must to specify path to consumers info.")))

    if not CLUSTERS[cluster].TOPICS_PATH.get():
      res.append((CLUSTERS[cluster].TOPICS_PATH, _("You must to specify path to topics info.")))

    if not CLUSTERS[cluster].GANGLIA_SERVER.get():
      res.append((CLUSTERS[cluster].GANGLIA_SERVER, _("You must to specify Ganglia Server I.P. or Ganglia Server HostName.")))

    if not CLUSTERS[cluster].GANGLIA_DATA_SOURCE.get():
      res.append((CLUSTERS[cluster].GANGLIA_DATA_SOURCE, _("You must to specify Ganglia Data Source name.")))

  return res