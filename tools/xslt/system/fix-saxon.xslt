<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="FixSaxon"
	name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/system/fix-saxon.xslt"
	package-version="2.3.0"
	declared-modes="yes"
	expand-text="no"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:err="http://www.w3.org/2005/xqt-errors"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"

	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:fix="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/system/fix"
>

	<!--
	 	решаем проблему падения doc( ... )/office:document-meta/office:meta/dc:date вместо xsl:source-document падает.
		Проблема в Saxon.
		Нашёл информацию, что явно требуется указание UriResolver для XsltTranslator.
		Но обходное решение, предложенное ниже, работает.
	-->
	<xsl:function name="fix:doc" as="document-node()?" visibility="final">
		<xsl:param name="fix:uri" as="xs:string?" required="yes"/>
		<xsl:if test="exists( $fix:uri )">
			<xsl:source-document href="{ $fix:uri }">
				<xsl:sequence select="/"/>
			</xsl:source-document>
		</xsl:if>
	</xsl:function>

</xsl:package>
