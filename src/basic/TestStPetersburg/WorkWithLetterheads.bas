rem ----------------------------------------------------------------------
rem Включение / выключение печати элементов фирменного бланка
rem ----------------------------------------------------------------------
sub setLetterheadItemsPrintingAbility(ByVal printLetterheadItems as boolean)
	dim document as object
	dim textFrame as object
	dim frameId as string

	document = ThisComponent

	Common.setDocVariableValue("ПечататьНаБланке", not printLetterheadItems)

	rem перебираем все врезки (фреймы), наименование которые начинается
	rem с Бланк:
	for each textObject in document.TextFrames
		if InStr(textObject.Name, "Бланк:") = 1 then
			textObject.Print = printLetterheadItems
		end if
	next

	rem перебираем всю графику, наименование которой начинается
	rem с Бланк:
	for each textObject in document.GraphicObjects
		if InStr(textObject.Name, "Бланк:") = 1 then
			textObject.Print = printLetterheadItems
		end if
	next
end sub

rem ----------------------------------------------------------------------
rem Подготовка документа к печати на бумаге
rem ----------------------------------------------------------------------
sub prepareForPrintingOnPaper
	setLetterheadItemsPrintingAbility(true)
end sub

rem ----------------------------------------------------------------------
rem Подготовка документа к печати на бланке
rem ----------------------------------------------------------------------
sub prepareForPrintingOnLetterhead
	setLetterheadItemsPrintingAbility(false)
end sub
