' Creazione dell'oggetto Excel
Set objExcel = CreateObject("Excel.Application")

' Apri il file Excel
Set objWorkbook = objExcel.Workbooks.Open("Table_To_Analyze.xlsx")

' Seleziona il primo foglio
Set objWorksheet = objWorkbook.Sheets(1)

' Imposta il percorso del file CSV di output
csvFilePath = "Guide_File.csv"

' Apri il file CSV per la scrittura
Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objCSVFile = objFSO.CreateTextFile(csvFilePath, True)

' Cicla attraverso le righe e colonne del foglio
rowCount = objWorksheet.UsedRange.Rows.Count
colCount = objWorksheet.UsedRange.Columns.Count

For i = 1 To rowCount
    line = ""
    For j = 1 To colCount
        cellValue = objWorksheet.Cells(i, j).Value
        ' Aggiungi il valore della cella alla riga
        line = line & cellValue
        ' Aggiungi il separatore solo se non è l'ultima colonna
        If j < colCount Then
            line = line & ";"
        End If
    Next
    ' Scrivi la riga nel file CSV
    objCSVFile.WriteLine line
Next

' Chiudi il file CSV
objCSVFile.Close

' Chiudi il file Excel
objWorkbook.Close False
objExcel.Quit

' Pulisci gli oggetti
Set objCSVFile = Nothing
Set objFSO = Nothing
Set objWorksheet = Nothing
Set objWorkbook = Nothing
Set objExcel = Nothing

WScript.Echo "File CSV creato con successo: " & csvFilePath