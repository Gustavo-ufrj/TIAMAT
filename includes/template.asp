<%
Class Page
	private page_title 
	public CSSList()
	public JSList()
	public MetaList() 
	private shortcutIcon 
	
	' Função auxiliar para gerenciar arrays
	private Sub addArray(Array, value)
		on error resume next
		ub_array = -1
		ub_array = UBound(Array) 
		ReDim Preserve Array(ub_array + 1)
		Array(UBound(Array)) = value
	End Sub

	Sub addCSS(css)
		call addArray(CSSList, css)
	End Sub

	Sub addJS(js)
		call addArray(JSList, js)
	End Sub
	
	Sub addMeta(meta)
		call addArray(MetaList, meta)
	End Sub
	
	Public Property Let Title(Byval p_str)
		page_title = p_str
	End Property
	
	Public Property Get Title()
		Title = page_title
	End Property

	Public Property Let Icon(Byval p_str)
		shortcutIcon = p_str
	End Property
	
	Public Property Get Icon()
		Icon = shortcutIcon
	End Property

End class


Class HTMLRender 
	
	private current_page
	
	Public Property Let Page(Byref p_obj)
		Set current_page = p_obj
	End Property

	Public Property Get Page()
		Set Page = current_page
	End Property

	
	Sub renderTitle()

     	renderToBody()
		
		openClassTag "div", "container-fluid min-vh-100 d-flex flex-column"
		openClassTag "div", "row"
		openClassTag "nav", "navbar navbar-expand-md navbar-dark bg-dark"
		openClassTag "div", "container-fluid"
		openLink "/", "navbar-brand"
		printImageWithStyle "/img/theme/TiamatLogo.png", "d-inline-block align-middle", "height:40px;width:auto;"
		openClassTag "b", "align-middle fs-4 p-2"
		printText "TIAMAT"
		closeTag "b"
		closeTag "a"
		openClassTag "div", "text-right"
		openFreeTag "button", "class=""navbar-toggler"" type=""button"" data-bs-toggle=""collapse"" data-bs-target=""#navbarNavDropdown"" aria-controls=""navbarNavDropdown"" aria-expanded=""false"" aria-label=""Toggle navigation"""
		openClassTag "span", "navbar-toggler-icon"
		closeTag "span"
		closeTag "button"
		openFreeTag "div", "class=""collapse navbar-collapse navbar-dark bg-dark"" id=""navbarNavDropdown"" "
		openClassTag "ul", "navbar-nav"
		openClassTag "li", "nav-item"
		openLink "/about.asp", "nav-link h-100"
		printText "About"
		closeTag "a"
		closeTag "li"

		if Session("email") <> "" then
			
				if Session("admin") then
		openClassTag "li", "nav-item"
		openLink "/administration.asp", "nav-link h-100"
		printText "Users"
		closeTag "a"
		closeTag "li"
				end if 
				
		openClassTag "li", "nav-item"
		openLink "/workplace.asp", "nav-link h-100"
		printText "My Workplace"
		closeTag "a"
		closeTag "li"

		openClassTag "li", "nav-item dropdown"
		openFreeTag "a", " class=""nav-link dropdown-toggle"" href=""#"" id=""navbarDropdownMenuLink"" role=""button"" data-bs-toggle=""dropdown"" aria-expanded=""false"" "
        printImageWithStyle Session("photo"), "rounded-circle align-middle", "height:24px;width:auto;"       
		openClassTag "b", "align-middle"
		printText "&nbsp;" + Session("name")  
		closeTag "b"
		closeTag "a"
		openFreeTag "ul", " class=""dropdown-menu"" aria-labelledby=""navbarDropdownMenuLink"" "
		openTag "li"
		openLink "/profile.asp", "dropdown-item"
		printText "Edit Profile"
		closeTag "a"
		closeTag "li"
		openTag "li"
		openLink "/logout.asp", "dropdown-item"
		printText "Logout"
		closeTag "a"
		closeTag "li"
		closeTag "ul"
		closeTag "li"
		
		else 
		
		openClassTag "li", "nav-item"
		openLink "/signin.asp", "nav-link h-100"
		printText "Sign In"
		closeTag "a"
		closeTag "li"
		
		end if
		closeTag "ul"	
		closeTag "div"
		closeTag "div"
		closeTag "div"
		closeTag "nav"
		closeTag "div"
		openClassTag "div", "row d-flex flex-grow-1"
	
	
	End Sub

	
	Sub renderFooter()

	
		closeTag "div" 
	'	openClassTag "div", "row shrink-grow-1"
	'	closeTag "div" 
		closeTag "div" 
		
		
		renderFromBody()

		
	end sub
	
	
	
	
	Sub renderToBody()
		openTag("html")
		openTag("head")
		
		for each meta in current_page.MetaList
			printMeta(meta)
		Next
		
		openTag("title")
		Response.Write current_page.Title
		closeTag("title")

		printIcon(current_page.Icon)

		for each CSS in current_page.CSSList
			printCSS(CSS)
		Next


		for each JS in current_page.JSList
			printJS(JS)
		Next

		closeTag("head")

		openTag("body")
		
    end sub
	
	Sub renderFromBody()

		closeTag("body")
		closeTag("html")

	end sub
	
	Sub openTag(tag)
		Response.Write "<"+tag+">"
	end Sub

	Sub closeTag(tag)
		Response.Write "</"+tag+">"
	end Sub
		
	Sub printMeta(meta) 
		Response.Write "<meta "+meta+">"
	End Sub

	Sub printIcon(icon) 
		Response.Write "<link rel='shortcut icon' href='"+icon+"'>"
	End Sub

	Sub printCSS(file)
		Response.Write "<link rel='stylesheet' href='"+file+"' type='text/css'>"
	End Sub

	Sub printJS(file)
		Response.Write "<script src='"+file+"'  type='text/javascript'></script>"
	End Sub

	Sub openClassTag(tag, HTMLclass)
		Response.Write "<"+tag+" class='"+HTMLclass+"'>"
	end Sub
	
	Sub openFreeTag(tag, extras)
		Response.Write "<"+tag+" "+extras+">"
	end Sub
	
	Sub printImage(src, HTMLclass)
		Response.Write "<img src='"+src+"' class='"+HTMLclass+"' />"
	end Sub
	
	Sub printImageWithStyle(src, HTMLclass, Style)
		Response.Write "<img src='"+src+"' class='"+HTMLclass+"' style='"+Style+"' />"
	end Sub

	Sub openLink(href, HTMLclass)
		Response.Write "<a href='"+href+"' class='"+HTMLclass+"'>"
	end Sub
	
	Sub closeLink()
		closeTag("a")
	end Sub

	Sub printText(text)
		Response.Write text
	End Sub
	

End Class


%>


