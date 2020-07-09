<?xml version="1.0" encoding="UTF-8"?><xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:t="http://github.com/test-st-petersburg/DocTemplates/tools/xslt"
	xmlns:p="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-macrolib.xslt" package-version="2.3">
		<xsl:accept component="template" names="p:build-macro-library" visibility="final"/>
	</xsl:use-package>

</xsl:transform>
