rem ----------------------------------------------------------------------
rem Обновление метаданных документа из его переменных
rem ----------------------------------------------------------------------
sub updateDocMetas()
	dim document as object

	document = ThisComponent

	document.DocumentProperties.Author = Common.getDocVariableValue( "ПодготовилПредставлениеВДокументахИП" )
	document.DocumentProperties.ModifiedBy = Common.getDocVariableValue( "ПодготовилПредставлениеВДокументахИП" )
	document.DocumentProperties.Subject = Common.getDocVariableValue( "Тема" )
	document.DocumentProperties.Title = Common.getDocVariableValue( "Название" )
	document.DocumentProperties.Description = Common.getDocVariableValue( "Описание" )
end sub
