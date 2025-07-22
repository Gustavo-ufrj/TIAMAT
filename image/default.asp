<%@ Language="VBScript" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title></title>
        <style type="text/css">
            img {border:5px solid #FFFFFF}
            body {font-family:Verdana;font-size:10pt;color:#FFFFFF;background-color:#333333}
        </style>        
    </head>
    <body>
        <p>This Classic ASP script uses a .NET Image resizer. Images are resized on the fly by the showThumb.aspx file.</p>
        <%
        for i=100 to 200 step 50
        %>
        <div style="margin:20px;float:left"><img src="showthumb.aspx?maxsize=<%=i%>&amp;img=sample.jpg" /><br/>Max <%=i%>px</div>
        <%
        next
        %>
        <p>Finally, you can crop images to squares (FSR=1):</p>
        <%
        for i=100 to 200 step 50
        %>
        <div style="margin:20px;float:left"><img src="showthumb.aspx?fsr=1&amp;maxsize=<%=i%>&amp;img=sample.jpg" /><br/>Max <%=i%>px</div>
        <%
        next
        %>
    </body>
</html>
