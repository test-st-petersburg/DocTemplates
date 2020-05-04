<?xml version="1.0" encoding="UTF-8"?><xsl:transform version="3.0"
	default-mode="f:outline"
	default-validation="preserve"
	input-type-annotations="preserve"
	expand-text="no"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:f="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"
>

	<xsl:use-package name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OO.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:outline" visibility="public"/>
		<xsl:accept component="mode" names="f:inline" visibility="final"/>
	</xsl:use-package>

</xsl:transform>
