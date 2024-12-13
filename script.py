#!/usr/bin/python3
import subprocess, os, random, string, sys, shutil, socket, time, io

if sys.version_info.major != 3:
    print("Please run with python3.")
    sys.exit(1)

rPath = os.path.dirname(os.path.realpath(__file__))
rPackages = ["cpufrequtils", "iproute2", "python", "net-tools", "dirmngr", "gpg-agent", "software-properties-common", "libmaxminddb0", "libmaxminddb-dev", "mmdb-bin", "libcurl4", "libgeoip-dev", "libxslt1-dev", "libonig-dev", "e2fsprogs", "wget", "mariadb-server", "sysstat", "alsa-utils", "v4l-utils", "mcrypt", "certbot", "iptables-persistent", "libjpeg-dev", "libpng-dev", "php-ssh2", "xz-utils", "zip", "unzip"]
rRemove = ["mysql-server"]
rMySQLCnf = '# XUI\n[client]\nport                            = 3306\n\n[mysqld_safe]\nnice                            = 0\n\n[mysqld]\nuser                            = mysql\nport                            = 3306\nbasedir                         = /usr\ndatadir                         = /var/lib/mysql\ntmpdir                          = /tmp\nlc-messages-dir                 = /usr/share/mysql\nskip-external-locking\nskip-name-resolve\nbind-address                    = *\n\nkey_buffer_size                 = 128M\nmyisam_sort_buffer_size         = 4M\nmax_allowed_packet              = 64M\nmyisam-recover-options          = BACKUP\nmax_length_for_sort_data        = 8192\nquery_cache_limit               = 0\nquery_cache_size                = 0\nquery_cache_type                = 0\nexpire_logs_days                = 10\nmax_binlog_size                 = 100M\nmax_connections                 = 8192\nback_log                        = 4096\nopen_files_limit                = 20240\ninnodb_open_files               = 20240\nmax_connect_errors              = 3072\ntable_open_cache                = 4096\ntable_definition_cache          = 4096\ntmp_table_size                  = 1G\nmax_heap_table_size             = 1G\n\ninnodb_buffer_pool_size         = 10G\ninnodb_buffer_pool_instances    = 10\ninnodb_read_io_threads          = 64\ninnodb_write_io_threads         = 64\ninnodb_thread_concurrency       = 0\ninnodb_flush_log_at_trx_commit  = 0\ninnodb_flush_method             = O_DIRECT\nperformance_schema              = 0\ninnodb-file-per-table           = 1\ninnodb_io_capacity              = 20000\ninnodb_table_locks              = 0\ninnodb_lock_wait_timeout        = 0\n\nsql_mode                        = "NO_ENGINE_SUBSTITUTION"\n\n[mariadb]\n\nthread_cache_size               = 8192\nthread_handling                 = pool-of-threads\nthread_pool_size                = 12\nthread_pool_idle_timeout        = 20\nthread_pool_max_threads         = 1024\n\n[mysqldump]\nquick\nquote-names\nmax_allowed_packet              = 16M\n\n[mysql]\n\n[isamchk]\nkey_buffer_size                 = 16M'
rConfig = '; XUI Configuration\n; -----------------\n; Your username and password will be encrypted and\n; saved to the \'credentials\' file in this folder\n; automatically.\n;\n; To change your username or password, modify BOTH\n; below and XUI will read and re-encrypt them.\n\n[XUI]\nhostname    =   "127.0.0.1"\ndatabase    =   "xui"\nport        =   3306\nserver_id   =   1\nlicense     =   ""\n\n[Encrypted]\nusername    =   "%s"\npassword    =   "%s"'
rRedisConfig = "bind *\nprotected-mode yes\nport 6379\ntcp-backlog 511\ntimeout 0\ntcp-keepalive 300\ndaemonize yes\nsupervised no\npidfile /home/xui/bin/redis/redis-server.pid\nloglevel warning\nlogfile /home/xui/bin/redis/redis-server.log\ndatabases 1\nalways-show-logo yes\nstop-writes-on-bgsave-error no\nrdbcompression no\nrdbchecksum no\ndbfilename dump.rdb\ndir /home/xui/bin/redis/\nslave-serve-stale-data yes\nslave-read-only yes\nrepl-diskless-sync no\nrepl-diskless-sync-delay 5\nrepl-disable-tcp-nodelay no\nslave-priority 100\nrequirepass #PASSWORD#\nmaxclients 655350\nlazyfree-lazy-eviction no\nlazyfree-lazy-expire no\nlazyfree-lazy-server-del no\nslave-lazy-flush no\nappendonly no\nappendfilename \"appendonly.aof\"\nappendfsync everysec\nno-appendfsync-on-rewrite no\nauto-aof-rewrite-percentage 100\nauto-aof-rewrite-min-size 64mb\naof-load-truncated yes\naof-use-rdb-preamble no\nlua-time-limit 5000\nslowlog-log-slower-than 10000\nslowlog-max-len 128\nlatency-monitor-threshold 0\nnotify-keyspace-events \"\"\nhash-max-ziplist-entries 512\nhash-max-ziplist-value 64\nlist-max-ziplist-size -2\nlist-compress-depth 0\nset-max-intset-entries 512\nzset-max-ziplist-entries 128\nzset-max-ziplist-value 64\nhll-sparse-max-bytes 3000\nactiverehashing yes\nclient-output-buffer-limit normal 0 0 0\nclient-output-buffer-limit slave 256mb 64mb 60\nclient-output-buffer-limit pubsub 32mb 8mb 60\nhz 10\naof-rewrite-incremental-fsync yes\nsave 60 1000\nserver-threads 4\nserver-thread-affinity true"
rSysCtl = '# XUI.one\n\nnet.ipv4.tcp_congestion_control = bbr\nnet.core.default_qdisc = fq\nnet.ipv4.tcp_rmem = 8192 873 134217728\nnet.ipv4.udp_rmem_min = 16384\nnet.core.rmem_default = 262144\nnet.core.rmem_max = 268435456\nnet.ipv4.tcp_wmem = 8192 65536 134217728\nnet.ipv4.udp_wmem_min = 16384\nnet.core.wmem_default = 262144\nnet.core.wmem_max = 268435456\nnet.core.somaxconn = 1000000\nnet.core.netdev_max_backlog = 250000\nnet.core.optmem_max = 65535\nnet.ipv4.tcp_max_tw_buckets = 1440000\nnet.ipv4.tcp_max_orphans = 16384\nnet.ipv4.ip_local_port_range = 2000 65000\nnet.ipv4.tcp_no_metrics_save = 1\nnet.ipv4.tcp_slow_start_after_idle = 0\nnet.ipv4.tcp_fin_timeout = 15\nnet.ipv4.tcp_keepalive_time = 300\nnet.ipv4.tcp_keepalive_probes = 5\nnet.ipv4.tcp_keepalive_intvl = 15\nfs.file-max=20970800\nfs.nr_open=20970800\nfs.aio-max-nr=20970800\nnet.ipv4.tcp_timestamps = 1\nnet.ipv4.tcp_window_scaling = 1\nnet.ipv4.tcp_mtu_probing = 1\nnet.ipv4.route.flush = 1\nnet.ipv6.route.flush = 1'
rSystemd = '[Unit]\nSourcePath=/home/xui/service\nDescription=XUI.one Service\nAfter=network.target\nStartLimitIntervalSec=0\n\n[Service]\nType=simple\nUser=root\nRestart=always\nRestartSec=1\nExecStart=/bin/bash /home/xui/service start\nExecRestart=/bin/bash /home/xui/service restart\nExecStop=/bin/bash /home/xui/service stop\n\n[Install]\nWantedBy=multi-user.target'
rChoice = "23456789abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ"

rVersions = {
    "14.04": "trusty",
    "16.04": "xenial",
    "18.04": "bionic",
    "20.04": "focal",
    "20.10": "groovy",
    "21.04": "hirsute",
    "21.10": "impish"
}

class col:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def printColor(msg, color):
    print(f"{color}{msg}{col.ENDC}")

def checkFile(filename):
    if not os.path.isfile(filename):
        printColor(f"{filename} not found!", col.FAIL)
        sys.exit(1)

def checkDir(dirname):
    if not os.path.isdir(dirname):
        printColor(f"{dirname} not found!", col.FAIL)
        sys.exit(1)

def isRoot():
    if os.geteuid() != 0:
        printColor("You must run this as root!", col.FAIL)
        sys.exit(1)

def getIP():
    ip = ""
    try:
        ip = socket.gethostbyname(socket.gethostname())
    except:
        pass
    return ip

def runCommand(command):
    try:
        subprocess.check_call(command, shell=True)
    except subprocess.CalledProcessError as e:
        printColor(f"Command failed: {e}", col.FAIL)
        sys.exit(1)

def getRandomString(length=10):
    return ''.join(random.choice(rChoice) for i in range(length))

def getServerVersion():
    version = ""
    try:
        version = subprocess.check_output(["lsb_release", "-r"]).decode("utf-8").split(":")[1].strip()
    except:
        pass
    return version

def main():
    version = getServerVersion()
    if version not in rVersions:
        printColor(f"Unsupported version: {version}", col.FAIL)
        sys.exit(1)

    printColor("Starting installation...", col.OKGREEN)

    for package in rPackages:
        runCommand(f"apt-get install -y {package}")

    for package in rRemove:
        runCommand(f"apt-get remove -y {package}")

    # Add MySQL configuration
    with open("/etc/mysql/my.cnf", "w") as f:
        f.write(rMySQLCnf)

    # Add Redis configuration
    with open("/etc/redis/redis.conf", "w") as f:
        f.write(rRedisConfig)

    # Add sysctl configuration
    with open("/etc/sysctl.conf", "a") as f:
        f.write(rSysCtl)

    # Add systemd service
    with open("/etc/systemd/system/xui.service", "w") as f:
        f.write(rSystemd)

    # Reload systemd and enable the service
    runCommand("systemctl daemon-reload")
    runCommand("systemctl enable xui")
    runCommand("systemctl start xui")

    printColor("Installation complete!", col.OKGREEN)

if __name__ == "__main__":
    main()
