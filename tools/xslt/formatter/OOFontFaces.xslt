<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOFontFaces"
	name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OOFontFaces.xslt"
	package-version="1.5.0"
	input-type-annotations="preserve"
	declared-modes="yes"
	default-validation="preserve"
	expand-text="no"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:f="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"

	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
	xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
>

	<xsl:use-package name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/main.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:outline-child" visibility="public"/>
		<xsl:accept component="mode" names="f:outline-self" visibility="final"/>
		<xsl:override>

			<xsl:template mode="f:outline-child" match="office:font-face-decls">
				<xsl:apply-templates select="style:font-face" mode="f:outline-self">
					<xsl:sort select="@style:name" data-type="text" order="ascending" case-order="upper-first" />
				</xsl:apply-templates>
			</xsl:template>

		</xsl:override>
	</xsl:use-package>

</xsl:package>
