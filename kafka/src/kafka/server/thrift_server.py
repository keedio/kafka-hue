#!/usr/bin/env python
    
port = 9090
  
import sys, os
import subprocess

# your gen-py dir
sys.path.append(os.path.join(os.path.dirname(__file__), '../../../gen-py'))
  
from topics import *
from topics.ttypes import *
  
# Thrift files
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer

#response = subprocess.Popen(['/usr/lib/kafka/bin/kafka-create-topic.sh', '--zookeeper', zookeepers, '--replication-factor', replication, '--partitions', partitions, '--topic', topic],stdout=subprocess.PIPE, stderr=subprocess.PIPE)

# Server implementation
class TopicsHandler:
    def createTopic(self, zookeepers, replication, partitions, topic):
        response = subprocess.Popen(['/usr/lib/kafka/bin/kafka-topics.sh', '--create', '--zookeeper', zookeepers, '--replication-factor', str(replication), '--partitions', str(partitions), '--topic', topic],stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output,err = response.communicate()
        return str(output)
  
# set handler to our implementation
handler = TopicsHandler()
processor = Topics.Processor(handler)
transport = TSocket.TServerSocket(port = port)
tfactory = TTransport.TBufferedTransportFactory()
pfactory = TBinaryProtocol.TBinaryProtocolFactory()
  
# set server
server = TServer.TThreadedServer(processor, transport, tfactory, pfactory)
  
print 'Starting server on port',port
server.serve()