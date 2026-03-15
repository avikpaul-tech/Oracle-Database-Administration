--CHECK ARCHIVE DISKGROUP USAGE
set lines 300 pages 300
SELECT name,
	   total_mb/1024 total_gb,
	   free_mb/1024 free_gb, 
	   ((1- free_mb/total_mb)*100) "% Used" FROM v$asm_diskgroup 
where NAME like '%AR%' 
order by ((1- free_mb/total_mb)*100) desc;

--CHECK ABOUT DATABASE ROLE
select name,open_mode,database_role from v$database;


--RUN SAP

sudo -u oracle /auto/hosting/bin/Oracle/database/SmartArchivePurge/PRD/smart_arch_purge.pl -i YTS3CSF1 -E NPRD -r 24 -x EM -p avikpau@cisco.com




set lines 300 pages 300
SELECT name,
	   total_mb/1024 total_gb,
	   free_mb/1024 free_gb, 
	   ((1- free_mb/total_mb)*100) "% Used" FROM v$asm_diskgroup 
where NAME like '%FRA%' 
order by ((1- free_mb/total_mb)*100) desc;


Hourly archive generation
=========================
set pages 30
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

select trunc(COMPLETION_TIME,'HH') Hour,thread# , 
round(sum(BLOCKS*BLOCK_SIZE)/1024/1024/1024) GB,
count(*) Archives from v$archived_log 
where standby_dest='NO'
group by trunc(COMPLETION_TIME,'HH'),thread#  order by 1,2;

-----------------------------

set pages 30
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

select trunc(COMPLETION_TIME,'HH') Hour, 
round(sum(BLOCKS*BLOCK_SIZE)/1024/1024/1024) GB,
count(*) Archives from v$archived_log 
where standby_dest='NO'
group by trunc(COMPLETION_TIME,'HH')  order by 1,2;

Daily archive generation
=========================
set pages 30
alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';
select trunc(COMPLETION_TIME,'DD') Day, thread#, 
round(sum(BLOCKS*BLOCK_SIZE)/1024/1024/1024) GB,
count(*) Archives_Generated from v$archived_log 
where standby_dest='NO'
group by trunc(COMPLETION_TIME,'DD'),thread# order by 1,2;