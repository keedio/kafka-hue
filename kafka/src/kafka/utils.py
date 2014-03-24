from django.http import Http404

from kafka.conf import CLUSTERS


def get_cluster_or_404(id):
  try:
    name = id
    cluster = CLUSTERS.get()[name]
  except (TypeError, ValueError):
    raise Http404()

  cluster = {
    'id': id,
    'nice_name': id,
    'zk_host_ports': cluster.ZK_HOST_PORTS.get(),
    'zk_rest_url': cluster.ZK_REST_URL.get(),
    'brokers_path' : cluster.BROKERS_PATH.get(),
    'consumers_path' : cluster.CONSUMERS_PATH.get(),
  }

  return cluster