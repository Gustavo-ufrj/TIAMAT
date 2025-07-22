<% 
Class StringBuffer

   Dim buf

   Private Sub Class_Initialize()
      Set buf = CreateObject("System.IO.StringWriter")
   End Sub

   Private Sub Class_Terminate()
      Set buf = Nothing
   End Sub

   Public Sub Append(ByVal strValue)
      If Not IsNull(strValue) Then
         buf.Write_12 CStr(strValue)
      End If
   End Sub

   Public Sub AppendLine(ByVal strValue)
      buf.Write_12 strValue & vbCRLF
   End Sub

   Public Function ToString()
      ToString = buf.GetStringBuilder().ToString()
   End Function

End Class
%>