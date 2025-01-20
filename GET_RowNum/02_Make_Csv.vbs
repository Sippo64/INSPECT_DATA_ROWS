Set objFSO = CreateObject("Scripting.FileSystemObject")
Set WshShell = CreateObject("WScript.Shell")


'operazioni con i file
Const ForReading = 1 'Opens a file for reading only
Const ForWriting = 2 'Opens a file for writing. If the file already exists, the contents are overwritten.
Const ForAppending = 8 'Opens a file and starts writing at the end (appends). Contents are not overwritten.
Const VBSEPAR = ";"

strCurDir       = WshShell.CurrentDirectory & "\OutPut"
Textfile_CSV    = objFSO.BuildPath(strCurDir , "Talent_Rows_For_Table.csv")

' main --------------
ElaboraDirectory strCurDir
X = MsgBox ("Done !" ,64, "The Best Programmers <GCP>") 
WshShell.Run Textfile_CSV
'---------------


Function ElaboraDirectory(strCurDir)
    Set objFolder = objFSO.GetFolder(strCurDir )
    Set objFiles = objFolder.Files
    Set file_CSV = objFSO.OpenTextFile(Textfile_CSV,  ForWriting, True)
    
    file_CSV.WriteLine "TipoRiga" & VBSEPAR & "TipoDatabase" & VBSEPAR & "Applicazione" & VBSEPAR & "Connessione" & VBSEPAR & "Database" & VBSEPAR & "Owner" & VBSEPAR & "Tabella"  & VBSEPAR & "NumRows"
     
    For Each strfile In objFiles
        If InStr(UCase(strfile.Name), UCase(".log")) > 0 Then
        	ElaboraContenutoFile strCurDir, strfile.Name, file_CSV
        End If
     Next 
End Function


Function ElaboraContenutoFile(strCurDir, strFilename, file_CSV)

    Set MyFile   = objFSO.OpenTextFile(objFSO.BuildPath(strCurDir,strFilename), ForReading)
    
    Do While MyFile.AtEndOfStream <> True
    	TextLine = MyFile.ReadLine
        UTextLine = UCase(TextLine)

        If InStr(UTextLine, "IN_ORACLE") > 0 Or InStr(UTextLine, "IN_SQL_SERVER") > 0 Then	
        	'In_Sql_Server "sql" "Short_Description" "Str_Connection" "DB_Name" "Owner_name" "Table_Name"
        	'In_Oracle     "ora" "Short_Description" "Str_Connection" "DB_Name" "Owner_name" "Table_Name"
        	DatiHeader = Split(UTextLine," ")
		End If
		
		ControlRow = Mid(UTextLine,1,4)

        If ControlRow = "##RO" Then	
        	file_CSV.WriteLine UTextLine
		End If
        If ControlRow = "##ER" Then	
        	file_CSV.WriteLine UTextLine
		End If
				
        If ControlRow = "ORA-" Then	
        	file_CSV.WriteLine "##ERR##" & VBSEPAR & DatiHeader(1) & VBSEPAR & DatiHeader(2) & VBSEPAR & DatiHeader(3) & VBSEPAR & DatiHeader(4) & VBSEPAR & DatiHeader(5) & VBSEPAR & DatiHeader(6) & VBSEPAR & UTextLine
		End If

        If ControlRow = "HRES" or ControlRow = "MSG "  Then	
	    	UTextLine2 = UCase(MyFile.ReadLine)
        	file_CSV.WriteLine "##ERR##" & VBSEPAR & DatiHeader(1) & VBSEPAR & DatiHeader(2) & VBSEPAR & DatiHeader(3) & VBSEPAR & DatiHeader(4) & VBSEPAR & DatiHeader(5) & VBSEPAR & DatiHeader(6) & VBSEPAR & UTextLine & " " & UTextLine2
		End If	        
    Loop
    
    MyFile.Close
End Function