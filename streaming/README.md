
#Create Hbase Tables
```
create ‘measurement’,’cf1’
```

#Build a “generator -> Flume -> HBase” pipeline

```
# Name the components on this agent
agent1.sources = src1
agent1.sinks = sink1
agent1.channels = ch1

# Describe/configure the source
agent1.sources.src1.type = netcat
agent1.sources.src1.bind = 172.31.37.63
agent1.sources.src1.port = 44444
agent1.sources.src1.channels = ch1

# Describe the sink
agent1.sinks.sink1.type = org.apache.flume.sink.hbase.HBaseSink
agent1.sinks.sink1.table = measurements
agent1.sinks.sink1.columnFamily = cf1
agent1.sinks.sink1.serializer=org.apache.flume.sink.hbase.RegexHbaseEventSerializer
agent1.sinks.sink1.serializer.regex=^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$
agent1.sinks.sink1.serializer.colNames=measurement_id,detector_id,galaxy_id,astrophysicist_id,measurement_time,amplitude_1,amplitude_2,amplitude_3
agent1.sinks.sink1.batchSize = 100
agent1.sinks.sink1.channel = ch1


# Use a channel which buffers events in memory
agent1.channels.ch1.type = memory
agent1.channels.ch1.capacity = 10000000
agent1.channels.ch1.transactionCapacity = 1000000
```

#Build a “generator -> Flume -> Hdfs” pipeline


```

# Name the components on this agent
agent2.sources = src1
agent2.sinks = sink3
agent2.channels = ch2

# Describe/configure the source
agent2.sources.src1.type = netcat
agent2.sources.src1.bind =172.31.37.63
agent2.sources.src1.port = 44444
agent2.sources.src1.channels = ch2

# Describe the sink
agent2.sinks.sink3.type = hdfs
agent2.sinks.sink3.hdfs.path = /user/saturn/flumeMeasurements
agent2.sinks.sink3.channel = ch2
agent2.sinks.sink3.hdfs.rollInterval = 0
agent2.sinks.sink3.hdfs.rollSize = 125829120
agent2.sinks.sink3.hdfs.rollCount = 0
agent2.sinks.sink3.hdfs.fileType = DataStream


# Use a channel which buffers events in memory
agent2.channels.ch2.type = memory
agent2.channels.ch2.capacity = 10000000
agent2.channels.ch2.transactionCapacity = 1000000


```

#Create Kafka topic

```
kafka-topics --create --zookeeper 172.31.37.63:2181 --replication-factor 1 --partitions 1 --topic galaxy-measurements
```


#Kafka Channel with Hdfs sink


```
# Name the components on this agent
agent1.sources = src1
agent1.channels = ch1

# Describe/configure the source
agent1.sources.src1.type = netcat
agent1.sources.src1.bind = 172.31.37.63
agent1.sources.src1.port = 44444
agent1.sources.src1.channels = ch1

# Describe the sink
agent1.sinks.sink1.type = org.apache.flume.sink.hbase.HBaseSink
agent1.sinks.sink1.table = measurements
agent1.sinks.sink1.columnFamily = cf1
agent1.sinks.sink1.serializer=org.apache.flume.sink.hbase.RegexHbaseEventSerializer
agent1.sinks.sink1.serializer.regex=^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$
agent1.sinks.sink1.serializer.colNames=measurement_id,detector_id,galaxy_id,astrophysicist_id,measurement_time,amplitude_1,amplitude_2,amplitude_3
agent1.sinks.sink1.batchSize = 100
agent1.sinks.sink1.channel = ch1

# Use a channel which buffers events in memory
agent1.channels.ch1.type = org.apache.flume.channel.kafka.KafkaChannel
agent1.channels.ch1.capacity = 1000000
agent1.channels.ch1.zookeeperConnect =  172.31.37.63:2181
agent1.channels.ch1.parseAsFlumeEvent = false
agent1.channels.ch1.kafka.topic = galaxy-measurements
agent1.channels.ch1.kafka.consumer.group.id = galaxy-grp
agent1.channels.ch1.auto.offset.reset = earliest
agent1.channels.ch1.kafka.bootstrap.servers = 172.31.37.63:9092
agent1.channels.ch1.transactionCapacity = 100000
agent1.channels.ch1.kafka.consumer.max.partition.fetch.bytes=2097152

```

# Kafka Channel for Spark Streaming

```
# Name the components on this agent
agent1.sources = src1
agent1.channels = ch1

# Describe/configure the source
agent1.sources.src1.type = netcat
agent1.sources.src1.bind = 172.31.37.63
agent1.sources.src1.port = 44444
agent1.sources.src1.channels = ch1

# Use a channel which buffers events in memory
agent1.channels.ch1.type = org.apache.flume.channel.kafka.KafkaChannel
agent1.channels.ch1.capacity = 1000000
agent1.channels.ch1.zookeeperConnect =  172.31.37.63:2181
agent1.channels.ch1.parseAsFlumeEvent = false
agent1.channels.ch1.kafka.topic = galaxy-measurements
agent1.channels.ch1.kafka.consumer.group.id = galaxy-grp
agent1.channels.ch1.auto.offset.reset = earliest
agent1.channels.ch1.kafka.bootstrap.servers = 172.31.37.63:9092
agent1.channels.ch1.transactionCapacity = 100000
agent1.channels.ch1.kafka.consumer.max.partition.fetch.bytes=2097152

```

# Test spark streaming on spark console 

```
open spark shell -- It already has spark context so no need to initialize again from console. you need that in Scala,python or java code

import org.apache.spark.SparkConf
import org.apache.spark.streaming.StreamingContext
import org.apache.spark.streaming.Seconds
val ssc = new StreamingContext(sc, Seconds(10))
import org.apache.spark.streaming.kafka.KafkaUtils
val kafkaStream = KafkaUtils.createStream(ssc, "172.31.37.63:2181","galaxy-grp", Map("galaxy-measurements" -> 5))
kafkaStream.print()
ssc.start

```


# Hbase put Scala example 

```
import org.apache.hadoop.hbase.client._
import org.apache.hadoop.hbase.util.Bytes
import org.apache.hadoop.hbase.{CellUtil, HBaseConfiguration, TableName}
import org.apache.hadoop.conf.Configuration
import scala.collection.JavaConverters._


val conf : Configuration = HBaseConfiguration.create()

 conf.set("hbase.zookeeper.quorum", "172.31.37.63:2181");

 val connection = ConnectionFactory.createConnection(conf)
 val table = connection.getTable(TableName.valueOf( Bytes.toBytes("measurements") ) )

 var put = new Put(Bytes.toBytes("test1"))
 put.addColumn(Bytes.toBytes("cf1"), Bytes.toBytes("test_column_name"), Bytes.toBytes("test_value"))
 put.addColumn(Bytes.toBytes("cf1"), Bytes.toBytes("test_column_name2"), Bytes.toBytes("test_value2"))
 table.put(put)

```


#Build a “generator -> Flume -> Kafka -> Spark Streaming -> HBase” pipeline

```
use flume code for #Kafka Channel for Spark Streaming

Paste spark streaming code here

```
