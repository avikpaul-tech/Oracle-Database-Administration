------------------------------------------------------------------------------------------------------------
--UNDO Session Details
select s.sid,s.inst_id,s.serial#,s.username,s.osuser, sql_id, round(last_call_et/60) as Last_CALL_ET, module, program,
-- machine, 
s.status, floor((t.used_ublk * 8192)/(1024*1024*1024)) Undo_Usage_Gb
from gv$session s, gv$transaction t, (select round(sum(bytes)/1024/1024) total from dba_data_files where tablespace_name like '%UNDO%') tu
where s.taddr = t.addr and upper(s.type) <> 'BACKGROUND' and floor((t.used_ublk * 8192)/(1024*1024*1024)) > 1 
order by 1 desc;

--UNDO Session Details & conurrent requests
select s.sid,s.inst_id,s.serial#,c.spid,a.request_id,d.program,s.status,s.username,s.osuser,s.client_identifier,sql_id, 
round(last_call_et/60) as Last_CALL_ET, 
machine, 
floor((t.used_ublk * 8192)/(1024*1024*1024)) Undo_Usage_Gb
from gv$session s, gv$process c,apps.fnd_concurrent_requests a,gv$transaction t, apps.FND_CONC_REQ_SUMMARY_V d,
(select round(sum(bytes)/1024/1024) total from dba_data_files where tablespace_name like '%UNDO%') tu
where s.taddr = t.addr 
AND s.paddr = c.addr 
AND a.oracle_process_id = c.spid  
and d.request_id=a.request_id
AND a.phase_code = UPPER ('R') and upper(s.type) <> 'BACKGROUND' and floor((t.used_ublk * 8192)/(1024*1024*1024)) > 1 
order by Undo_Usage_Gb desc;
--------------------------------------------------------------------------------------------------------------------
--Undo  space utilization
set linesize 200
set pages 99
set verify off
Prompt
Prompt Global Undo Tablespace Details
Prompt #######################
Prompt
col Undo_Retention format a10
select /*+ parallel(64) */ 
a.tablespace_name,nvl(a.tot,0) "Total Size in GB",
       round((nvl(a.tot,0))) - (nvl(round(b.active,2),0)+nvl(d.unexpired,0)+nvl(c.expired,0)) as Free_Space,
       nvl(round(b.active,2),0) "Used/Active in GB",
       nvl(round((b.active*100/a.tot),2),0) percent_used,
       nvl(d.unexpired,0) "Unexpired in GB",nvl(c.expired,0) "Expired in GB",f.undo_ret Undo_Retention
from
(select tablespace_name, round(sum(bytes)/(1024*1024*1024),2) tot
  from dba_data_files where tablespace_name in (select value from gv$parameter where name='undo_tablespace')
 group by tablespace_name) a,
(select tablespace_name,round(sum(bytes)/1024/1024/1024,2) active from dba_undo_extents where status='ACTIVE' group by tablespace_name) b,
(select tablespace_name,round(sum(bytes)/1024/1024/1024,2) expired from dba_undo_extents where status='EXPIRED' group by tablespace_name) c,
(select tablespace_name,round(sum(bytes)/1024/1024/1024,2) unexpired from dba_undo_extents where status='UNEXPIRED' group by tablespace_name) d,
(select tablespace_name,ltrim(round(sum(bytes)/1024/1024)) free  from dba_data_files
  where tablespace_name in (select value from gv$parameter where name='undo_tablespace')
 group by tablespace_name) e,
(select y.value tablespace_name,x.value undo_ret from
(select inst_id,value from gv$parameter where name='undo_retention') x,
(select inst_id,value from gv$parameter where name='undo_tablespace') y
where x.inst_id=y.inst_id) f
where a.tablespace_name=b.tablespace_name(+)
and a.tablespace_name=c.tablespace_name(+)
and a.tablespace_name=d.tablespace_name(+)
and a.tablespace_name=e.tablespace_name(+)
and a.tablespace_name=f.tablespace_name(+)
order by 1
;
--------------------------------------------------------------------------------------------------------------------
select status, count(*) Num_Extents, sum(blocks) Num_Blocks, round((sum(bytes)/1024/1024),2) MB from dba_undo_extents group by status order by status

SELECT s.inst_id,
       s.username,
       s.sid,
       s.serial#,
       t.used_ublk,
       t.used_urec,
       rs.segment_name,
       r.rssize,
       r.status
FROM   gv$transaction t,
       gv$session s,
       gv$rollstat r,
       dba_rollback_segs rs
WHERE  s.saddr = t.ses_addr
AND    s.inst_id = t.inst_id
AND    t.xidusn = r.usn
AND    t.inst_id = r.inst_id
AND    rs.segment_id = t.xidusn
ORDER BY t.used_ublk DESC