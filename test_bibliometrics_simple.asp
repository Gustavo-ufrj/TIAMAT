<!--#include file="system.asp"-->
<!--#include file="TIAMAT_OUTPUT_INTEGRATION.asp"-->
<%
Response.Write "<h2>Teste Bibliometrics Output (Simulado)</h2>"

' Simular dados como se fossem reais do banco
Dim outputData
Set outputJSON = New aspJSON
With outputJSON.data
    .add "analysisType", "Bibliometric Analysis"
    .add "stepID", 1
    .add "processedAt", FormatDateTime(Now(), 2)
    .add "methodology", "Systematic Literature Review"
    
    ' Simular métricas
    .add "metrics", outputJSON.Collection()
    With .item("metrics")
        .add "totalReferences", 25
        .add "uniqueAuthors", 15
        .add "timeSpan", "2020-2024"
        .add "topics", 8
    End With
    
    ' Simular top autores
    .add "topAuthors", outputJSON.Collection()
    Dim i
    For i = 0 To 4
        .item("topAuthors").add i, outputJSON.Collection()
        With .item("topAuthors").item(i)
            .add "name", "Autor " & (i+1)
            .add "publications", (10-i)
        End With
    Next
    
    ' Simular distribuição por ano
    .add "yearlyDistribution", outputJSON.Collection()
    For i = 0 To 4
        .item("yearlyDistribution").add i, outputJSON.Collection()
        With .item("yearlyDistribution").item(i)
            .add "year", (2020+i)
            .add "count", (5+i*2)
        End With
    Next
End With

outputData = outputJSON.JSONoutput()

' Testar captura
Response.Write "<h3>Testando SaveFTAMethodOutput...</h3>"
Dim success
success = SaveFTAMethodOutput(1, outputData, "bibliometric_analysis", 15)

If success Then
    Response.Write "<div style='color:green; padding:10px; border:1px solid green;'>✓ Output capturado com SUCESSO!</div>"
Else
    Response.Write "<div style='color:red; padding:10px; border:1px solid red;'>✗ Erro ao capturar output</div>"
End If

' Testar recuperação
Response.Write "<h3>Testando GetFTAMethodInput...</h3>"
Dim retrieved
retrieved = GetFTAMethodInput(1, "")

If retrieved <> "" Then
    Response.Write "<div style='color:green; padding:10px; border:1px solid green;'>✓ Output recuperado com SUCESSO!</div>"
    Response.Write "<h4>Dados Recuperados:</h4>"
    Response.Write "<pre style='background:#f5f5f5; padding:10px; border:1px solid #ddd;'>" & retrieved & "</pre>"
Else
    Response.Write "<div style='color:red; padding:10px; border:1px solid red;'>✗ Nenhum output encontrado</div>"
End If

' Testar estatísticas
Response.Write "<h3>Testando GetOutputStatistics...</h3>"
Dim stats
stats = GetOutputStatistics()
Response.Write "<pre style='background:#f5f5f5; padding:10px; border:1px solid #ddd;'>" & stats & "</pre>"

Response.Write "<h3>✅ Teste Concluído!</h3>"
Response.Write "<p><a href='test_complete_system.asp'>Ver Teste Completo do Sistema</a></p>"
%>