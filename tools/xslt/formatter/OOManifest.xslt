<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOManifest"
	name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OOManifest.xslt"
	package-version="1.5.0"
	input-type-annotations="preserve"
	declared-modes="yes"
	default-validation="preserve"
	expand-text="no"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:f="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"

	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
>

	<xsl:use-package name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/main.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:outline-child" visibility="public"/>
		<xsl:accept component="mode" names="f:outline-self" visibility="final"/>
		<xsl:override>

			<xsl:template mode="f:outline-child" match="/manifest:manifest">
				<xsl:apply-templates select="manifest:file-entry" mode="f:outline-self">
					<xsl:sort select="@manifest:full-path" data-type="text" order="ascending" case-order="upper-first" />
				</xsl:apply-templates>
			</xsl:template>

		</xsl:override>
	</xsl:use-package>

</xsl:package>
