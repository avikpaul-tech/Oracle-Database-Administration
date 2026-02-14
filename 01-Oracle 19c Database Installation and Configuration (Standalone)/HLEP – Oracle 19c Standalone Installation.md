1. Run oracle19cPreinstallations.sh
2. Run oracle19cPackageInstall.sh
3. Set password for oracle 
4. Crosscheck required directory and permissions
5. Copy the oracle database binary and unzip in ORACLE_HOME location
6. Set the .bash_profile of oracle user
7. Run prerequisite
```
./runInstaller -executePrereqs -silent -responseFile /scripts/db_install.rsp
```
8. Install database
```
./runInstaller -silent -responseFile /scripts/db_install.rsp
```
9. Configure FRA and ARCHIVEMODE after database creation
```
alter system set db_recovery_file_dest_size=4G SCOPE=BOTH;
alter system set db_recovery_file_dest='/fra' scope=both;
ALTER SYSTEM SET log_archive_dest_1='LOCATION=/arch' scope=both;
shutdown immediate
startup mount
alter database archivelog;
alter database open;
alter pluggable database all open;
```
