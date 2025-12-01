# Quick Reference - Hadoop Cluster Commands

Cheat sheet untuk command yang sering digunakan.

## 🚀 Cluster Management

```bash
# Start cluster
docker-compose up -d

# Stop cluster
docker-compose down

# Restart cluster
docker-compose restart

# Check status
docker-compose ps

# View logs
docker-compose logs -f [service_name]
```

## 🔍 Health Checks

```bash
# HDFS cluster report
docker-compose exec namenode hdfs dfsadmin -report

# YARN nodes list
docker-compose exec resourcemanager yarn node -list

# Full health check
docker-compose exec resourcemanager bash /opt/test.sh
```

## 📁 HDFS Operations

```bash
# List files
docker-compose exec namenode hdfs dfs -ls /
docker-compose exec namenode hdfs dfs -ls /user/

# Create directory
docker-compose exec namenode hdfs dfs -mkdir -p /path/to/dir

# Upload file
docker-compose exec namenode hdfs dfs -put /local/path /hdfs/path

# Download file
docker-compose exec namenode hdfs dfs -get /hdfs/path /local/path

# Delete file
docker-compose exec namenode hdfs dfs -rm /hdfs/path

# Delete directory recursively
docker-compose exec namenode hdfs dfs -rm -r /hdfs/directory

# Check disk usage
docker-compose exec namenode hdfs dfs -du -h /

# Check file replication
docker-compose exec namenode hdfs fsck /path/to/file -files -blocks -locations
```

## 🧪 Testing & Examples

```bash
# Run MapReduce Pi example
docker-compose exec resourcemanager hadoop jar \
  $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  pi 2 100

# List available examples
docker-compose exec resourcemanager hadoop jar \
  $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar
```

## 🛠️ Troubleshooting

```bash
# Format namenode (CAUTION: destroys data!)
docker-compose run --rm namenode hdfs namenode -format -force

# Restart specific service
docker-compose restart namenode
docker-compose restart datanode1

# View service logs
docker-compose logs namenode --tail 100
docker-compose logs datanode1 --tail 100

# Check container resources
docker stats

# Inspect container
docker inspect hadoop-namenode-1
```

## 🌐 Web UIs

- NameNode: http://localhost:9870
- ResourceManager: http://localhost:8088

## 💾 Backup & Restore

```bash
# Backup namenode metadata
tar -czf namenode-backup-$(date +%Y%m%d).tar.gz data/namenode/

# Full cluster backup
tar -czf hadoop-backup-$(date +%Y%m%d).tar.gz data/

# Restore from backup
tar -xzf hadoop-backup-20251201.tar.gz
```

## 🔧 Common Issues

| Issue | Quick Fix |
|-------|-----------|
| NameNode not starting | `docker-compose run --rm namenode hdfs namenode -format -force` |
| DataNodes not connecting | `docker-compose restart datanode1 datanode2 datanode3` |
| Port already in use | Change port in docker-compose.yml |
| Disk full | `docker-compose exec namenode hdfs dfs -rm -r /large/directory` |

## 📊 Monitoring

```bash
# HDFS capacity
docker-compose exec namenode hdfs dfsadmin -report | grep -E "DFS Used|DFS Remaining"

# Live nodes
docker-compose exec namenode hdfs dfsadmin -report | grep "Live datanodes"

# YARN nodes
docker-compose exec resourcemanager yarn node -list

# Running applications
docker-compose exec resourcemanager yarn application -list
```
