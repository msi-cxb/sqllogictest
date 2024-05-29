# sqllogic test

[sqllogic test](https://www.sqlite.org/sqllogictest/doc/trunk/about.wiki)




# Build

```shell
apt-get install unixodbc-dev
```

`cd  src`

```shell
make
```

# Run

## Install ODBC

### Download 

https://dev.mysql.com/downloads/connector/odbc/

```shell
wget https://dev.mysql.com/get/Downloads/Connector-ODBC/8.4/mysql-connector-odbc-8.4.0-linux-glibc2.28-x86-64bit.tar.gz
tar -zxvf mysql-connector-odbc-8.4.0-linux-glibc2.28-x86-64bit.tar.gz
```

### Install

```shell
cp bin/* /usr/local/bin
cp lib/* /usr/local/lib
myodbc-installer -a -d -n "MySQL ODBC 8.4 Unicode Driver" -t "Driver=/usr/local/lib/libmyodbc8w.so"
myodbc-installer -a -d -n "MySQL ODBC 8.4 ANSI Driver" -t "Driver=/usr/local/lib/libmyodbc8a.so"
```

### Verify

```shell
myodbc-installer -d -l
```


## Config Data Source

`~/.odbc.ini`

```text
[MySQLDataSource]
Driver = MySQL ODBC 8.4 Unicode Driver
Server = 127.0.0.1
Port = 3306
Database = test
User = root
```


## Run Test

```shell
./src/sqllogictest -odbc DSN=MySQLDataSource  -verify ./test/select1.test
```


