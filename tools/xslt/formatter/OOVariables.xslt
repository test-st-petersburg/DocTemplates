<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOVariables"
	name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OOVariables.xslt"
	package-version="1.5.0"
	input-type-annotations="preserve"
	default-validation="preserve"
	expand-text="no"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:f="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"

	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
>

	<xsl:use-package name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/main.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:outline" visibility="public"/>
		<xsl:accept component="mode" names="f:outline-self" visibility="final"/>
		<xsl:accept component="mode" names="f:inline" visibility="final"/>
		<xsl:override>

			<xsl:template mode="f:outline" match="
				text:variable-set | text:variable-get
			">
				<xsl:apply-templates select="." mode="f:inline"/>
			</xsl:template>

			<xsl:template mode="f:outline-child" match="text:variable-decls">
				<xsl:apply-templates select="text:variable-decl" mode="f:outline-self">
					<xsl:sort select="@text:name" data-type="text" order="ascending" case-order="upper-first" />
				</xsl:apply-templates>
			</xsl:template>

		</xsl:override>
	</xsl:use-package>

</xsl:package>
