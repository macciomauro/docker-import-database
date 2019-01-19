# Docker Import Database

## Setup environments

You need to copy .env.dist and rename it as you want, removing *.dist suffix.

Every *.env file represents a project, for example you can have "my-personal-site.env".
 
You can have as many .env file as you need, once for project.

Fill all the parameters inside the file before start dumping.

> DUMP_DIR is the directory where you need to put database backups

## Start dumping

```
$ cd docker-import-database
$ bash restore-db.sh
```
Then write inside the bash the env name you want to use without .env extension like this:

```
...
Tell me .env name and press [ENTER]:
my-personal-site
-----------------------------------------------------
Using my-personal-site.env
...
```
If you did right, you only need to choose from a list the database dump you want to import

#### ATTENTION: all previous data will be lost!
 
