<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOTexts"
	name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OOTexts.xslt"
	package-version="1.5.0"
	input-type-annotations="preserve"
	declared-modes="yes"
	default-validation="preserve"
	expand-text="no"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:f="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"

	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
>

	<xsl:use-package name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/main.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:outline" visibility="public"/>
		<xsl:accept component="mode" names="f:inline" visibility="final"/>
		<xsl:override>

			<!-- правила для элементов, содержимое которых нельзя "форматировать" -->

			<xsl:template mode="f:outline" match="
				text:p | text:h | text:span
				| text:table-of-content-entry-template | text:index-title-template
			">
				<xsl:apply-templates select="." mode="f:inline"/>
			</xsl:template>

		</xsl:override>
	</xsl:use-package>

</xsl:package>
