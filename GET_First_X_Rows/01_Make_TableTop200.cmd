@Echo off
set /p USER=Enter user: 
call:InputPassword "Enter Password" PWD

set FILE_DATABASE_LIST=input\Guide_File_03.csv
set OutPutFileLog=OutPut\TmpOutputLog.log
@echo %date% %time% START program %0 >> %OutPutFileLog%

if not exist %FILE_DATABASE_LIST% (
	set RC=1
	set RCMSG=File Guida %FILE_DATABASE_LIST% mancante 
	goto :eof
)


	rem tmpl TipoRiga ; TipoDatabase ; Applicazione         ; Connessione            ;Database ; Owner ; Tabella
	rem          i            j           k                        l                      m        n        o
	rem exam ##ROWS## ; SQL          ; MY_SHORT_DESCRIPTION ; 1.2.3.4\MYINSTANCE,1453 ; MY_DB_2; [dbo] ; [MY_TABLE_NAME]
	rem          i       j                   k                       l                    m        n            o
	rem exam ##ROWS## ; ORA          ; MY_SHORT_DESCRIPTION ; MY_DB:PORT/MY_DB ; MY_DB_2 ; dbo  ; MY_TABLE_NAME

FOR /F "eol=! tokens=1-7 delims=; " %%i in (%FILE_DATABASE_LIST%) do (
	if /I "%%i" == "##ROWS##" (			
		if /I "%%j" == "sql" (
			del output\In_Sql_Server_%%k_%%m_%%n_%%o.csv
			@echo %date% %time% In_Sql_Server "%%j" "%%k" "%%l" "%%m" "%%n" "%%o"
			echo %date% %time% In_Sql_Server "%%j" "%%k" "%%l" "%%m" "%%n" "%%o" >> %OutPutFileLog%
			@echo Select top 200 * from %%m.%%n.%%o > Script\In_Sql_Server_%%m_%%n_%%o.sql
			sqlcmd -b -S %%l -U%USER% -P%PWD% -d master -i Script\In_Sql_Server_%%m_%%n_%%o.sql -W -I -s ";" > output\In_Sql_Server_%%k_%%m_%%n_%%o.csv
		)
	)
)

FOR /F "eol=! tokens=1-7 delims=; " %%i in (%FILE_DATABASE_LIST%) do (
	if /I "%%i" == "##ROWS##" (			
		if /I "%%j" == "ora" (
			del Output\In_Oracle_%%k_%%m_%%n_%%o.csv
			@echo %date% %time% In_Oracle "%%j" "%%k" "%%l" "%%m" "%%n" "%%o" 
			echo %date% %time% In_Oracle "%%j" "%%k" "%%l" "%%m" "%%n" "%%o" >> %OutPutFileLog%
			Type Model\oracle_csv_output.sql > Script\In_Oracle_%%m_%%n_%%o.sql
 			@echo Select * from %%n.%%o WHERE ROWNUM ^<= 200;>> Script\In_Oracle_%%m_%%n_%%o.sql
			@echo SPOOL OFF >> Script\In_Oracle_%%m_%%n_%%o.sql
			@echo EXIT; >> Script\In_Oracle_%%m_%%n_%%o.sql
			sqlplus -L %USER%/o%PWD%@%%l @Script\In_Oracle_%%m_%%n_%%o.sql Output\In_Oracle_%%k_%%m_%%n_%%o
		)
	)
)
@echo %date% %time% END  program %0 >> %OutPutFileLog%

::***********************************
:InputPassword
set "psCommand=powershell -Command "$pword = read-host '%1' -AsSecureString ; ^
    $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
      [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
        for /f "usebackq delims=" %%p in (`%psCommand%`) do set %2=%%p
)
goto :eof     
::***********************************
