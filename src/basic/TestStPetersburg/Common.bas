rem ----------------------------------------------------------------------
rem Установка значение переменных документа
rem ----------------------------------------------------------------------
sub setDocVariableValue(ByVal name as string, ByVal value)
	dim document as object
	dim textField as object
	dim fieldId as string

	document = ThisComponent

	fieldId = "com.sun.star.text.fieldmaster.SetExpression" + "." + name
	if document.TextFieldMasters.hasByName(fieldId) then
		for each textField in document.TextFieldMasters.getByName(fieldId).dependentTextFields
			textField.Content = value
		next
	end if

	document.getTextFields().refresh()
end sub

rem ----------------------------------------------------------------------
rem Чтение значения переменных документа
rem ----------------------------------------------------------------------
function getDocVariableValue(ByVal name as string)
	dim document as object
	dim textField as object
	dim fieldId as string

	document = ThisComponent

	fieldId = "com.sun.star.text.fieldmaster.SetExpression" + "." + name
	if document.TextFieldMasters.hasByName(fieldId) then
		getDocVariableValue = document.TextFieldMasters.getByName(fieldId).dependentTextFields(0).Content
	end if
end function

rem ----------------------------------------------------------------------
rem Обновляем поля
rem ----------------------------------------------------------------------
sub updateAllFields()
	dim document as object

	document = ThisComponent

	document.getTextFields().refresh()
end sub
