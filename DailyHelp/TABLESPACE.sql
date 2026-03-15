--ADD DATAFILE TO TABLESPACE MANUALLY
-------------------------------------
alter tablespace APPS_TS_TX_DATA add datafile '+DG_CFNPRD_DT04/oradata/apps_ts_tx_data_3121.dbf' size 16000M;


--RESIZE DATAFILE
-----------------
alter database datafile '/info/data/oradata/ZEIT36/sysaux01.dbf' RESIZE 8000M;


--CHECK SINGLE TABLESPACE USAGE
-------------------------------

COLUMN in_M              FORMAT 9999
COLUMN nx_M              FORMAT 9999
COLUMN pct               FORMAT 99       HEADING %I
COLUMN status            FORMAT A5       HEADING STATE      TRUNC
COLUMN contents          FORMAT A9
COLUMN logging           FORMAT A7                          TRUNC
COLUMN extent_management FORMAT A10       HEADING EXTNT_MGMT     TRUNC
COLUMN allocation_type   FORMAT A10       HEADING ALLOCATION TRUNC
COLUMN segment_space_management  FORMAT A12       HEADING SEG_SPC_MGMT     TRUNC


SET    PAGESIZE 500 LINES 200
COLUMN tablespace_name   FORMAT A25
select
        a.TABLESPACE_NAME
        , round(a.bytes_used/(1024*1024*1024),2) TOTAL_SPACE_IN_GB
        , round(b.bytes_free/(1024*1024*1024),2) FREE_SPACE_IN_GB
        , round(((a.bytes_used-b.bytes_free)/a.bytes_used)*100,2) percent_used
from
        (select TABLESPACE_NAME, sum(bytes) bytes_used from dba_data_files group by TABLESPACE_NAME) a
        , (select TABLESPACE_NAME, sum(BYTES) bytes_free, max(BYTES) largest from dba_free_space group by TABLESPACE_NAME) b
        , (select TABLESPACE_NAME, bytes, count(1) cnt from dba_free_space where (TABLESPACE_NAME, bytes) in (select TABLESPACE_NAME, max(bytes) from dba_free_space group by TABLESPACE_NAME) group by TABLESPACE_NAME, bytes) c
        , dba_tablespaces d
where
        a.TABLESPACE_NAME=b.TABLESPACE_NAME(+)
        and a.tablespace_name=c.tablespace_name
        and a.tablespace_name=d.tablespace_name
        and d.contents = 'PERMANENT'
        and a.tablespace_name = upper('&tablespace_name')
order by
        ((a.BYTES_used-b.BYTES_free)/a.BYTES_used) desc;


--CHECK ALL TABLESPACE USAGE
----------------------------
set linesize 100 pages 100 trimspool on numwidth 14 
col name format a25
col owner format a15 
col "Used (GB)" format a15
col "Free (GB)" format a15 
col "(Used) %" format a15 
col "Size (M)" format a15 
SELECT d.status "Status", d.tablespace_name "Name", 
 TO_CHAR(NVL(a.bytes / 1024 / 1024 /1024, 0),'99,999,990.90') "Size (GB)", 
 TO_CHAR(NVL(a.bytes - NVL(f.bytes, 0), 0)/1024/1024 /1024,'99999999.99') "Used (GB)", 
 TO_CHAR(NVL(f.bytes / 1024 / 1024 /1024, 0),'99,999,990.90') "Free (GB)", 
 TO_CHAR(NVL((a.bytes - NVL(f.bytes, 0)) / a.bytes * 100, 0), '990.00') "(Used) %"
 FROM sys.dba_tablespaces d, 
 (select tablespace_name, sum(bytes) bytes from dba_data_files group by tablespace_name) a, 
 (select tablespace_name, sum(bytes) bytes from dba_free_space group by tablespace_name) f WHERE 
 d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = f.tablespace_name(+) AND NOT 
 (d.extent_management like 'LOCAL' AND d.contents like 'TEMPORARY') 
UNION ALL 
SELECT d.status 
 "Status", d.tablespace_name "Name", 
 TO_CHAR(NVL(a.bytes / 1024 / 1024 /1024, 0),'99,999,990.90') "Size (GB)", 
 TO_CHAR(NVL(t.bytes,0)/1024/1024 /1024,'99999999.99') "Used (GB)",
 TO_CHAR(NVL((a.bytes -NVL(t.bytes, 0)) / 1024 / 1024 /1024, 0),'99,999,990.90') "Free (GB)", 
 TO_CHAR(NVL(t.bytes / a.bytes * 100, 0), '990.00') "(Used) %" 
 FROM sys.dba_tablespaces d, 
 (select tablespace_name, sum(bytes) bytes from dba_temp_files group by tablespace_name) a, 
 (select tablespace_name, sum(bytes_cached) bytes from v$temp_extent_pool group by tablespace_name) t 
 WHERE d.tablespace_name = a.tablespace_name(+) AND d.tablespace_name = t.tablespace_name(+) AND 
 d.extent_management like 'LOCAL' AND d.contents like 'TEMPORARY'
order by 2;



--DATAFILE DETAILS OF A TABLESPACE
----------------------------------
set lines 300
col FILE_NAME for a60
col TABLESPACE_NAME for a25
select 
	FILE_NAME,
	TABLESPACE_NAME,
	BYTES/1024/1024 SIZE_IN_MB,
	AUTOEXTENSIBLE
from dba_data_files 
where 
	TABLESPACE_NAME='&TABLESPACE_NAME' 
order by FILE_NAME;


--UNDO TABLESPACE STATUS
------------------------
select a.tbl "Name",a.tsz "Total Size",b.fsz "Free Space", round((1-(b.fsz/a.tsz))*100) "Pct Used",
round((b.fsz/a.tsz)*100) "Pct Free" from (select tablespace_name tbl,sum(bytes)/1024/1024 TSZ from dba_data_files 
where tablespace_name like '%UNDO%' group by tablespace_name) a, (select tablespace_name tblsp,sum(bytes)/1024/1024 FSZ 
from dba_free_space where tablespace_name like '%UNDO%' group by tablespace_name) b Where a.tbl=b.tblsp;