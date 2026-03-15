--INACTIVE SESSIONS COUNT
------------------------
select username,count(*) inactive_session_count
from 
gv$session
where
status='INACTIVE'
group by 
username
order by count(*) desc;


select inst_id,username,count(*) inactive_session_count
from 
gv$session
where
status='INACTIVE'
and username='&user'
group by 
inst_id,username;



--INACTIVE SESSION DETAILS
--------------------------
select *
from 
gv$session
where
status='INACTIVE' and 
username='&user'
;


select 
a.*,
b.SQL_TEXT
from gv$session a,
gv$sql b
where
a.status='INACTIVE' 
and a.type!='BACKGROUND'
and a.SQL_ID=b.SQL_ID
;


--all sessions in database
select * from gv$session;

--instance wise active session in database
select inst_id,count(*)  from gv$session where status='ACTIVE' group by inst_id;

--instance wise inactive session in database
select inst_id,count(*)  from gv$session where status='INACTIVE' group by inst_id;

--For entire db
-------------

select inst_id,username,count(*) inactive_session_count from gv$session 
where status='INACTIVE' group by inst_id,username order by count(*) desc,username,inst_id;

--Inactive session count group by username

select inst_id,username,count(*) inactive_session_count from gv$session 
where status='INACTIVE' and inst_id=5 group by inst_id,username order by count(*) desc,username,inst_id;

--Inactive session details

select * from gv$session 
where status='INACTIVE' and inst_id=5 and username='XXCTS_SHN_U';

--Inactive session count group by machine

select inst_id,machine,count(*) inactive_session_count from gv$session 
where status='INACTIVE' and inst_id=5 and username='XXCTS_SHN_U'
group by inst_id,machine order by count(*) desc;