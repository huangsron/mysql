# mysql replication

```shell
# login to master
docker-compose exec master mysql -u root -padmin123

show variables like 'log_%';
show master status;\G

show databases;

# 建立使用帳號
CREATE USER 'repl'@'%' IDENTIFIED BY 'repl';

GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';

CREATE DATABASE `repl`;

use repl;
create table if not exists code(code int);
insert into code values (100), (101),(102),(200);

show master status;\G
exit


# get master ip
docker inspect replication_master_1 -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'

# login to slave
docker-compose exec slave1 mysql -u root -padmin123
docker-compose exec slave2 mysql -u root -padmin123

change master to
master_host='172.23.0.2',
master_user='repl',
master_password='repl',
master_port=3306,
master_log_file=' mysql-bin.000003',
master_log_pos=154,
master_connect_retry=30;

start slave;

SHOW SLAVE STATUS\G;
FLUSH PRIVILEGES;

show databases;
use repl;
select * from code;

```

## sql
```shell
docker-compose exec master mysql -u root -padmin123

#获取binlog文件列表
show binary logs;

#只查看第一个binlog文件的内容
show binlog events;

#查看指定binlog文件的内容
show binlog events in 'mysql-bin.000003';

#查看当前正在写入的binlog文件
show master status;
```

## change binlog_format online



```
mysql> set global binlog_format= ROW

mysql> set global binlog_format= STATEMENT

mysql> set global binlog_format= MIXED
```
### ref
> <https://www.cnblogs.com/xinysu/p/6607658.html>