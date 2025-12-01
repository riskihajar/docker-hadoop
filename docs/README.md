# Hadoop 3-Node Cluster - Docker Implementation

Dokumentasi lengkap untuk deployment Hadoop 3-node cluster menggunakan Docker Compose dengan persistent storage.

## 📋 Daftar Isi

1. [Overview](#overview)
2. [Arsitektur Cluster](#arsitektur-cluster)
3. [Struktur Project](#struktur-project)
4. [Penjelasan File & Directory](#penjelasan-file--directory)
5. [Cara Penggunaan](#cara-penggunaan)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)

---

## Overview

Project ini adalah implementasi Apache Hadoop 3.3.6 distributed cluster dengan konfigurasi:
- **1 NameNode**: Mengelola metadata HDFS
- **3 DataNodes**: Menyimpan data terdistribusi dengan replication factor 3
- **1 ResourceManager**: Mengelola resource YARN cluster
- **3 NodeManagers**: Menjalankan task/container aplikasi

### Fitur Utama
✅ Persistent storage menggunakan Docker volumes  
✅ 3-node cluster untuk fault tolerance  
✅ Replication factor 3 untuk data redundancy  
✅ YARN untuk resource management  
✅ Web UI untuk monitoring (NameNode: 9870, ResourceManager: 8088)  
✅ Project naming yang jelas ("hadoop" group di OrbStack)

---

## Arsitektur Cluster

```
┌─────────────────────────────────────────────────────────┐
│                    HDFS Layer                           │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐                                       │
│  │  NameNode    │  Metadata management                  │
│  │  Port: 9870  │  (Web UI)                            │
│  └──────┬───────┘                                       │
│         │                                                │
│    ┌────┴────┬──────────┬──────────┐                   │
│    │         │          │          │                    │
│ ┌──▼────┐ ┌─▼──────┐ ┌─▼──────┐ ┌─▼──────┐           │
│ │DataN1 │ │DataN2  │ │DataN3  │                        │
│ │240GB  │ │240GB   │ │240GB   │  Total: 720GB         │
│ └───────┘ └────────┘ └────────┘                        │
│                                                          │
│  Replication Factor: 3 (setiap block tersimpan 3x)     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    YARN Layer                           │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────┐                                   │
│  │ ResourceManager  │  Resource scheduling              │
│  │  Port: 8088      │  (Web UI)                        │
│  └────────┬─────────┘                                   │
│           │                                              │
│    ┌──────┴──────┬──────────┬──────────┐               │
│    │             │          │          │                │
│ ┌──▼────────┐ ┌─▼────────┐ ┌─▼────────┐               │
│ │NodeMgr1   │ │NodeMgr2  │ │NodeMgr3  │               │
│ │Container  │ │Container │ │Container │               │
│ │Execution  │ │Execution │ │Execution │               │
│ └───────────┘ └──────────┘ └──────────┘               │
└─────────────────────────────────────────────────────────┘
```

---

## Struktur Project

```
docker/
├── docker-compose.yml      # Konfigurasi orchestration 8 services
├── config                  # Hadoop XML configuration (27 params)
├── .env                    # Environment variables
├── test.sh                 # Cluster health check script
├── .gitignore             # Git exclusion rules
├── .claude/               # Claude Code configuration
│   └── settings.local.json
├── data/                  # Persistent storage (excluded from git)
│   ├── namenode/          # NameNode metadata
│   ├── datanode1/         # DataNode 1 storage
│   ├── datanode2/         # DataNode 2 storage
│   ├── datanode3/         # DataNode 3 storage
│   └── yarn/
│       ├── resourcemanager/
│       ├── nodemanager1/
│       ├── nodemanager2/
│       └── nodemanager3/
└── docs/                  # Documentation
    ├── README.md          # Dokumentasi utama (file ini)
    └── TROUBLESHOOTING.md # Panduan troubleshooting
```

---

## Penjelasan File & Directory

### 📄 Files

#### `docker-compose.yml`
**Fungsi**: File konfigurasi Docker Compose yang mendefinisikan semua services Hadoop cluster.

**Komponen**:
- `name: hadoop` - Project name untuk grouping di OrbStack
- `version: "2"` - Docker Compose file format version
- **8 Services**:
  1. `namenode` - HDFS NameNode (port 9870)
  2. `datanode1` - HDFS DataNode pertama
  3. `datanode2` - HDFS DataNode kedua
  4. `datanode3` - HDFS DataNode ketiga
  5. `resourcemanager` - YARN ResourceManager (port 8088)
  6. `nodemanager1` - YARN NodeManager pertama
  7. `nodemanager2` - YARN NodeManager kedua
  8. `nodemanager3` - YARN NodeManager ketiga

**Volume Mappings**:
```yaml
namenode:
  volumes:
    - ./data/namenode:/tmp/hadoop-root/dfs/name
datanode1:
  volumes:
    - ./data/datanode1:/tmp/hadoop-root/dfs/data
# ... dan seterusnya untuk semua nodes
```

**Key Configuration**:
- Image: `apache/hadoop:3`
- Network: `hadoop_default` (auto-created)
- Env file: `./config` (shared configuration)

---

#### `config`
**Fungsi**: File konfigurasi Hadoop yang berisi parameter untuk HDFS, YARN, dan MapReduce.

**Format**: Key-value pairs dengan prefix XML element name.

**Sections**:

1. **CORE-SITE.XML** (HDFS core config):
```
CORE-SITE.XML_fs.default.name=hdfs://namenode
CORE-SITE.XML_fs.defaultFS=hdfs://namenode
```
- Mendefinisikan default filesystem URI
- NameNode sebagai master HDFS

2. **HDFS-SITE.XML** (HDFS specific config):
```
HDFS-SITE.XML_dfs.namenode.rpc-address=namenode:8020
HDFS-SITE.XML_dfs.replication=3
HDFS-SITE.XML_dfs.namenode.name.dir=file:///tmp/hadoop-root/dfs/name
HDFS-SITE.XML_dfs.datanode.data.dir=file:///tmp/hadoop-root/dfs/data
```
- RPC address untuk komunikasi client-NameNode
- Replication factor = 3 (setiap block disimpan 3 kali)
- Directory untuk metadata dan data storage

3. **MAPRED-SITE.XML** (MapReduce config):
```
MAPRED-SITE.XML_mapreduce.framework.name=yarn
MAPRED-SITE.XML_yarn.app.mapreduce.am.env=HADOOP_MAPRED_HOME=$HADOOP_HOME
```
- Framework: YARN (bukan classic MapReduce)
- Environment variables untuk MapReduce ApplicationMaster

4. **YARN-SITE.XML** (YARN config):
```
YARN-SITE.XML_yarn.resourcemanager.hostname=resourcemanager
YARN-SITE.XML_yarn.nodemanager.pmem-check-enabled=false
YARN-SITE.XML_yarn.nodemanager.vmem-check-enabled=false
YARN-SITE.XML_yarn.nodemanager.aux-services=mapreduce_shuffle
```
- ResourceManager hostname
- Memory checks disabled (development mode)
- Auxiliary services untuk MapReduce shuffle

5. **CAPACITY-SCHEDULER.XML** (Scheduling config):
```
CAPACITY-SCHEDULER.XML_yarn.scheduler.capacity.maximum-applications=10000
CAPACITY-SCHEDULER.XML_yarn.scheduler.capacity.root.queues=default
CAPACITY-SCHEDULER.XML_yarn.scheduler.capacity.root.default.capacity=100
```
- Maximum concurrent applications: 10,000
- Single queue "default" dengan 100% capacity

---

#### `.env`
**Fungsi**: Environment variables untuk Docker Compose dan Hadoop.

**Content**:
```bash
HADOOP_HOME=/opt/hadoop
COMPOSE_PROJECT_NAME=hadoop
```

**Variabel**:
- `HADOOP_HOME`: Path instalasi Hadoop di dalam container
- `COMPOSE_PROJECT_NAME`: Nama project untuk Docker Compose (muncul sebagai "hadoop" di OrbStack)

---

#### `test.sh`
**Fungsi**: Script bash untuk testing dan health check cluster.

**Tests yang dilakukan**:
1. **HDFS Status**: `hdfs dfsadmin -report`
2. **YARN Nodes**: `yarn node -list`
3. **HDFS Operations**:
   - Create directory: `hdfs dfs -mkdir -p /test`
   - Upload file: `hdfs dfs -put /tmp/test.txt /test/`
   - Check replication: `hdfs fsck /test/test.txt -files -blocks -locations`
4. **MapReduce Job**: Pi estimation example

**Cara Menjalankan**:
```bash
docker-compose exec resourcemanager bash /opt/test.sh
```

---

#### `.gitignore`
**Fungsi**: Menentukan file/directory yang diabaikan oleh Git.

**Excluded Items**:
```
data/           # Persistent data (ukuran besar, generated)
*.log           # Log files
.env.local      # Local environment overrides
.DS_Store       # macOS system files
```

**Alasan**:
- `data/`: Ukuran besar, specific untuk setiap environment
- Logs: Generated files, tidak perlu versioning
- Local env: Credential/sensitive data

---

### 📁 Directories

#### `data/`
**Fungsi**: Persistent storage untuk semua data Hadoop cluster.

**Sub-directories**:

1. **`data/namenode/`**
   - Menyimpan: HDFS metadata (fsimage, edits)
   - Ukuran: Kecil (~MB), metadata only
   - Critical: Data loss = cluster data loss!
   - Backup priority: **TINGGI**

2. **`data/datanode1/`, `data/datanode2/`, `data/datanode3/`**
   - Menyimpan: Actual HDFS blocks
   - Ukuran: Besar (sesuai kapasitas disk)
   - Redundancy: Replication factor 3
   - Backup priority: Sedang (ada replikasi)

3. **`data/yarn/resourcemanager/`**
   - Menyimpan: YARN state (application history, logs)
   - Ukuran: Sedang (~GB)
   - Backup priority: Sedang

4. **`data/yarn/nodemanager1-3/`**
   - Menyimpan: Local logs, intermediate data
   - Ukuran: Bervariasi
   - Backup priority: Rendah (temporary data)

**Lifecycle**:
```bash
# Created automatically saat: docker-compose up
# Persist setelah: docker-compose down
# Deleted manual: rm -rf data/
```

---

#### `.claude/`
**Fungsi**: Konfigurasi untuk Claude Code (AI assistant).

**File**: `settings.local.json`
- Project-specific settings untuk Claude Code
- Tidak mempengaruhi Hadoop cluster

---

#### `docs/`
**Fungsi**: Dokumentasi project.

**Files**:
- `README.md`: Dokumentasi utama (file ini)
- `TROUBLESHOOTING.md`: Panduan troubleshooting detail

---

## Cara Penggunaan

### Initial Setup

1. **Format NameNode** (hanya sekali untuk fresh install):
```bash
docker-compose run --rm namenode hdfs namenode -format -force
```

2. **Start Cluster**:
```bash
docker-compose up -d
```

3. **Verify Status**:
```bash
docker-compose ps
```

Expected output: Semua 8 containers STATUS = "Up"

### Daily Operations

**Start cluster**:
```bash
docker-compose up -d
```

**Stop cluster** (data tetap ada):
```bash
docker-compose down
```

**Restart cluster**:
```bash
docker-compose restart
```

**View logs**:
```bash
# Semua services
docker-compose logs -f

# Specific service
docker-compose logs -f namenode
docker-compose logs -f datanode1
```

**Check cluster health**:
```bash
# HDFS report
docker-compose exec namenode hdfs dfsadmin -report

# YARN nodes
docker-compose exec resourcemanager yarn node -list

# Run test script
docker-compose exec resourcemanager bash /opt/test.sh
```

### HDFS Operations

**Create directory**:
```bash
docker-compose exec namenode hdfs dfs -mkdir -p /user/hadoop
```

**Upload file**:
```bash
# From local to HDFS
echo "Hello Hadoop" > local.txt
docker cp local.txt hadoop-namenode-1:/tmp/
docker-compose exec namenode hdfs dfs -put /tmp/local.txt /user/hadoop/
```

**List files**:
```bash
docker-compose exec namenode hdfs dfs -ls /
docker-compose exec namenode hdfs dfs -ls /user/hadoop/
```

**Download file**:
```bash
docker-compose exec namenode hdfs dfs -get /user/hadoop/local.txt /tmp/output.txt
docker cp hadoop-namenode-1:/tmp/output.txt ./
```

**Delete file**:
```bash
docker-compose exec namenode hdfs dfs -rm /user/hadoop/local.txt
```

### YARN Operations

**List running applications**:
```bash
docker-compose exec resourcemanager yarn application -list
```

**Kill application**:
```bash
docker-compose exec resourcemanager yarn application -kill <application_id>
```

**Run MapReduce job**:
```bash
docker-compose exec resourcemanager hadoop jar \
  $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar \
  pi 2 100
```

### Web UI Access

**NameNode Web UI**:
- URL: http://localhost:9870
- Info: HDFS status, datanodes, file browser

**ResourceManager Web UI**:
- URL: http://localhost:8088
- Info: YARN applications, cluster metrics, node status

---

## Troubleshooting

### 1. NameNode Tidak Bisa Start (Exit Code 1)

**Symptom**:
```bash
docker-compose ps
# namenode STATUS kosong atau "Exited (1)"
```

**Check logs**:
```bash
docker-compose logs namenode | tail -50
```

**Error**: `java.io.IOException: NameNode is not formatted`

**Cause**: NameNode belum diformat (fresh installation atau data directory kosong)

**Solution**:
```bash
# Format namenode
docker-compose run --rm namenode hdfs namenode -format -force

# Restart namenode
docker-compose up -d namenode

# Verify
docker-compose ps namenode
```

**Prevention**: Jangan hapus `data/namenode/` directory kecuali ingin reset cluster.

---

### 2. DataNode Tidak Terhubung ke NameNode

**Symptom**:
```bash
docker-compose exec namenode hdfs dfsadmin -report
# Output: Live datanodes (0)
```

**Possible Causes**:
1. DataNode belum selesai startup (butuh waktu 30-60 detik)
2. Network issue antar container
3. DataNode directory permission issue

**Solution**:

**Check DataNode logs**:
```bash
docker-compose logs datanode1 | tail -50
```

**Wait dan retry**:
```bash
# Tunggu 60 detik
sleep 60

# Check lagi
docker-compose exec namenode hdfs dfsadmin -report
```

**Restart DataNodes**:
```bash
docker-compose restart datanode1 datanode2 datanode3
```

**Nuclear option** (reset datanode data):
```bash
docker-compose down
rm -rf data/datanode1/* data/datanode2/* data/datanode3/*
docker-compose up -d
```

---

### 3. YARN NodeManagers Not Showing

**Symptom**:
```bash
docker-compose exec resourcemanager yarn node -list
# Output: Total Nodes:0
```

**Check NodeManager logs**:
```bash
docker-compose logs nodemanager1 | tail -50
```

**Solution**:
```bash
# Restart NodeManagers
docker-compose restart nodemanager1 nodemanager2 nodemanager3

# Wait 30 seconds
sleep 30

# Check again
docker-compose exec resourcemanager yarn node -list
```

---

### 4. Port Already in Use

**Error**:
```
Error: bind: address already in use 0.0.0.0:9870
```

**Cause**: Port 9870 atau 8088 sudah digunakan aplikasi lain

**Solution**:

**Check what's using the port**:
```bash
lsof -i :9870
lsof -i :8088
```

**Option 1: Stop conflicting application**

**Option 2: Change port** di `docker-compose.yml`:
```yaml
namenode:
  ports:
    - "19870:9870"  # Use 19870 instead
```

---

### 5. Disk Space Full

**Symptom**:
```bash
docker-compose exec namenode hdfs dfsadmin -report
# DFS Used%: 95%+
```

**Solution**:

**Check disk usage**:
```bash
docker-compose exec namenode hdfs dfs -du -h /
```

**Delete unnecessary files**:
```bash
docker-compose exec namenode hdfs dfs -rm -r /path/to/large/directory
```

**Clean YARN logs** (older than 7 days):
```bash
docker-compose exec resourcemanager yarn logs -applicationId <app_id> -delete
```

---

### 6. Container Keeps Restarting

**Check container status**:
```bash
docker-compose ps
docker inspect <container_name>
```

**Check resource limits**:
```bash
docker stats
```

**Solution**: Increase Docker resource limits
- Docker Desktop: Settings → Resources → Memory/CPU

---

### 7. Permission Denied Errors

**Error in logs**:
```
Permission denied: user=root, access=WRITE, inode="/user":hadoop:supergroup:drwxr-xr-x
```

**Cause**: HDFS permission issue

**Solution**:
```bash
# Change ownership
docker-compose exec namenode hdfs dfs -chown -R root:supergroup /user

# Or change permissions
docker-compose exec namenode hdfs dfs -chmod -R 777 /user
```

---

### 8. Network Issues Between Containers

**Symptom**: Services can't communicate

**Check network**:
```bash
docker network ls
docker network inspect hadoop_default
```

**Solution**:
```bash
# Recreate network
docker-compose down
docker network prune
docker-compose up -d
```

---

### 9. Complete Cluster Reset

**When**: Cluster dalam kondisi tidak recoverable

**Steps**:
```bash
# 1. Stop semua containers
docker-compose down

# 2. Hapus semua data (CAUTION: DATA LOSS!)
rm -rf data/*

# 3. Format namenode
docker-compose run --rm namenode hdfs namenode -format -force

# 4. Start fresh cluster
docker-compose up -d

# 5. Verify
sleep 30
docker-compose ps
docker-compose exec namenode hdfs dfsadmin -report
```

---

## Best Practices

### 1. Backup Strategy

**Critical Data** (backup daily):
```bash
# Backup namenode metadata
tar -czf namenode-backup-$(date +%Y%m%d).tar.gz data/namenode/

# Upload to cloud storage
# aws s3 cp namenode-backup-*.tar.gz s3://your-bucket/
```

**Full Cluster Backup** (backup weekly):
```bash
tar -czf hadoop-full-backup-$(date +%Y%m%d).tar.gz data/
```

### 2. Monitoring

**Setup periodic health checks**:
```bash
# Add to crontab
*/5 * * * * cd /path/to/docker && docker-compose exec -T namenode hdfs dfsadmin -report > /var/log/hdfs-report.log
```

**Monitor disk usage**:
```bash
watch -n 60 "docker-compose exec namenode hdfs dfs -df -h"
```

### 3. Resource Management

**Limit container resources** di `docker-compose.yml`:
```yaml
namenode:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 4G
```

### 4. Log Management

**Rotate logs**:
```bash
# Clear old logs
docker-compose exec namenode rm -rf /var/log/hadoop/*.log.old
```

**Limit log size** di config:
```
LOG.DIR=/var/log/hadoop
LOG.MAXFILESIZE=100MB
LOG.MAXBACKUPINDEX=10
```

### 5. Security

**Production environment**:
1. Enable Kerberos authentication
2. Enable HDFS encryption
3. Setup SSL/TLS for web UIs
4. Use firewall rules untuk port access
5. Regular security updates untuk Docker image

### 6. Performance Tuning

**HDFS Block Size**:
```
HDFS-SITE.XML_dfs.blocksize=134217728  # 128MB
```

**YARN Memory**:
```
YARN-SITE.XML_yarn.nodemanager.resource.memory-mb=8192
YARN-SITE.XML_yarn.scheduler.maximum-allocation-mb=4096
```

---

## Additional Resources

**Official Documentation**:
- Hadoop HDFS: https://hadoop.apache.org/docs/r3.3.6/hadoop-project-dist/hadoop-hdfs/HdfsDesign.html
- Hadoop YARN: https://hadoop.apache.org/docs/r3.3.6/hadoop-yarn/hadoop-yarn-site/YARN.html
- MapReduce: https://hadoop.apache.org/docs/r3.3.6/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html

**Docker Image**:
- apache/hadoop:3 - https://hub.docker.com/r/apache/hadoop

**Troubleshooting Resources**:
- Apache Hadoop Wiki: https://cwiki.apache.org/confluence/display/HADOOP
- Stack Overflow: Tag `apache-hadoop`

---

## Changelog

**v1.0.0** - Initial cluster setup
- 3-node HDFS configuration
- 3-node YARN configuration
- Persistent storage implementation
- Project naming ("hadoop")
- Comprehensive documentation

---

## License

This project configuration is based on Apache Hadoop (Apache License 2.0).

---

## Contact & Support

Untuk pertanyaan atau issue, silakan buka issue di repository atau hubungi maintainer.

**Happy Hadooping! 🐘**
