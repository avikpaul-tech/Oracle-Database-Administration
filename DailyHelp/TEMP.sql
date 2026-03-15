-----Temp Sessions-----------
set lines 300
set colsep |
--col Temp_GB for 9999999
col Temp_MB for 9999999
col username for a10
col Instance for 99999999
col sid_serial for a10
col event for a20
col program for a25

SELECT 
ROUND(((b.blocks*p.value)/1024/1024/1024),2) AS Temp_GB,
--ROUND(((b.blocks*p.value)/1024/1024),2) AS Temp_MB,
NVL(a.username, '(oracle)') AS username,
a.inst_id as Instance,
       a.sid||','||a.serial# AS sid_serial,
       a.status,
       --||','||
       --a.blocking_session as blocking_sess,a.blocking_instance as block_inst,
       --a.FINAL_BLOCKING_SESSION,a.FINAL_BLOCKING_INSTANCE,osuser,a.BLOCKING_SESSION_STATUS, 
       a.event,
       a.program,
	   a.machine,
	   --TO_CHAR(a.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time,
	   TO_CHAR(a.logon_Time,'DD/MM/YY HH24:MI') AS logon_time,
	   --a.logon_Time logon_time,
       a.sql_id
FROM   gv$session a,
       gv$sort_usage b,
       gv$parameter p
WHERE  p.name  = 'db_block_size'
AND    a.saddr = b.session_addr
AND    a.inst_id=b.inst_id
AND    a.inst_id=p.inst_id
and ROUND(((b.blocks*p.value)/1024/1024),2)>10000
ORDER BY b.tablespace, b.blocks desc;


-----Temp Percent-----------
select a.tablespace,b.tot "Total in GB",a.used "Used in GB",trim(ROUND(100-((1-(a.used/b.tot))*100))) used_pct
from
(select s.tablespace,round(sum((s.blocks*p.value)/1024/1024/1024),0) used from gv$sort_usage s, v$parameter p where p.name='db_block_size' group by s.tablespace) a,
(select tablespace_name,round(sum(bytes/1024/1024/1024),0) tot from dba_temp_files group by tablespace_name) b
where a.tablespace=b.tablespace_name
order by 2 desc;


--Query to see Current Temp Datafiles State
-------------------------------------------
set pages 999
set lines 400
col FILE_NAME format a75
select d.TABLESPACE_NAME, d.FILE_NAME, d.BYTES/1024/1024 SIZE_MB, d.AUTOEXTENSIBLE, d.MAXBYTES/1024/1024 MAXSIZE_MB, d.INCREMENT_BY*(v.BLOCK_SIZE/1024)/1024 INCREMENT_BY_MB
from dba_temp_files d,
 v$tempfile v
where d.FILE_ID = v.FILE#
order by d.TABLESPACE_NAME, d.FILE_NAME;


--Add Temp Datafile to Temp Tablespace
--------------------------------------

ALTER TABLESPACE TEMP ADD TEMPFILE '+DATAC1' SIZE 16000M;









SELECT 
    TABLESPACE_NAME,
    ROUND(SUM(BYTES_USED) / 1024 / 1024, 2) AS USED_MB,
    ROUND(SUM(BYTES_FREE) / 1024 / 1024, 2) AS FREE_MB,
    ROUND(SUM(BYTES_USED + BYTES_FREE) / 1024 / 1024, 2) AS TOTAL_MB,
    ROUND((SUM(BYTES_USED) / SUM(BYTES_USED + BYTES_FREE)) * 100, 2) AS USED_PCT
FROM 
    V$TEMP_SPACE_HEADER
GROUP BY 
    TABLESPACE_NAME;
	

col username for a15
col osuser for a15	
col program for a40
col tablespace for a10
SELECT
    s.sid,
    s.serial#,
    s.username,
    s.osuser,
    s.program,
    t.tablespace,
    ROUND(t.blocks * ts.block_size / 1024 / 1024, 2) AS temp_mb
FROM
    gv$sort_usage t
JOIN
    gv$session s ON t.session_addr = s.saddr
JOIN
    dba_tablespaces ts ON ts.tablespace_name = t.tablespace
WHERE
    t.tablespace IN ('TEMP', 'TEMP1')  -- your temp tablespaces
ORDER BY
    temp_mb DESC;	
	