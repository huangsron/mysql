# mysql backup

## run

```shell
# init
docker-compose up -d

# enter container
docker-compose exec mysql bash

# import database
cd /tmp/sql/test_db/
mysql -u root -pdbadmin1234 < employees.sql
exit

# execute backup
docker-compose exec mysql sh -c "chmod 755 /tmp/sql/backup/backup.sh; /tmp/sql/backup/backup.sh"

sudo ls sql/db_backup/mysql

# stop container
docker-compose down
```

## clean

```shell
sudo git clean -f -X -d
```

## add test_db to project

```shell
git submodule add https://github.com/datacharmer/test_db.git singleton/sql/test_db
git submodule init
git submodule update --recursive
```

## note

```shell
docker-compose up -d

docker-compose exec mysql bash

cd /tmp/sql/test_db/
mysql -u root -pdbadmin1234 < employees.sql

mysql -u root -p
use employees;
select * from employees limit 10;

mysqldump -u root -p employees > /tmp/sql/backup/backup.sql

# restore database
mysql -u root -p
CREATE DATABASE `employees2`;
mysql -u root -p  employees2 < /tmp/sql/backup/backup.sql

mysql -u root -pdbadmin1234 -e "show databases;"

docker-compose down

# install mysql client
sudo apt install mysql-client

cat << EOF > .my.cnf
[client]
user=root
password=dbadmin1234
EOF

cat  .my.cnf

mysql --defaults-file=.my.cnf -h 127.0.0.1 -u root -pdbadmin1234 -e "show databases;"

# test backup
# docker-compose exec mysql sh -c "chown root:root /tmp/sql/backup/backup.sh; chmod 755 /tmp/sql/backup/backup.sh; /tmp/sql/backup/backup.sh"
docker-compose exec mysql sh -c "chmod 755 /tmp/sql/backup/backup.sh; /tmp/sql/backup/backup.sh"

sudo ls sql/db_backup/mysql
```

## create new database

```shell
docker-compose up -d

docker-compose exec mysql bash

# login db
mysql -u root -pdbadmin1234

# 新增資料庫
CREATE DATABASE `test_db`;
CREATE DATABASE `jumpserver`;

ICAgIGluZXQ2IDo6MS8xMjggc2
jumpserver-v2.13.2-2021-10-25_15:01:58.sql

# 新增使用者，設定密碼
CREATE USER 'test'@'localhost' IDENTIFIED BY 'test123';

# 設定使用者權限
GRANT ALL PRIVILEGES ON test_db.* TO 'test'@'localhost';

exit

# login to new database
mysql -u test -ptest123

use test_db;

CREATE TABLE products (  # 新增產品資料表
  id INT NOT NULL AUTO_INCREMENT, # 產品 ID
  name varchar(50) NOT NULL,  # 名稱
  descr varchar(200),  # 說明
  price INT NOT NULL,  # 價格

  PRIMARY KEY(id)      # 主要索引
);

# 插入資料
INSERT INTO products (name, descr, price)
  VALUES ("test 1", "test 1", 990);
INSERT INTO products (name, descr, price)
  VALUES ("test 2", "test 2", 1000);
INSERT INTO products (name, descr, price)
  VALUES ("test 3", "test 3", 1000);

select * from products;

# list table indexs
SHOW INDEX FROM products;

# create index
CREATE INDEX products_index ON products(price);
ALTER TABLE products ADD INDEX(price);

# create multiple column index
# CREATE INDEX email_tel_index ON member(email, tel);
# ALTER TABLE member ADD INDEX email_tel_index (email, tel);
```

## Explain
```sql
EXPLAIN SELECT * FROM products WHERE price < 1000;
```

type: 顯示的是查詢類型，是較為重要的一個指標值，依序從好到壞
system > const > eq_ref > ref > fulltext > ref_or_null > index_merge > unique_subquery > index_subquery > range > index > ALL

| type            | desc                                                                                                                       |
| --------------- | -------------------------------------------------------------------------------------------------------------------------- |
| System          | 表只有一行，這是一個 const type 的特殊情況                                                                                 |
| const           | 使用主鍵或者唯一索引的時候，當查詢的表僅有一行時，使用 System                                                              |
| eq_ref          | MySQL 在連接查詢時，會從最前面的資料表，對每一個記錄的聯合，從資料表中讀取一個記錄，在查詢時會使用索引為主鍵或唯一鍵的全部 |
| ref             | 只有在查詢使用了非唯一鍵或主鍵時才會發生                                                                                   |
| fulltext        | 使用全文索引的時候才會出現                                                                                                 |
| ref_or_null     | 查詢類型和 ref 很像，但是 MySQL 會做一個額外的查詢，來看哪些行包含了 NULL。這種類型常見於解析子查詢的優化                  |
| index_merge     | 在一個查詢裡面很有多索引用被用到，可能會觸發 index_merge 的優化機制                                                        |
| unique_subquery | 比 eq_ref 複雜的地方是使用了 in 的子查詢，而且是子查詢是主鍵或者唯一索引                                                   |
| index_subquery  | 和 unique_subquery 類似，但是它在子查詢裡使用的是非唯一索引。                                                              |
| range           | 使用索引返回一個範圍的結果，例如：使用大於 > 或小於 < 查詢時發生。                                                         |
| index           | 全表掃瞄，此為針對索引中的資料進行查詢，主要優點就是避免了排序，但是開銷仍然非常大                                         |
| ALL             | 針對每一筆記錄進行完全掃瞄，此為最壞的情況，應該儘量避免                                                                   |

## slow query

```shell
docker-compose up -d

docker-compose exec mysql bash

mysql -u root -pdbadmin1234
```

```sql
show variables like '%quer%';

-- turn on slow query
SET GLOBAL slow_query_log = 'ON';
-- setting the long query time
SET GLOBAL long_query_time = 1;
-- setting log path
set GLOBAL slow_query_log_file=/var/lib/mysql/slow.log;

-- long query sql
SELECT SLEEP(2);

exit
```

```shell
cat /var/lib/mysql/slow.log
```
