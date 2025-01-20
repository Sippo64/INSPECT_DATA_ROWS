@Echo off
set /p USER=Enter user: 
set /p PWD=Enter password: 

set FILE_DATABASE_LIST=input\Guide_File.csv
set OutPutFileLog=OutPut\TmpOutputLog.log
@echo %date% %time% start program %0 > %OutPutFileLog%

if not exist %FILE_DATABASE_LIST% (
	set RC=1
	set RCMSG=File Guida %FILE_DATABASE_LIST% mancante 
	goto :eof
)

	rem tmpl DB ; type ; Application ; Connection ; Database ; Owner ; Table 
	rem      i     j           k           l            m        n       o
	rem exam DB ; sql ; MY_SHORT_DESCRIPTION ; 123.123.12.23\MYINSTANCE,1453 ; MY_MODEL_2 ; dbo ; MY_TABLE_NAME
	rem      i     j                k                       l                     m          n           o

FOR /F "eol=! tokens=1-7 delims=; " %%i in (%FILE_DATABASE_LIST%) do (
	if "%%i" == "DB" (			
		if "%%j" == "sql" (
			@echo In_Sql_Server "%%j" "%%k" "%%l" "%%m" "%%n" "%%o"
			echo In_Sql_Server "%%j" "%%k" "%%l" "%%m" "%%n" "%%o" >> %OutPutFileLog%
			sqlcmd -b -S %%l -U%USER% -P%PWD% -d master -i Script\sql_extract_count.sql -W -I -s ";" -v APPLICATION="%%k" CONNECTNAME="%%l" DATABASE_NAME="%%m" OWNER_NAME="%%n" TABLE_NAME="%%o" >> %OutPutFileLog%
		)
	)
)

FOR /F "eol=! tokens=1-7 delims=; " %%i in (%FILE_DATABASE_LIST%) do (
	if "%%i" == "DB" (			
		if "%%j" == "ora" (	
			@echo In_Oracle "%%j" "%%k" "%%l" "%%m" "%%n" "%%o" 
			echo In_Oracle "%%j" "%%k" "%%l" "%%m" "%%n" "%%o" >> %OutPutFileLog%
 			sqlplus -L %USER%/o%PWD%@%%l @Script\ora_extract_count.sql "%%k" "%%l" "%%m" "%%n" "%%o" >> %OutPutFileLog%
		)
	)
)

cscript 02_Make_Csv.vbs

:eof


