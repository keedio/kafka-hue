namespace py topics

typedef i32 int 

service Topics {
	string createTopic(1:string zookeepers, 2:int replication, 3:int partitions, 4:string topic),
}
