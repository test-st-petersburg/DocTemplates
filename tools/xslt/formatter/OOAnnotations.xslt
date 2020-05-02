<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOAnnotations"
	name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OOAnnotations.xslt"
	package-version="1.5.0"
	input-type-annotations="preserve"
	declared-modes="yes"
	default-validation="preserve"
	expand-text="no"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:f="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"

	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
>

	<xsl:use-package name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/main.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:inline" visibility="public"/>
		<xsl:accept component="mode" names="f:outline" visibility="final"/>
		<xsl:override>

			<xsl:template mode="f:inline" match="office:annotation">
				<xsl:apply-templates select="." mode="f:outline"/>
			</xsl:template>

		</xsl:override>
	</xsl:use-package>

</xsl:package>
