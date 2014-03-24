# distributed with this work for additional information
# regarding copyright ownership.  Cloudera, Inc. licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from desktop.lib.conf import Config, UnspecifiedConfigSection, ConfigSection

# URL = Config(
#   key="zookeeper_list",
#   default="",
#   help="The URL that is proxied inside the app.",
#   type=str
# )

def coerce_string(value):
  if type(value) == list:
    return ','.join(value)
  else:
    return value

CLUSTERS = UnspecifiedConfigSection(
  "clusters",
  help="One entry for each Zookeeper cluster",
  each=ConfigSection(
    help="Information about a single Zookeeper cluster",
    members=dict(
        ZK_HOST_PORTS=Config(
          "zk_host_ports",
          help="Zookeeper ensemble. Comma separated list of Host/Port, e.g. localhost:2181,localhost:2182,localhost:2183",
          default="localhost:2181",
          type=coerce_string,
        ),
        ZK_REST_URL=Config(
          "zk_rest_url",
          help="The URL of the REST contrib service.",
          default="http://localhost:9998",
          type=str,
        ),
        BROKERS_PATH=Config(
          "brokers_path",
          help=" Path to brokers info in Zookeeper Znode hierarchy, e.g. /brokers/ids",
          default="/brokers/ids",
          type=str,
        ),
        CONSUMERS_PATH=Config(
          "consumers_path",
          help=" Path to consumers info in Zookeeper Znode hierarchy, e.g. /consumers",
          default="/consumers",
          type=str,
        ),
    )
  )
)