rem ----------------------------------------------------------------------
rem Изменение межсточного интервала для основного текста
rem ----------------------------------------------------------------------
sub setDocTextLineSpacing(ByVal value as integer) ' в процентах
	dim document as object
	document = ThisComponent

	dim newParaLineSpacingSettings as new com.sun.star.style.LineSpacing
	newParaLineSpacingSettings.Mode = com.sun.star.style.LineSpacingMode.PROP
	newParaLineSpacingSettings.Height = value
	document.StyleFamilies.getByName("ParagraphStyles").getByName("Text body").ParaLineSpacing = newParaLineSpacingSettings
end sub

sub setDocTextLineSpacing150
	setDocTextLineSpacing(150)
end sub

sub setDocTextLineSpacing115
	setDocTextLineSpacing(115)
end sub

sub setDocTextLineSpacing100
	setDocTextLineSpacing(100)
end sub
