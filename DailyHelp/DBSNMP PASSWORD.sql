--CHECK PASSWORD VALIDITY
SQL>
set lines 300
col username for a20
col PROFILE for a20
select username,account_status,profile,expiry_date from dba_users where username='DBSNMP';

USERNAME ACCOUNT_STATUS PROFILE EXPIRY_DA
------------------------------ -------------------------------- ------------------------------ ---------
DBSNMP EXPIRED DEFAULT 27-SEP-21


--CHECK PROFILE
SQL> 
col LIMIT for a30
Select PROFILE,RESOURCE_NAME,LIMIT from dba_profiles where RESOURCE_NAME='PASSWORD_VERIFY_FUNCTION';

PROFILE RESOURCE_NAME LIMIT
------------------------------ -------------------------------- ---------------------------------------------------------------------
DEFAULT PASSWORD_VERIFY_FUNCTION VERIFY_FUNCTION
ORA_STIG_PROFILE PASSWORD_VERIFY_FUNCTION ORA12C_STIG_VERIFY_FUNCTION
SOX_PROFILE PASSWORD_VERIFY_FUNCTION SOX_PASSWORD_VERIFY_FUNCTION

--CHANGE PROFILE TO DEFAULT
SQL> alter profile DEFAULT limit PASSWORD_VERIFY_FUNCTION null;

Profile altered.


--CHANGE PASSWORD
SQL> alter user DBSNMP identified by dboem10g;

User altered.

--REVERT BACK THE PROFILE
SQL> alter profile DEFAULT limit PASSWORD_VERIFY_FUNCTION VERIFY_FUNCTION;    

Profile altered.

--CHECK PASSWORD VALIDITY
SQL> select username,account_status,profile,expiry_date from dba_users where username='DBSNMP';

USERNAME ACCOUNT_STATUS PROFILE EXPIRY_DA
------------------------------ -------------------------------- ------------------------------ ---------
DBSNMP OPEN DEFAULT 26-MAR-22