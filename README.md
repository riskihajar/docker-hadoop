# Hadoop 3-Node Cluster - Docker Implementation

[![Apache Hadoop](https://img.shields.io/badge/Hadoop-3.3.6-orange.svg)](https://hadoop.apache.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue.svg)](https://docs.docker.com/compose/)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](https://www.apache.org/licenses/LICENSE-2.0)

> Production-ready Apache Hadoop 3-node distributed cluster dengan Docker Compose, persistent storage, dan fault tolerance.

## 📋 Table of Contents

- [Overview](#-overview)
- [Arsitektur](#-arsitektur)
- [Features](#-features)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [File & Directory Reference](#-file--directory-reference)
- [Command Reference](#-command-reference)
- [Common Operations](#-common-operations)
- [Troubleshooting](#-troubleshooting)
- [Monitoring](#-monitoring)
- [Backup & Recovery](#-backup--recovery)
- [Best Practices](#-best-practices)
- [Performance Tuning](#-performance-tuning)
- [Security](#-security)
- [Testing](#-testing)
- [Resources](#-resources)
- [Changelog](#-changelog)

---

## 🎯 Overview

Project ini menyediakan setup lengkap untuk menjalankan **Apache Hadoop 3.3.6** distributed cluster dengan:

- **1 NameNode** + **3 DataNodes** (HDFS layer)
- **1 ResourceManager** + **3 NodeManagers** (YARN layer)
- **Replication Factor 3** untuk data redundancy
- **Persistent Storage** dengan Docker volumes
- **Web UI** untuk monitoring dan management

---

## 🏗️ Arsitektur

```
┌─────────────────────────────────────────────────────────┐
│                    HDFS Layer                           │
│  ┌──────────────┐                                       │
│  │  NameNode    │  Metadata Management                  │
│  │  Port: 9870  │  (Web UI)                             │
│  └──────┬───────┘                                       │
│         │                                               │
│    ┌────┴────┬──────────┬──────────┐                    │
│ ┌──▼────┐ ┌──▼─────┐ ┌──▼─────┐                         │
│ │DataN1 │ │DataN2  │ │DataN3  │  Total: ~720GB          │
│ └───────┘ └────────┘ └────────┘                         │
│  Replication Factor: 3 (fault tolerant)                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    YARN Layer                           │
│  ┌──────────────────┐                                   │
│  │ ResourceManager  │  Resource Scheduling              │
│  │  Port: 8088      │  (Web UI)                         │
│  └────────┬─────────┘                                   │
│    ┌──────┴──────┬────────────┬──────────┐              │
│ ┌──▼────────┐ ┌──▼───────┐ ┌──▼───────┐                 │
│ │NodeMgr1   │ │NodeMgr2  │ │NodeMgr3  │                 │
│ │Containers │ │Containers│ │Containers│                 │
│ └───────────┘ └──────────┘ └──────────┘                 │
└─────────────────────────────────────────────────────────┘
```

---

## ✨ Features

✅ **Easy Setup** - Single command untuk deploy entire cluster
✅ **Persistent Storage** - Data tetap ada setelah container restart
✅ **Fault Tolerant** - 3-node replication untuk data safety
✅ **Web Monitoring** - Built-in web UI untuk NameNode, ResourceManager, DataNode, dan NodeManager
✅ **Individual Node Access** - Monitor setiap DataNode dan NodeManager secara terpisah via Web UI
✅ **Production Ready** - Konfigurasi optimal untuk workload nyata
✅ **Well Documented** - Comprehensive documentation dengan troubleshooting guide

---

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Minimal 8GB RAM
- 50GB free disk space

### Installation

**1. Clone repository**
```bash
git clone <repository-url>
cd docker
```

**2. Format NameNode** (first time only)
```bash
docker-compose run --rm namenode hdfs namenode -format -force
```

**3. Start cluster**
```bash
docker-compose up -d
```

**4. Verify cluster**
```bash
# Check all containers running
docker-compose ps

# Check HDFS health
docker-compose exec namenode hdfs dfsadmin -report

# Check YARN nodes
docker-compose exec resourcemanager yarn node -list
```

**5. Configure hostname resolution** (for DataNode & NodeManager Web UI access)

Add to `/etc/hosts`:
```bash
sudo nano /etc/hosts
```

Add these lines:
```
127.0.0.1 datanode1
127.0.0.1 datanode2
127.0.0.1 datanode3
127.0.0.1 nodemanager1
127.0.0.1 nodemanager2
127.0.0.1 nodemanager3
```

**6. Access Web UIs**
- **NameNode UI**: http://localhost:9870
- **ResourceManager UI**: http://localhost:8088
- **DataNode 1 UI**: http://localhost:9864
- **DataNode 2 UI**: http://localhost:9865
- **DataNode 3 UI**: http://localhost:9866
- **NodeManager 1 UI**: http://localhost:8042
- **NodeManager 2 UI**: http://localhost:8043
- **NodeManager 3 UI**: http://localhost:8044

### 📸 Cluster Screenshots

**NameNode Web Interface**

![NameNode UI](./images/namenode.png)

**Cluster Nodes Overview**

![Nodes of Cluster](./images/nodes-of-cluster.png)

---

## 📁 Project Structure

```
.
├── docker-compose.yml      # 8 services orchestration
├── config                  # Hadoop configuration (27 params)
├── .env                    # Environment variables
├── .gitignore              # Git ignore patterns
├── test.sh                 # Health check script
├── .claude/                # Claude AI configuration
├── .playwright-mcp/        # Playwright test screenshots
├── data/                   # Persistent storage (auto-created)
│   ├── namenode/           # HDFS metadata
│   ├── datanode{1,2,3}/    # HDFS data blocks
│   └── yarn/               # YARN state
└── images/                 # Screenshots for documentation
    ├── namenode.png        # NameNode Web UI
    └── nodes-of-cluster.png # Cluster nodes overview
```

---

## 📄 File & Directory Reference

### Core Configuration Files

#### `docker-compose.yml`
**Purpose**: Orchestration configuration untuk 8 Hadoop services

**Components**:
- `name: hadoop` - Project name untuk grouping di OrbStack/Docker Desktop
- **8 Services**:
  1. `namenode` - HDFS NameNode (port 9870)
  2. `datanode1-3` - HDFS DataNodes dengan hostname & port mapping (9864-9866)
  3. `resourcemanager` - YARN ResourceManager (port 8088)
  4. `nodemanager1-3` - YARN NodeManagers dengan hostname & port mapping (8042-8044)

**Volume Mappings**: Persistent storage untuk semua services
```yaml
namenode:
  volumes:
    - ./data/namenode:/tmp/hadoop-root/dfs/name
datanode1:
  volumes:
    - ./data/datanode1:/tmp/hadoop-root/dfs/data
```

#### `config`
**Purpose**: Hadoop configuration parameters (27 settings)

**Key Sections**:

1. **CORE-SITE.XML** - HDFS core configuration
   ```
   CORE-SITE.XML_fs.default.name=hdfs://namenode
   CORE-SITE.XML_fs.defaultFS=hdfs://namenode
   ```

2. **HDFS-SITE.XML** - HDFS specific settings
   ```
   HDFS-SITE.XML_dfs.namenode.rpc-address=namenode:8020
   HDFS-SITE.XML_dfs.replication=3
   HDFS-SITE.XML_dfs.namenode.name.dir=file:///tmp/hadoop-root/dfs/name
   HDFS-SITE.XML_dfs.datanode.data.dir=file:///tmp/hadoop-root/dfs/data
   ```

3. **YARN-SITE.XML** - YARN configuration
   ```
   YARN-SITE.XML_yarn.resourcemanager.hostname=resourcemanager
   YARN-SITE.XML_yarn.nodemanager.pmem-check-enabled=false
   YARN-SITE.XML_yarn.nodemanager.vmem-check-enabled=false
   YARN-SITE.XML_yarn.nodemanager.aux-services=mapreduce_shuffle
   ```

4. **MAPRED-SITE.XML** - MapReduce settings
   ```
   MAPRED-SITE.XML_mapreduce.framework.name=yarn
   MAPRED-SITE.XML_yarn.app.mapreduce.am.env=HADOOP_MAPRED_HOME=$HADOOP_HOME
   ```

5. **CAPACITY-SCHEDULER.XML** - Scheduler configuration
   ```
   CAPACITY-SCHEDULER.XML_yarn.scheduler.capacity.maximum-applications=10000
   CAPACITY-SCHEDULER.XML_yarn.scheduler.capacity.root.queues=default
   ```

#### `.env`
**Purpose**: Environment variables untuk Docker Compose

```bash
HADOOP_HOME=/opt/hadoop
COMPOSE_PROJECT_NAME=hadoop
```

#### `test.sh`
**Purpose**: Health check script untuk cluster validation

**Tests**:
1. HDFS cluster report
2. YARN nodes list
3. HDFS operations (mkdir, put, fsck)
4. MapReduce job (Pi estimation)

**Usage**:
```bash
docker-compose exec resourcemanager bash /opt/test.sh
```

#### `.gitignore`
**Purpose**: Git exclusion rules

**Excluded**:
- `data/` - Large persistent data (generated per environment)
- `*.log` - Generated log files
- `.env.local` - Local environment overrides
- `.DS_Store` - macOS system files

### Data Directories

#### `data/namenode/`
- **Stores**: HDFS metadata (fsimage, edits)
- **Size**: Small (~MB), metadata only
- **Critical**: Data loss = cluster data loss!
- **Backup Priority**: **HIGHEST**

#### `data/datanode{1,2,3}/`
- **Stores**: Actual HDFS data blocks
- **Size**: Large (depends on disk capacity)
- **Redundancy**: Replication factor 3
- **Backup Priority**: Medium (redundancy exists)

#### `data/yarn/resourcemanager/`
- **Stores**: YARN state (application history, logs)
- **Size**: Medium (~GB)
- **Backup Priority**: Medium

#### `data/yarn/nodemanager{1-3}/`
- **Stores**: Local logs, intermediate data
- **Size**: Variable
- **Backup Priority**: Low (temporary data)

---

## ⚡ Command Reference

Quick reference untuk operasi sehari-hari.

### Cluster Management

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

### Health Checks

```bash
# HDFS cluster report
docker-compose exec namenode hdfs dfsadmin -report

# YARN nodes list
docker-compose exec resourcemanager yarn node -list

# Full health check
docker-compose exec resourcemanager bash /opt/test.sh
```

### HDFS Operations

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

### YARN Operations

```bash
# List running applications
docker-compose exec resourcemanager yarn application -list

# Kill application
docker-compose exec resourcemanager yarn application -kill <application_id>

# Run MapReduce Pi example
docker-compose exec resourcemanager hadoop jar \
  $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  pi 2 100

# List available examples
docker-compose exec resourcemanager hadoop jar \
  $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar
```

### Troubleshooting Commands

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

### Monitoring Commands

```bash
# HDFS capacity
docker-compose exec namenode hdfs dfsadmin -report | grep -E "DFS Used|DFS Remaining"

# Live nodes
docker-compose exec namenode hdfs dfsadmin -report | grep "Live datanodes"

# YARN nodes
docker-compose exec resourcemanager yarn node -list

# Running applications
docker-compose exec resourcemanager yarn application -list

# Individual node logs
docker logs datanode1
docker logs nodemanager1
```

### Common Issues Quick Reference

| Issue | Quick Fix |
|-------|-----------|
| NameNode not starting | `docker-compose run --rm namenode hdfs namenode -format -force` |
| DataNodes not connecting | `docker-compose restart datanode1 datanode2 datanode3` |
| Port already in use | Change port in docker-compose.yml |
| Disk full | `docker-compose exec namenode hdfs dfs -rm -r /large/directory` |
| Container keeps restarting | Check logs: `docker-compose logs [service] --tail 100` |
| Network issues | `docker-compose down && docker network prune && docker-compose up -d` |

---

## 💻 Common Operations

### HDFS File Operations

```bash
# Create directory
docker-compose exec namenode hdfs dfs -mkdir -p /user/hadoop

# Upload file from local to HDFS
echo "Hello Hadoop" > local.txt
docker cp local.txt hadoop-namenode-1:/tmp/
docker-compose exec namenode hdfs dfs -put /tmp/local.txt /user/hadoop/

# List files
docker-compose exec namenode hdfs dfs -ls /user/hadoop/

# Download file from HDFS to local
docker-compose exec namenode hdfs dfs -get /user/hadoop/local.txt /tmp/output.txt
docker cp hadoop-namenode-1:/tmp/output.txt ./

# Delete file
docker-compose exec namenode hdfs dfs -rm /user/hadoop/local.txt

# Check file status
docker-compose exec namenode hdfs dfs -stat "%n %o %r %u %g %b" /user/hadoop/file
```

### YARN Application Management

```bash
# List running applications
docker-compose exec resourcemanager yarn application -list

# Get application status
docker-compose exec resourcemanager yarn application -status <application_id>

# Kill application
docker-compose exec resourcemanager yarn application -kill <application_id>

# View application logs
docker-compose exec resourcemanager yarn logs -applicationId <application_id>
```

### MapReduce Examples

```bash
# Run Pi estimation
docker-compose exec resourcemanager hadoop jar \
  $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  pi 2 100

# Run WordCount
docker-compose exec resourcemanager hadoop jar \
  $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  wordcount /input/file /output/directory

# Run TeraGen (data generation)
docker-compose exec resourcemanager hadoop jar \
  $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  teragen 1000000 /teragen-output
```

---

## 🛠️ Troubleshooting

Comprehensive troubleshooting guide untuk common issues.

### 1. NameNode Won't Start (Exit Code 1)

**Symptom**:
```bash
docker-compose ps
# namenode STATUS kosong atau "Exited (1)"
```

**Check logs**:
```bash
docker-compose logs namenode | tail -50
```

**Common Errors**:
- `java.io.IOException: NameNode is not formatted`
- `NameNode is in safe mode`

**Solutions**:

**A. NameNode Not Formatted** (fresh installation)
```bash
# Format namenode
docker-compose run --rm namenode hdfs namenode -format -force

# Restart namenode
docker-compose up -d namenode

# Verify
docker-compose ps namenode
```

**B. NameNode in Safe Mode**
```bash
# Wait for safe mode to exit (usually 30-60 seconds)
sleep 60

# Check safe mode status
docker-compose exec namenode hdfs dfsadmin -safemode get

# Force leave safe mode (use with caution)
docker-compose exec namenode hdfs dfsadmin -safemode leave
```

**Prevention**: Jangan hapus `data/namenode/` directory kecuali ingin reset cluster.

---

### 2. DataNodes Not Connecting to NameNode

**Symptom**:
```bash
docker-compose exec namenode hdfs dfsadmin -report
# Output: Live datanodes (0)
```

**Possible Causes**:
1. DataNodes belum selesai startup (butuh waktu 30-60 detik)
2. Network issue antar containers
3. DataNode directory permission issue
4. Version ID mismatch

**Solutions**:

**A. Wait for Startup**
```bash
# Tunggu 60 detik
sleep 60

# Check lagi
docker-compose exec namenode hdfs dfsadmin -report
```

**B. Check DataNode Logs**
```bash
docker-compose logs datanode1 | tail -50
docker-compose logs datanode2 | tail -50
docker-compose logs datanode3 | tail -50
```

**C. Restart DataNodes**
```bash
docker-compose restart datanode1 datanode2 datanode3

# Wait and verify
sleep 30
docker-compose exec namenode hdfs dfsadmin -report
```

**D. Version ID Mismatch** (after NameNode reformat)
```bash
# Stop cluster
docker-compose down

# Remove datanode data (they will re-register)
rm -rf data/datanode1/* data/datanode2/* data/datanode3/*

# Start cluster
docker-compose up -d

# Verify after 60 seconds
sleep 60
docker-compose exec namenode hdfs dfsadmin -report
```

---

### 3. YARN NodeManagers Not Showing

**Symptom**:
```bash
docker-compose exec resourcemanager yarn node -list
# Output: Total Nodes:0
```

**Check NodeManager Logs**:
```bash
docker-compose logs nodemanager1 | tail -50
docker-compose logs nodemanager2 | tail -50
docker-compose logs nodemanager3 | tail -50
```

**Solutions**:

**A. Restart NodeManagers**
```bash
docker-compose restart nodemanager1 nodemanager2 nodemanager3

# Wait 30 seconds
sleep 30

# Check again
docker-compose exec resourcemanager yarn node -list
```

**B. Check ResourceManager Connection**
```bash
# Verify ResourceManager is running
docker-compose ps resourcemanager

# Check ResourceManager logs
docker-compose logs resourcemanager | tail -50
```

**C. Network Connectivity Test**
```bash
# Test connectivity from nodemanager to resourcemanager
docker-compose exec nodemanager1 ping -c 3 resourcemanager
```

---

### 4. Port Already in Use

**Error**:
```
Error: bind: address already in use 0.0.0.0:9870
```

**Cause**: Port 9870, 8088, atau ports lain sudah digunakan aplikasi lain.

**Solutions**:

**A. Check What's Using the Port**
```bash
lsof -i :9870
lsof -i :8088
```

**B. Stop Conflicting Application**
```bash
# Find process ID from lsof output
kill -9 <PID>
```

**C. Change Port in docker-compose.yml**
```yaml
namenode:
  ports:
    - "19870:9870"  # Use 19870 instead of 9870

resourcemanager:
  ports:
    - "18088:8088"  # Use 18088 instead of 8088
```

Then restart:
```bash
docker-compose down
docker-compose up -d
```

---

### 5. Disk Space Full

**Symptom**:
```bash
docker-compose exec namenode hdfs dfsadmin -report
# DFS Used%: 95%+
```

**Solutions**:

**A. Check Disk Usage**
```bash
# Check overall HDFS usage
docker-compose exec namenode hdfs dfs -du -h /

# Find largest directories
docker-compose exec namenode hdfs dfs -du -h / | sort -h | tail -20
```

**B. Delete Unnecessary Files**
```bash
# Delete specific directory
docker-compose exec namenode hdfs dfs -rm -r /path/to/large/directory

# Delete specific files
docker-compose exec namenode hdfs dfs -rm /path/to/large/file
```

**C. Clean YARN Logs**
```bash
# Delete old application logs (older than 7 days)
docker-compose exec resourcemanager yarn logs -applicationId <app_id> -delete
```

**D. Adjust Replication Factor** (if appropriate)
```bash
# Reduce replication to 2 for non-critical data
docker-compose exec namenode hdfs dfs -setrep -R 2 /path/to/directory

# Check replication
docker-compose exec namenode hdfs fsck / | grep "Average block replication"
```

---

### 6. Container Keeps Restarting

**Check Container Status**:
```bash
docker-compose ps
docker inspect <container_name>
```

**Check Resource Limits**:
```bash
# Monitor resource usage
docker stats

# Check individual container
docker stats hadoop-namenode-1
```

**Solutions**:

**A. Increase Docker Resources**
- Docker Desktop: Settings → Resources → Memory/CPU
- Increase memory to at least 8GB
- Increase CPU to at least 4 cores

**B. Add Resource Limits** (prevent resource starvation)
Edit `docker-compose.yml`:
```yaml
namenode:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 4G
      reservations:
        memory: 2G
```

**C. Check Container Logs**
```bash
docker-compose logs [service] --tail 100
```

---

### 7. Permission Denied Errors

**Error in logs**:
```
Permission denied: user=root, access=WRITE, inode="/user":hadoop:supergroup:drwxr-xr-x
```

**Cause**: HDFS permission issue

**Solutions**:

**A. Change Ownership**
```bash
# Change to root
docker-compose exec namenode hdfs dfs -chown -R root:supergroup /user

# Or specific user
docker-compose exec namenode hdfs dfs -chown -R hadoop:hadoop /user/hadoop
```

**B. Change Permissions**
```bash
# Make directory writable
docker-compose exec namenode hdfs dfs -chmod -R 755 /user

# Or full permissions (development only)
docker-compose exec namenode hdfs dfs -chmod -R 777 /user
```

**C. Check Current Permissions**
```bash
docker-compose exec namenode hdfs dfs -ls -R /
```

---

### 8. Network Issues Between Containers

**Symptom**: Services can't communicate, connection refused errors

**Check Network**:
```bash
# List networks
docker network ls

# Inspect hadoop network
docker network inspect hadoop_default
```

**Solutions**:

**A. Verify Network Connectivity**
```bash
# Test from datanode to namenode
docker-compose exec datanode1 ping -c 3 namenode

# Test from nodemanager to resourcemanager
docker-compose exec nodemanager1 ping -c 3 resourcemanager
```

**B. Recreate Network**
```bash
# Stop cluster
docker-compose down

# Remove network
docker network prune

# Start fresh
docker-compose up -d
```

**C. Check DNS Resolution**
```bash
# Verify hostname resolution
docker-compose exec datanode1 nslookup namenode
```

---

### 9. Complete Cluster Reset

**When to Use**: Cluster dalam kondisi tidak recoverable, multiple persistent errors.

**⚠️ WARNING**: This will DELETE ALL DATA!

**Steps**:
```bash
# 1. Stop all containers
docker-compose down

# 2. Backup data (optional but recommended)
tar -czf hadoop-backup-$(date +%Y%m%d).tar.gz data/

# 3. Delete all data
rm -rf data/*

# 4. Remove Docker volumes (if any)
docker volume prune

# 5. Format namenode
docker-compose run --rm namenode hdfs namenode -format -force

# 6. Start fresh cluster
docker-compose up -d

# 7. Wait for startup
sleep 60

# 8. Verify
docker-compose ps
docker-compose exec namenode hdfs dfsadmin -report
docker-compose exec resourcemanager yarn node -list
```

---

## 📊 Monitoring

### Web UIs

**NameNode** - http://localhost:9870
- HDFS overview & statistics
- DataNode status & health
- HDFS file browser
- NameNode logs
- Snapshot management

**DataNode Web UIs** (Individual monitoring)
- **DataNode 1** - http://localhost:9864
  - Block information & replication status
  - Volume status & capacity
  - Storage metrics & health
- **DataNode 2** - http://localhost:9865
  - Block information & replication status
  - Volume status & capacity
  - Storage metrics & health
- **DataNode 3** - http://localhost:9866
  - Block information & replication status
  - Volume status & capacity
  - Storage metrics & health

> **Note**: DataNode Web UIs require hostname configuration in `/etc/hosts` as described in Quick Start section.

**ResourceManager** - http://localhost:8088
- Cluster metrics & statistics
- Running applications & history
- Node status & capacity
- Scheduler information
- Queue management

**NodeManager Web UIs** (YARN resource monitoring)
- **NodeManager 1** - http://localhost:8042
  - Container information & status
  - Resource allocation & utilization
  - Application logs
- **NodeManager 2** - http://localhost:8043
  - Container information & status
  - Resource allocation & utilization
  - Application logs
- **NodeManager 3** - http://localhost:8044
  - Container information & status
  - Resource allocation & utilization
  - Application logs

> **Note**: NodeManager Web UIs require hostname configuration in `/etc/hosts` as described in Quick Start section.

### CLI Monitoring

```bash
# HDFS status & health
docker-compose exec namenode hdfs dfsadmin -report

# HDFS capacity & usage
docker-compose exec namenode hdfs dfs -df -h

# YARN nodes & resources
docker-compose exec resourcemanager yarn node -list

# Detailed node status
docker-compose exec resourcemanager yarn node -status <node_id>

# Check specific file distribution across DataNodes
docker-compose exec namenode hdfs fsck /path/to/file -files -blocks -locations

# Check overall HDFS health
docker-compose exec namenode hdfs fsck / -files -blocks

# Disk usage by directory
docker-compose exec namenode hdfs dfs -du -h /

# Running applications
docker-compose exec resourcemanager yarn application -list

# Application status
docker-compose exec resourcemanager yarn application -status <app_id>

# Individual DataNode logs
docker logs datanode1 --tail 100 -f
docker logs datanode2 --tail 100 -f
docker logs datanode3 --tail 100 -f

# Individual NodeManager logs
docker logs nodemanager1 --tail 100 -f
docker logs nodemanager2 --tail 100 -f
docker logs nodemanager3 --tail 100 -f

# Container resource usage
docker stats
```

---

## 💾 Backup & Recovery

### Backup Strategy

#### Critical Data - Backup Daily

**NameNode Metadata** (HIGHEST PRIORITY)
```bash
# Daily backup namenode metadata
tar -czf namenode-backup-$(date +%Y%m%d).tar.gz data/namenode/

# Upload to cloud storage (optional)
# aws s3 cp namenode-backup-*.tar.gz s3://your-bucket/hadoop-backups/
# gsutil cp namenode-backup-*.tar.gz gs://your-bucket/hadoop-backups/
```

#### Full Cluster Backup - Backup Weekly

```bash
# Weekly full cluster backup
tar -czf hadoop-full-backup-$(date +%Y%m%d).tar.gz data/

# Compress with better ratio (slower)
tar -cJf hadoop-full-backup-$(date +%Y%m%d).tar.xz data/
```

### Automated Backup Script

Create `backup.sh`:
```bash
#!/bin/bash
BACKUP_DIR="/path/to/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Daily namenode backup
tar -czf ${BACKUP_DIR}/namenode-${TIMESTAMP}.tar.gz data/namenode/

# Keep only last 7 days
find ${BACKUP_DIR} -name "namenode-*.tar.gz" -mtime +7 -delete

# Weekly full backup (only on Sunday)
if [ $(date +%u) -eq 7 ]; then
    tar -czf ${BACKUP_DIR}/full-${TIMESTAMP}.tar.gz data/
    # Keep only last 4 weeks
    find ${BACKUP_DIR} -name "full-*.tar.gz" -mtime +28 -delete
fi
```

Add to crontab:
```bash
# Daily backup at 2 AM
0 2 * * * /path/to/backup.sh >> /var/log/hadoop-backup.log 2>&1
```

### Restore Procedures

#### Restore NameNode Metadata Only

```bash
# Stop cluster
docker-compose down

# Backup current state (safety)
mv data/namenode data/namenode.broken

# Extract backup
tar -xzf namenode-backup-20251201.tar.gz

# Start cluster
docker-compose up -d

# Verify
sleep 60
docker-compose exec namenode hdfs dfsadmin -report
```

#### Full Cluster Restore

```bash
# Stop cluster
docker-compose down

# Backup current state (safety)
mv data data.broken

# Extract full backup
tar -xzf hadoop-full-backup-20251201.tar.gz

# Start cluster
docker-compose up -d

# Verify all services
sleep 60
docker-compose ps
docker-compose exec namenode hdfs dfsadmin -report
docker-compose exec resourcemanager yarn node -list
```

---

## 📚 Best Practices

### 1. Monitoring & Alerting

**Setup Periodic Health Checks**:
```bash
# Add to crontab - check every 5 minutes
*/5 * * * * cd /path/to/docker && docker-compose exec -T namenode hdfs dfsadmin -report > /var/log/hdfs-report.log 2>&1
```

**Monitor Disk Usage**:
```bash
# Real-time monitoring
watch -n 60 "docker-compose exec namenode hdfs dfs -df -h"

# Alert when usage > 80%
USAGE=$(docker-compose exec namenode hdfs dfs -df | awk 'NR==2 {print $5}' | tr -d '%')
if [ $USAGE -gt 80 ]; then
    echo "ALERT: HDFS usage is ${USAGE}%" | mail -s "HDFS Alert" admin@example.com
fi
```

**Monitor Node Health**:
```bash
# Check for dead nodes
DEAD_NODES=$(docker-compose exec namenode hdfs dfsadmin -report | grep "Dead datanodes" | awk '{print $4}')
if [ $DEAD_NODES -gt 0 ]; then
    echo "ALERT: $DEAD_NODES dead datanodes" | mail -s "DataNode Alert" admin@example.com
fi
```

### 2. Resource Management

**Container Resource Limits** - Add to `docker-compose.yml`:
```yaml
namenode:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 4G
      reservations:
        cpus: '1'
        memory: 2G

datanode1:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 4G
      reservations:
        cpus: '1'
        memory: 2G
```

**HDFS Quotas** (limit storage per user/directory):
```bash
# Set space quota (10GB)
docker-compose exec namenode hdfs dfsadmin -setSpaceQuota 10g /user/hadoop

# Set namespace quota (1000 files)
docker-compose exec namenode hdfs dfsadmin -setQuota 1000 /user/hadoop

# Check quotas
docker-compose exec namenode hdfs dfs -count -q /user/hadoop
```

### 3. Log Management

**Rotate Logs**:
```bash
# Clear old logs (older than 7 days)
docker-compose exec namenode find /var/log/hadoop -name "*.log*" -mtime +7 -delete
docker-compose exec resourcemanager find /var/log/hadoop -name "*.log*" -mtime +7 -delete
```

**Limit Log Size** - Add to `config`:
```
LOG4J.APPENDER.RFA.MaxFileSize=100MB
LOG4J.APPENDER.RFA.MaxBackupIndex=10
```

**Centralized Logging** (optional):
```yaml
# Add to docker-compose.yml
logging:
  driver: "json-file"
  options:
    max-size: "100m"
    max-file: "5"
```

### 4. Data Lifecycle Management

**Clean Old MapReduce Outputs**:
```bash
# Delete directories older than 30 days
docker-compose exec namenode hdfs dfs -find /output -type d -mtime +30 -delete
```

**Archive Cold Data**:
```bash
# Move to archive with reduced replication
docker-compose exec namenode hdfs dfs -setrep -R 2 /archive/
```

### 5. High Availability (Production)

**For Production Environments**:

1. **Multiple NameNodes** (HA setup)
   - Configure secondary NameNode
   - Setup automatic failover with ZooKeeper

2. **Federation** (for large clusters)
   - Multiple independent namespaces
   - Scalability for very large deployments

3. **Regular Testing**
   - Test restore procedures monthly
   - Verify backup integrity
   - Practice disaster recovery

### 6. Maintenance Windows

**Planned Maintenance Checklist**:
```bash
# 1. Notify users
# 2. Stop accepting new jobs
docker-compose exec resourcemanager yarn rmadmin -refreshQueues

# 3. Wait for running jobs to complete
docker-compose exec resourcemanager yarn application -list

# 4. Create backup
tar -czf pre-maintenance-$(date +%Y%m%d).tar.gz data/

# 5. Perform maintenance
docker-compose down
# ... maintenance tasks ...
docker-compose up -d

# 6. Verify cluster health
docker-compose exec namenode hdfs dfsadmin -report
docker-compose exec resourcemanager yarn node -list

# 7. Resume operations
```

---

## ⚡ Performance Tuning

### HDFS Performance

**Block Size Optimization**:
```
# For large files (videos, logs): 256MB
HDFS-SITE.XML_dfs.blocksize=268435456

# For medium files: 128MB (default)
HDFS-SITE.XML_dfs.blocksize=134217728

# For small files: 64MB
HDFS-SITE.XML_dfs.blocksize=67108864
```

**Replication Factor** (based on cluster size):
```
# 3-node cluster: replication = 3
HDFS-SITE.XML_dfs.replication=3

# Larger clusters: can reduce to 2 for cold data
# Critical data: keep at 3
```

**Handler Count** (concurrent RPC requests):
```
# Increase for high concurrent access
HDFS-SITE.XML_dfs.namenode.handler.count=40
HDFS-SITE.XML_dfs.datanode.handler.count=10
```

### YARN Performance

**Memory Configuration**:
```
# NodeManager total memory (8GB)
YARN-SITE.XML_yarn.nodemanager.resource.memory-mb=8192

# Container max allocation (4GB)
YARN-SITE.XML_yarn.scheduler.maximum-allocation-mb=4096

# Container min allocation (512MB)
YARN-SITE.XML_yarn.scheduler.minimum-allocation-mb=512
```

**CPU Configuration**:
```
# Virtual cores per NodeManager
YARN-SITE.XML_yarn.nodemanager.resource.cpu-vcores=4

# Enable CPU scheduling
YARN-SITE.XML_yarn.nodemanager.resource.cpu-vcores.enabled=true
```

**Container Executor**:
```
# Threads per container
YARN-SITE.XML_yarn.nodemanager.container-executor.threads=20
```

### MapReduce Performance

**Map Task Configuration**:
```
MAPRED-SITE.XML_mapreduce.map.memory.mb=2048
MAPRED-SITE.XML_mapreduce.map.java.opts=-Xmx1536m
MAPRED-SITE.XML_mapreduce.map.cpu.vcores=1
```

**Reduce Task Configuration**:
```
MAPRED-SITE.XML_mapreduce.reduce.memory.mb=4096
MAPRED-SITE.XML_mapreduce.reduce.java.opts=-Xmx3072m
MAPRED-SITE.XML_mapreduce.reduce.cpu.vcores=2
```

**Shuffle Performance**:
```
MAPRED-SITE.XML_mapreduce.task.io.sort.mb=512
MAPRED-SITE.XML_mapreduce.task.io.sort.factor=100
```

### JVM Tuning

Add to `config`:
```
# NameNode JVM
HADOOP_NAMENODE_OPTS=-Xms2g -Xmx4g -XX:+UseG1GC

# DataNode JVM
HADOOP_DATANODE_OPTS=-Xms1g -Xmx2g -XX:+UseG1GC

# ResourceManager JVM
YARN_RESOURCEMANAGER_OPTS=-Xms2g -Xmx4g -XX:+UseG1GC

# NodeManager JVM
YARN_NODEMANAGER_OPTS=-Xms1g -Xmx2g -XX:+UseG1GC
```

---

## 🔐 Security

### Production Security Checklist

#### 1. Authentication

**Enable Kerberos** (recommended for production):
```
# Add to config
CORE-SITE.XML_hadoop.security.authentication=kerberos
CORE-SITE.XML_hadoop.security.authorization=true
```

**Simple Authentication** (development only):
```
CORE-SITE.XML_hadoop.security.authentication=simple
```

#### 2. Encryption

**Encryption at Rest**:
```
# Enable HDFS transparent encryption
HDFS-SITE.XML_dfs.encryption.key.provider.uri=kms://http@kms-server:9600/kms
```

**Encryption in Transit**:
```
# Enable SSL/TLS
HDFS-SITE.XML_dfs.http.policy=HTTPS_ONLY
HDFS-SITE.XML_dfs.datanode.https.address=0.0.0.0:50475
```

#### 3. Access Control

**Enable ACLs**:
```bash
# Enable HDFS ACLs
docker-compose exec namenode hdfs dfs -setfacl -m user:username:rwx /path/to/directory

# Check ACLs
docker-compose exec namenode hdfs dfs -getfacl /path/to/directory
```

**File Permissions**:
```bash
# Set proper permissions
docker-compose exec namenode hdfs dfs -chmod 750 /user/hadoop
docker-compose exec namenode hdfs dfs -chown hadoop:hadoop /user/hadoop
```

#### 4. Firewall Configuration

**Required Ports**:
- 9870 (NameNode Web UI)
- 8020 (NameNode RPC)
- 8088 (ResourceManager Web UI)
- 8030-8033 (ResourceManager services)
- 9864-9866 (DataNode Web UIs)
- 8042-8044 (NodeManager Web UIs)

**Restrict Access**:
```bash
# Allow only specific IPs (example using iptables)
iptables -A INPUT -p tcp --dport 9870 -s 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p tcp --dport 9870 -j DROP
```

#### 5. Audit Logging

**Enable HDFS Audit Logs**:
```
HDFS-SITE.XML_dfs.namenode.audit.loggers=default
HDFS-SITE.XML_dfs.namenode.audit.log.async=true
```

**Monitor Audit Logs**:
```bash
docker-compose exec namenode tail -f /var/log/hadoop/hdfs-audit.log
```

#### 6. Security Updates

**Regular Updates**:
```bash
# Update to latest Hadoop image
docker pull apache/hadoop:3

# Update docker-compose.yml to use latest
# Then recreate containers
docker-compose up -d --force-recreate
```

#### 7. Network Security

**Use Private Networks**:
```yaml
# docker-compose.yml
networks:
  hadoop_net:
    driver: bridge
    internal: true  # No external access
```

**Container Isolation**:
```yaml
services:
  namenode:
    networks:
      - hadoop_net
    security_opt:
      - no-new-privileges:true
```

---

## 🧪 Testing

### Health Check Script

Run comprehensive health check:
```bash
docker-compose exec resourcemanager bash /opt/test.sh
```

**Tests Performed**:
- ✅ HDFS cluster report
- ✅ YARN node status
- ✅ Create HDFS directory
- ✅ Upload file with replication
- ✅ Verify replication factor
- ✅ Run MapReduce Pi estimation

### Manual Testing

**Test HDFS**:
```bash
# Create test file
echo "Test data $(date)" > test.txt

# Upload to HDFS
docker cp test.txt hadoop-namenode-1:/tmp/
docker-compose exec namenode hdfs dfs -put /tmp/test.txt /test/

# Verify replication
docker-compose exec namenode hdfs fsck /test/test.txt -files -blocks -locations

# Download and compare
docker-compose exec namenode hdfs dfs -get /test/test.txt /tmp/downloaded.txt
docker cp hadoop-namenode-1:/tmp/downloaded.txt ./
diff test.txt downloaded.txt

# Cleanup
docker-compose exec namenode hdfs dfs -rm -r /test
rm test.txt downloaded.txt
```

**Test YARN**:
```bash
# Run MapReduce example
docker-compose exec resourcemanager hadoop jar \
  $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  pi 2 100

# Check application completed successfully
docker-compose exec resourcemanager yarn application -list -appStates FINISHED
```

**Test Fault Tolerance**:
```bash
# Stop one datanode
docker-compose stop datanode1

# Verify cluster still operational
docker-compose exec namenode hdfs dfsadmin -report

# Verify data still accessible (replication factor 3)
docker-compose exec namenode hdfs dfs -cat /test/file

# Restart datanode
docker-compose start datanode1

# Verify rebalancing
sleep 30
docker-compose exec namenode hdfs dfsadmin -report
```

---

## 🔗 Resources

### Official Documentation

- [Hadoop Documentation](https://hadoop.apache.org/docs/r3.3.6/)
- [HDFS Architecture](https://hadoop.apache.org/docs/r3.3.6/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html)
- [YARN Architecture](https://hadoop.apache.org/docs/r3.3.6/hadoop-yarn/hadoop-yarn-site/YARN.html)
- [MapReduce Tutorial](https://hadoop.apache.org/docs/r3.3.6/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html)

### Docker Resources

- [Apache Hadoop Docker Image](https://hub.docker.com/r/apache/hadoop)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

### Community

- [Apache Hadoop Wiki](https://cwiki.apache.org/confluence/display/HADOOP)
- [Stack Overflow - hadoop tag](https://stackoverflow.com/questions/tagged/hadoop)
- [Hadoop Users Mailing List](https://hadoop.apache.org/mailing_lists.html)

### Learning Resources

**For Beginners**:
1. Start dengan [Quick Start](#-quick-start)
2. Explore Web UIs (NameNode & ResourceManager)
3. Practice HDFS operations dari [Common Operations](#-common-operations)
4. Run MapReduce examples
5. Understand [Arsitektur](#-arsitektur)

**For Advanced Users**:
- [Performance Tuning](#-performance-tuning)
- [Security Best Practices](#-security)
- [High Availability Setup](https://hadoop.apache.org/docs/r3.3.6/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithNFS.html)
- Integration dengan ecosystem tools (Hive, Spark, HBase)

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📝 License

This project configuration is based on Apache Hadoop.

- **Apache Hadoop**: [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)
- **This Configuration**: Free to use and modify

---

## 📧 Support

Untuk pertanyaan, issues, atau contributions:

- 🐛 [Report Issues](../../issues)
- 💡 [Feature Requests](../../issues)

---

## 🌟 Star History

If you find this project useful, please consider giving it a ⭐!

---

## 📅 Changelog

**v1.2.0** (2025-12-08)
- ✅ Consolidated documentation into single comprehensive README
- ✅ Added detailed File & Directory Reference section
- ✅ Added comprehensive Command Reference with quick copy-paste commands
- ✅ Expanded Troubleshooting to 9 detailed scenarios
- ✅ Added Best Practices section with monitoring & maintenance
- ✅ Added Performance Tuning guidelines
- ✅ Added Security section with production checklist
- ✅ Improved navigation with detailed Table of Contents

**v1.1.0** (2025-12-08)
- ✅ Added DataNode hostname configuration (datanode1, datanode2, datanode3)
- ✅ Enabled individual DataNode Web UI access
- ✅ Configured port mapping for DataNode monitoring (9864, 9865, 9866)
- ✅ Added NodeManager hostname configuration (nodemanager1, nodemanager2, nodemanager3)
- ✅ Enabled individual NodeManager Web UI access
- ✅ Configured port mapping for NodeManager monitoring (8042, 8043, 8044)
- ✅ Added `/etc/hosts` configuration guide for both HDFS and YARN layers
- ✅ Enhanced monitoring capabilities with per-node metrics

**v1.0.0** (2025-12-01)
- ✅ Initial 3-node cluster setup
- ✅ Persistent storage implementation
- ✅ Replication factor 3 configuration
- ✅ Docker Compose orchestration
- ✅ Comprehensive documentation
- ✅ Health check scripts
- ✅ Troubleshooting guides

---

<div align="center">

**Built with ❤️ for the Hadoop Community**

[Report Bug](../../issues) • [Request Feature](../../issues)

</div>
