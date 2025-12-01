#!/bin/bash
# Hadoop Cluster Test Script

echo "================================================"
echo "Hadoop Cluster Health Check"
echo "================================================"

# Wait for HDFS to be ready
echo "Waiting for HDFS to initialize..."
sleep 10

# Check HDFS status
echo -e "\n1. HDFS Status:"
hdfs dfsadmin -report

# Check YARN status
echo -e "\n2. YARN Node Status:"
yarn node -list

# Create test directory in HDFS
echo -e "\n3. Creating test directory in HDFS..."
hdfs dfs -mkdir -p /test

# List HDFS root
echo -e "\n4. HDFS Root Directory:"
hdfs dfs -ls /

# Create test file
echo -e "\n5. Creating test file..."
echo "Hadoop 3-node cluster test - $(date)" > /tmp/test.txt
hdfs dfs -put /tmp/test.txt /test/

# Verify replication
echo -e "\n6. Verifying replication factor:"
hdfs dfs -ls /test/
hdfs fsck /test/test.txt -files -blocks -locations

# Run a simple MapReduce job (Pi estimation)
echo -e "\n7. Running MapReduce Pi estimation test..."
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 2 100

echo -e "\n================================================"
echo "Cluster test completed!"
echo "================================================"
