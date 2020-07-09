# azkaban

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with azkaban](#setup)
    * [What azkaban affects](#what-azkaban-affects)
    * [Setup requirements](#setup-requirements)

## Description

Azkaban module provides installation and configuration for:
 - Azkaban executor
 - Azkaban web
 - Azkaban CLI

It will also setup local mysql database.

## Setup

Include required classes in appropriate profile in following order:
azkaban::executor, azkaban::web, azkaban::cli

NOTICE: module doesn ot provide default settings - all necessary should be provided in hieradata

### Setup Requirements **OPTIONAL**

Following values are required in hieradata:

# azkaban
**mysql::server::root_password:** -> root password for mysql server
**mysql::server::remove_default_accounts:** true -> optional setting

# azkaban executor settings
**azkaban::executor::version:** -> executor package version

**azkaban::executor::mysql_port:** -> mysql port

**azkaban::executor::mysql_host:** -> mysql hostname

**azkaban::executor::mysql_database:** -> azkaban database name 

**azkaban::executor::mysql_user:** -> azkaban database user name

**azkaban::executor::mysql_password:** -> azkaban database user password

# azkaban web
**azkaban::web::instancename:** -> web instance name

**azkaban::web::instancelabel:** -> web instance label

**azkaban::web::version:** -> web package version

**azkaban::web::mysql_port:** -> mysql port

**azkaban::web::mysql_host:** -> my sql server

**azkaban::web::mysql_database:** -> database name

**azkaban::web::mysql_user:** -> database user name

**azkaban::web::mysql_password:** -> database user password 

**azkaban::web::http_port:** -> http port of web instance

**azkaban::web::executor_port:** -> executor port

**azkaban::web::mail_sender:** -> mail sender address

**azkaban::web::mail_host:** -> mail host

**azkaban::web::job_failure_email:** -> failure email destination address

**azkaban::web::job_success_email:** -> sucess email address

