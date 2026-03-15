--ASM DISKGROUP USAGE IN GB
 
set lines 400
set pages 999
col GROUP_NAME for a35
SELECT
name group_name
, sector_size sector_size
, block_size block_size
, allocation_unit_size allocation_unit_size
, state state
, type type
, round(total_mb/1024,2) total_gb
, round((total_mb - free_mb)/1024,2) used_gb
,round(free_mb/1024,2) free_gb
, ROUND((1- (free_mb / total_mb))*100, 2) pct_used
FROM
v$asm_diskgroup
ORDER BY
name
; 




set lines 400
set pages 999
col GROUP_NAME for a35
SELECT
name group_name
, round(total_mb/1024,2) total_gb
, round((total_mb - free_mb)/1024,2) used_gb
,round(free_mb/1024,2) free_gb
, ROUND((1- (free_mb / total_mb))*100, 2) pct_used
FROM
v$asm_diskgroup
ORDER BY
name
;


set lines 400
set pages 999
col GROUP_NAME for a35
with tab1 AS
(
SELECT
name group_name
, round(total_mb/1024,2) total_gb
, round((total_mb - free_mb)/1024,2) used_gb
,round(free_mb/1024,2) free_gb
FROM
v$asm_diskgroup
ORDER BY
name
)
select 
sum(total_gb) as total_space_in_gb,
sum(used_gb) as used_space_in_gb,
sum(free_gb) as free_space_in_gb
from tab1
where group_name like '%&entername%'
; 


set lines 400
set pages 999
col GROUP_NAME for a35
SELECT
name group_name
, round(total_mb/1024,2) total_gb
, round((total_mb - free_mb)/1024,2) used_gb
,round(free_mb/1024,2) free_gb
, ROUND((1- (free_mb / total_mb))*100, 2) pct_used
FROM
v$asm_diskgroup
WHERE NAME='&EnterDgName'
ORDER BY
name
; 

--SELECT QUERY TO DISMOUNT DISKGROUPS

select 'alter diskgroup '||name||' dismount;' from v$asm_diskgroup where name like '%FNRP2%' and state='MOUNTED';

--SELECT QUERY TO MOUNT DISKGROUPS

select 'alter diskgroup '||name||' mount;' from v$asm_diskgroup where name like '%FNTR2PRD%';