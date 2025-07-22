<%
''
'' aspJSON v1.19
'' A JSON library for VBScript/ASP
''

Class aspJSON
    Public data
    Private p_state
    Private p_char
    Private p_index
    Private p_length
    
    Private Sub Class_Initialize()
        Set data = CreateObject("Scripting.Dictionary")
        data.CompareMode = 1
    End Sub
    
    Private Sub Class_Terminate()
        Set data = Nothing
    End Sub
    
    Private Sub p_parse()
        p_index = 1
        p_length = Len(p_char)
        Call p_white()
        If p_index <= p_length Then Call p_value()
    End Sub
    
    Private Sub p_white()
        Do While p_index <= p_length
            If InStr(" " & Chr(9) & Chr(10) & Chr(13), Mid(p_char, p_index, 1)) Then
                p_index = p_index + 1
            Else
                Exit Do
            End If
        Loop
    End Sub
    
    Private Function p_str(byRef str)
        Dim p_char2, char, code
        str = ""
        If Mid(p_char, p_index, 1) <> """" Then Call p_error("string")
        p_index = p_index + 1
        Do While p_index <= p_length
            p_char2 = Mid(p_char, p_index, 1)
            If p_char2 = """" Then
                p_index = p_index + 1
                p_str = True
                Exit Function
            ElseIf p_char2 = "\" Then
                p_index = p_index + 1
                If p_index > p_length Then Call p_error("string")
                p_char2 = Mid(p_char, p_index, 1)
                Select Case p_char2
                    Case """", "\", "/"
                        str = str & p_char2
                    Case "b"
                        str = str & Chr(8)
                    Case "f"
                        str = str & Chr(12)
                    Case "n"
                        str = str & Chr(10)
                    Case "r"
                        str = str & Chr(13)
                    Case "t"
                        str = str & Chr(9)
                    Case "u"
                        If p_index + 4 > p_length Then Call p_error("string")
                        code = ""
                        For i = 1 To 4
                            p_index = p_index + 1
                            char = Mid(p_char, p_index, 1)
                            If InStr("0123456789abcdefABCDEF", char) Then
                                code = code & char
                            Else
                                Call p_error("string")
                            End If
                        Next
                        str = str & ChrW("&H" & code)
                    Case Else
                        Call p_error("string")
                End Select
            Else
                str = str & p_char2
            End If
            p_index = p_index + 1
        Loop
        Call p_error("string")
    End Function
    
    Private Sub p_number()
        Dim number, minus
        number = ""
        If Mid(p_char, p_index, 1) = "-" Then
            number = number & "-"
            p_index = p_index + 1
        End If
        Do While p_index <= p_length
            If InStr("0123456789", Mid(p_char, p_index, 1)) Then
                number = number & Mid(p_char, p_index, 1)
                p_index = p_index + 1
            Else
                Exit Do
            End If
        Loop
        If Mid(p_char, p_index, 1) = "." Then
            number = number & "."
            p_index = p_index + 1
            Do While p_index <= p_length
                If InStr("0123456789", Mid(p_char, p_index, 1)) Then
                    number = number & Mid(p_char, p_index, 1)
                    p_index = p_index + 1
                Else
                    Exit Do
                End If
            Loop
        End If
        If InStr("eE", Mid(p_char, p_index, 1)) Then
            number = number & Mid(p_char, p_index, 1)
            p_index = p_index + 1
            If InStr("+-", Mid(p_char, p_index, 1)) Then
                number = number & Mid(p_char, p_index, 1)
                p_index = p_index + 1
            End If
            Do While p_index <= p_length
                If InStr("0123456789", Mid(p_char, p_index, 1)) Then
                    number = number & Mid(p_char, p_index, 1)
                    p_index = p_index + 1
                Else
                    Exit Do
                End If
            Loop
        End If
        If number = "" Or number = "-" Then Call p_error("number")
        If IsNumeric(number) Then
            data.item(p_state) = CDbl(number)
        Else
            data.item(p_state) = number
        End If
    End Sub
    
    Private Sub p_word()
        Select Case Mid(p_char, p_index, 4)
            Case "true"
                data.item(p_state) = True
                p_index = p_index + 4
            Case "fals"
                If Mid(p_char, p_index, 5) = "false" Then
                    data.item(p_state) = False
                    p_index = p_index + 5
                Else
                    Call p_error("false")
                End If
            Case "null"
                data.item(p_state) = null
                p_index = p_index + 4
            Case Else
                Call p_error("true, false or null")
        End Select
    End Sub
    
    Private Sub p_array()
        data.item(p_state) = CreateObject("Scripting.Dictionary")
        data.item(p_state).CompareMode = 1
        Dim p_index_array, p_state_array
        p_index_array = 0
        p_state_array = p_state
        p_index = p_index + 1
        Call p_white()
        If Mid(p_char, p_index, 1) = "]" Then
            p_index = p_index + 1
            Exit Sub
        End If
        Do
            p_state = p_state_array & "/" & p_index_array
            Call p_value()
            p_index_array = p_index_array + 1
            Call p_white()
            If Mid(p_char, p_index, 1) = "]" Then
                p_index = p_index + 1
                Exit Do
            ElseIf Mid(p_char, p_index, 1) = "," Then
                p_index = p_index + 1
                Call p_white()
            Else
                Call p_error("] or ,")
            End If
        Loop
        p_state = p_state_array
    End Sub
    
    Private Sub p_object()
        data.item(p_state) = CreateObject("Scripting.Dictionary")
        data.item(p_state).CompareMode = 1
        Dim p_index_object, p_state_object, string
        p_state_object = p_state
        p_index = p_index + 1
        Call p_white()
        If Mid(p_char, p_index, 1) = "}" Then
            p_index = p_index + 1
            Exit Sub
        End If
        Do
            Call p_str(string)
            Call p_white()
            If Mid(p_char, p_index, 1) <> ":" Then Call p_error(":")
            p_index = p_index + 1
            p_state = p_state_object & "/" & string
            Call p_value()
            Call p_white()
            If Mid(p_char, p_index, 1) = "}" Then
                p_index = p_index + 1
                Exit Do
            ElseIf Mid(p_char, p_index, 1) = "," Then
                p_index = p_index + 1
                Call p_white()
            Else
                Call p_error("} or ,")
            End If
        Loop
        p_state = p_state_object
    End Sub
    
    Private Sub p_value()
        Call p_white()
        Select Case Mid(p_char, p_index, 1)
            Case "{"
                Call p_object()
            Case "["
                Call p_array()
            Case """"
                Dim string
                Call p_str(string)
                data.item(p_state) = string
            Case Else
                If InStr("-0123456789", Mid(p_char, p_index, 1)) Then
                    Call p_number()
                Else
                    Call p_word()
                End If
        End Select
        Call p_white()
    End Sub
    
    Private Sub p_error(p_text)
        Err.Raise vbObjectError + 1, "aspJSON", "Expecting " & p_text & " at position " & p_index & " """ & Mid(p_char, p_index, 10) & """"
    End Sub
    
    Public Sub loadJSON(str)
        p_char = str
        p_state = ""
        Call p_parse()
    End Sub
    
    Public Function toJSON(name, item)
        Select Case VarType(item)
            Case 0
                toJSON = "null"
            Case 1
                toJSON = "null"
            Case 7
                toJSON = """" & Replace(Replace(Replace(Replace(Replace(Replace(Replace(CStr(item), "\", "\\"), """", "\"""), Chr(8), "\b"), Chr(12), "\f"), Chr(10), "\n"), Chr(13), "\r"), Chr(9), "\t") & """"
            Case 8
                toJSON = """" & Replace(Replace(Replace(Replace(Replace(Replace(Replace(item, "\", "\\"), """", "\"""), Chr(8), "\b"), Chr(12), "\f"), Chr(10), "\n"), Chr(13), "\r"), Chr(9), "\t") & """"
            Case 9
                Set toJSON = item
            Case 11
                If item Then toJSON = "true" Else toJSON = "false"
            Case 12, 8192, 8204
                Dim c, j, joinArray
                j = 0
                For Each c In item
                    If j > 0 Then joinArray = joinArray & ","
                    joinArray = joinArray & toJSON("", c)
                    j = j + 1
                Next
                toJSON = "[" & joinArray & "]"
            Case 13
                Dim c2, j2, joinObj
                j2 = 0
                For Each c2 In item
                    If j2 > 0 Then joinObj = joinObj & ","
                    joinObj = joinObj & """" & c2 & """:" & toJSON("", item.item(c2))
                    j2 = j2 + 1
                Next
                toJSON = "{" & joinObj & "}"
            Case Else
                toJSON = """" & Replace(Replace(Replace(Replace(Replace(Replace(Replace(CStr(item), "\", "\\"), """", "\"""), Chr(8), "\b"), Chr(12), "\f"), Chr(10), "\n"), Chr(13), "\r"), Chr(9), "\t") & """"
        End Select
    End Function
    
    Public Function JSONoutput()
        If IsObject(data.item("")) Then
            JSONoutput = toJSON("", data.item(""))
        Else
            JSONoutput = toJSON("", data)
        End If
    End Function
    
    Public Function Collection()
        Set Collection = CreateObject("Scripting.Dictionary")
        Collection.CompareMode = 1
    End Function
    
End Class
%>