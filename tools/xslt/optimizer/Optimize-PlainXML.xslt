<?xml version="1.0" encoding="UTF-8"?><xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:f="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"
	xmlns:p="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
>

	<xsl:global-context-item use="absent"/>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/main.xslt" package-version="1.5">
		<xsl:accept component="template" names="p:optimize" visibility="final"/>
	</xsl:use-package>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OO.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:outline" visibility="final"/>
		<xsl:accept component="mode" names="f:inline" visibility="final"/>
	</xsl:use-package>


</xsl:transform>
