--:setvar DATABASE_NAME A11	
--:setvar APPLICATION AppTest
--:setvar CONNECTNAME ConnectionName
--:setvar OWNER_NAME a11
--:setvar TABLE_NAME LFA1
use $(DATABASE_NAME)
go
IF EXISTS(SELECT * FROM sys.databases WHERE name = '$(DATABASE_NAME)')
	BEGIN		
		IF EXISTS (SELECT 1 FROM $(DATABASE_NAME).sys.schemas WHERE name='$(OWNER_NAME)') 
			IF EXISTS (SELECT 1 FROM $(DATABASE_NAME).sys.objects WHERE name = ('$(TABLE_NAME)')) 
				BEGIN
					SELECT '##ROWS##' Dati, 'SQL' as TipoDatabase, '$(APPLICATION)' as application, '$(CONNECTNAME)' as connection,  '$(DATABASE_NAME)' as DatabaseName,
							QUOTENAME(SCHEMA_NAME(sOBJ.schema_id)) as OWN, + QUOTENAME(sOBJ.name) AS [TableName], SUM(sPTN.Rows) AS [num_rows]
					FROM	$(DATABASE_NAME).sys.objects AS sOBJ INNER JOIN $(DATABASE_NAME).sys.partitions AS sPTN ON sOBJ.object_id = sPTN.object_id
					WHERE	sOBJ.type ='U' AND sOBJ.is_ms_shipped = 0x0 AND index_id < 2 
							AND SCHEMA_NAME(sOBJ.schema_id) = ('$(OWNER_NAME)')
							AND sOBJ.name = ('$(TABLE_NAME)')
					GROUP BY sOBJ.schema_id, sOBJ.name
				END	
			ELSE
				BEGIN
					-- Tabella inesistente
					select '##ERR##' TipoDati, 'SQL' as TipoDatabase, '$(APPLICATION)' as application, '$(CONNECTNAME)' as connection, '$(DATABASE_NAME)' as DatabaseName,  QUOTENAME('$(OWNER_NAME)') as OWN, QUOTENAME('$(TABLE_NAME)') as TABNAME, 'Table_Not_Found' as num_rows
				END	
		ELSE
			IF EXISTS (SELECT 1 FROM $(DATABASE_NAME).sys.objects WHERE name = ('$(TABLE_NAME)')) 	
				BEGIN
					-- elenco la tabella per tutti gli owner + segnalo oner inesistente
					SELECT '##ROWS##' Dati, 'SQL' as TipoDatabase, '$(APPLICATION)' as application, '$(CONNECTNAME)' as connection,  '$(DATABASE_NAME)' as DatabaseName,
							QUOTENAME(SCHEMA_NAME(sOBJ.schema_id)) as OWN, QUOTENAME(sOBJ.name) AS [TableName], convert(varchar,SUM(sPTN.Rows)) AS [num_rows]
					FROM	$(DATABASE_NAME).sys.objects AS sOBJ INNER JOIN $(DATABASE_NAME).sys.partitions AS sPTN ON sOBJ.object_id = sPTN.object_id
					WHERE	sOBJ.type ='U' AND sOBJ.is_ms_shipped = 0x0 AND index_id < 2 
							--AND SCHEMA_NAME(sOBJ.schema_id) = ('$(OWNER_NAME)')
							AND sOBJ.name = ('$(TABLE_NAME)')
					GROUP BY sOBJ.schema_id, sOBJ.name
					UNION
					select '##ERR##' TipoDati, 'SQL' as TipoDatabase, '$(APPLICATION)' as application, '$(CONNECTNAME)' as connection, '$(DATABASE_NAME)' as DatabaseName,  QUOTENAME('$(OWNER_NAME)') as OWN, QUOTENAME('$(TABLE_NAME)') as TABNAME, 'Owner.Table_Not_Found' as num_rows
				END
			ELSE
				BEGIN
					-- Owner inesistente
					select '##ERR##' TipoDati, 'SQL' as TipoDatabase, '$(APPLICATION)' as application, '$(CONNECTNAME)' as connection, '$(DATABASE_NAME)' as DatabaseName,  QUOTENAME('$(OWNER_NAME)') as OWN, QUOTENAME('$(TABLE_NAME)') as TABNAME, 'Owner_Not_Found' as num_rows
				END
	END	
ELSE
	BEGIN
		-- database inesistente
		select '##ERR##' TipoDati, 'SQL' as TipoDatabase, '$(APPLICATION)' as application, '$(CONNECTNAME)' as connection, '$(DATABASE_NAME)' as DatabaseName,  QUOTENAME('$(OWNER_NAME)') as OWN, QUOTENAME('$(TABLE_NAME)') as TABNAME, 'Database_Not_Found' as num_rows
	END