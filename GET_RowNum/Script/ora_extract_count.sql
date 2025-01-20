set echo OFF
SET SERVEROUTPUT ON
SET SQLPROMPT '&_CONNECT_IDENTIFIER > ' ;
set wrap off ;
set trimspool on
set trimout on
set lines 2000;
SET COLSEP ";" ;

declare
   o int;
   ot int;
   t int;
   Own varchar2(100) := '' ;
   Tab varchar2(100) := '' ;
   NumRow int;
   sep varchar2(1) := ';';

cursor c_Table is
	select OWNER, TABLE_NAME, NUM_ROWS 
	from dba_tables 
	where owner = '&4' and table_name = '&5';

cursor c_TableCrossOwn is
	select OWNER, TABLE_NAME, NUM_ROWS 
	from dba_tables 
	where table_name = '&5';

	
begin
	select count(*) into o from dba_tables where owner = upper('&4');
	dbms_output.Put_line('o=' || o);
	if o > 0 then
		select count(*) into ot from dba_tables  where owner = '&4' and table_name = '&5';
		dbms_output.Put_line('o=' || ot);
		if ot = 1 then
			OPEN c_Table; 
			LOOP 
			FETCH c_Table into Own, Tab, NumRow; 
				EXIT WHEN c_Table%notfound; 
				dbms_output.Put_line('##ROWS##' || sep || 'ORA' || sep || '&1' || sep || '&2' || sep || '&3' || sep  || Own||sep||Tab || sep || NumRow);
			END LOOP; 
			CLOSE c_Table; 
		else
			-- tabella inesistente
			dbms_output.Put_line('##ERR##' || sep || 'ORA' || sep || '&1' || sep || '&2' || sep || '&3' || sep  || '&4'||sep||'&5' || sep || 'Table_Not_ound');
		end if;
	else
		-- vedo se esiste almeno una tabella per tutti gli owner
		select count(*) into t from dba_tables where table_name = '&5';
		dbms_output.Put_line('t=' || t);
		if t > 0 then
			-- elenco la tabella per tutti gli owner
			OPEN c_TableCrossOwn; 
			LOOP 
			FETCH c_TableCrossOwn into Own, Tab, NumRow; 
				EXIT WHEN c_TableCrossOwn%notfound; 
				dbms_output.Put_line('##ROWS##' || sep || 'ORA' || sep || '&1' || sep || '&2' || sep || '&3' || sep || Own||sep||Tab || sep || NumRow);
			END LOOP; 
			CLOSE c_TableCrossOwn;
			-- Segnalo owner inesistente			
			dbms_output.Put_line('##ERR##' || sep || 'ORA' || sep || '&1' || sep || '&2' || sep || '&3' || sep  || '&4'||sep||'&5' || sep || 'Owner.Table_Not_Found' );
		else
			-- owner inesistente
			dbms_output.Put_line('##ERR##' || sep || 'ORA' || sep || '&1' || sep || '&2' || sep || '&3' || sep  || '&4'||sep||'&5' || sep || 'Owner_Not_Found' );
		end if;		
	end if; 
end;

/
exit;
