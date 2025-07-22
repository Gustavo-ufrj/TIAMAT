<%@ OutputCache Duration="600" VaryByParam="*" %>
<%@ Page Debug="true" %>
<%@ Import Namespace="System.Drawing" %>
<%@ Import Namespace="System.Drawing.Imaging" %>
<%@ Import Namespace="System.IO" %>
<script runat="server">
	
	
    Private Function CropImage(ByVal OriginalImage As Bitmap, ByVal TopLeft As Point, ByVal BottomRight As Point) As Bitmap
        Dim btmCropped As New Bitmap((BottomRight.Y - TopLeft.Y), (BottomRight.X - TopLeft.X))
        Dim grpOriginal As Graphics = Graphics.FromImage(btmCropped)
  
        grpOriginal.DrawImage(OriginalImage, New Rectangle(0, 0, btmCropped.Width, btmCropped.Height), _
            TopLeft.X, TopLeft.Y, btmCropped.Width, btmCropped.Height, GraphicsUnit.Pixel)
        grpOriginal.Dispose()
  
        Return btmCropped
    End Function

    Function ThumbnailCallback() As Boolean
        
        Return False
    
    End Function
	
	
    Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs)
        
        On Error Resume Next		
             
        'retrieve relative path to image
        Dim imageUrl As String = HttpUtility.UrlDecode(Request.QueryString("img"))	
		dim doresize As Boolean
		dim isPNG As Boolean
		Dim imageFormat as Drawing.Imaging.ImageFormat
		
		isPNG=false
		doresize=true
		
		
		
		select case Lcase(Right(imageUrl,len(imageUrl) - instrrev(imageUrl, ".")))
		
		
		case "png" 
			imageFormat = Drawing.Imaging.ImageFormat.Png
		case "jpg"
			imageFormat = Drawing.Imaging.ImageFormat.Jpeg
		case "jpeg"
			imageFormat = Drawing.Imaging.ImageFormat.Jpeg
		case "gif"
			imageFormat = Drawing.Imaging.ImageFormat.Gif
		case else
			response.write ("Format " +Lcase(Right(imageUrl,len(imageUrl) - instrrev(imageUrl, "."))) + " is an unaccepted image format. Use PNG, JPEG or GIF.")
			response.end 
		end select
        
		

		
		Dim pictureResizeSecCode As String = "gfhddghdfghdfgh" 'change this code!
		Dim resizePictureToPx As String = HttpUtility.UrlDecode(Request.QueryString("resizePictureToPx"))
		
		'prepare thumbnail
		Dim fullSizeImg As System.Drawing.Image
'		fullSizeImg = System.Drawing.Image.FromFile(Server.MapPath(imageUrl))

		Using FileStream = New IO.FileStream(Server.MapPath(imageUrl), IO.FileMode.Open)
  	    fullSizeImg = System.Drawing.Image.FromStream(FileStream)
		
		
		If Request.QueryString("getWidthOnly") = "true" Then
			Response.Write(fullSizeImg.Width)
			fullSizeImg.Dispose()
			Response.End()
		End If
		
		If fullSizeImg Is Nothing Then Response.End()            
	
		'??
		Dim dummyCallBack As System.Drawing.Image.GetThumbnailImageAbort
		dummyCallBack = New System.Drawing.Image.GetThumbnailImageAbort(AddressOf ThumbnailCallback)
		
		
'		Dim dummyCallBack As Object
'		dummyCallBack = Nothing
		
		
		
		Dim thumbNailImg As System.Drawing.Image
		Dim newWidth As Integer
		Dim newHeight As Integer
		Dim maxSize As Integer
		If IsNumeric(Request.QueryString("maxSize")) And Request.QueryString("maxSize") <> "" Then
			maxSize = Request.QueryString("maxSize")
		Else
			maxSize = 0
		End If	
		
		'calculate new width/height, if any  
	   
		If fullSizeImg.Width > maxSize Or fullSizeImg.Height > maxSize Then			
		
			'for better quality
			fullSizeImg.RotateFlip(System.Drawing.RotateFlipType.Rotate90FlipX)
			fullSizeImg.RotateFlip(System.Drawing.RotateFlipType.Rotate90FlipX)
		
			If fullSizeImg.Width >= fullSizeImg.Height Then
				newWidth = maxSize
				newHeight = (fullSizeImg.Height / fullSizeImg.Width) * maxSize
			Else
				newWidth = (fullSizeImg.Width / fullSizeImg.Height) * maxSize
				newHeight = maxSize
			End If
		Else
			
			newWidth = fullSizeImg.Width
			newHeight = fullSizeImg.Height
			doresize = False
			
		End If

		dim FSR as string = Request.QueryString("FSR")
		IF FSR IS NOTHING ANDALSO FSR.length = 0 Then
		FSR="0"
		END IF
		
		If FSR = "1" Then
			If newWidth < newHeight Then
				thumbNailImg = fullSizeImg.GetThumbnailImage(newWidth * (newHeight / newWidth), newHeight * (newHeight / newWidth), dummyCallBack, IntPtr.Zero)
				thumbNailImg = CropImage(thumbNailImg, New Point(0, (newHeight - newWidth) / 2), New Point(newHeight, newHeight + (newHeight - newWidth) / 2))
			Else
				thumbNailImg = fullSizeImg.GetThumbnailImage(newWidth * (newWidth / newHeight), newHeight * (newWidth / newHeight), dummyCallBack, IntPtr.Zero)
				thumbNailImg = CropImage(thumbNailImg, New Point((newWidth - newHeight) / 2, 0), New Point(newWidth + ((newWidth - newHeight) / 2), newWidth))
		   End If				
		Else
			If doresize=True Then
				thumbNailImg = fullSizeImg.GetThumbnailImage(newWidth, newHeight, dummyCallBack, IntPtr.Zero)
			else				
				thumbNailImg = fullSizeImg					
			End If
		End If

		thumbNailImg.Save(Server.MapPath(imageUrl)+".temp", imageFormat)
		
		'Clean up / Dispose...
		thumbNailImg.Dispose()
	
		'Clean up / Dispose...
		fullSizeImg.Dispose()

		 
		 
	    End Using

		IO.File.Delete(Server.MapPath(imageUrl))
                    
					
					
		fullSizeImg = System.Drawing.Image.FromFile(Server.MapPath(imageUrl)+".temp")
		fullSizeImg.Save(Server.MapPath(imageUrl), imageFormat)
			
			
		'Clean up / Dispose...
		fullSizeImg.Dispose()
		
		IO.File.Delete(Server.MapPath(imageUrl)+".temp")
		

		Dim redirectTo
		
		if Request.QueryString("url") <> "" then
			redirectTo = Request.QueryString("url")
		else 
			redirectTo = "/"
		end if

  	    Response.Write (" ")

		if Request.QueryString("parent") = "true" then
			Response.Write ("<script>" & "top.location.href='" & redirectTo & "';" & "<" & Chr(47) & "script>")
		else
			Response.Redirect (redirectTo)
		end if
		
            'On Error GoTo 0
    End Sub

    
	
</script>

