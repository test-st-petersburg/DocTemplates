<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOMetas"
	name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OOMetas.xslt"
	package-version="1.5.0"
	input-type-annotations="preserve"
	declared-modes="yes"
	default-validation="preserve"
	expand-text="no"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:f="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"

	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
	xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:loext="urn:org:documentfoundation:names:experimental:office:xmlns:loext:1.0"
>

	<xsl:use-package name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/main.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:outline" visibility="public"/>
		<xsl:accept component="mode" names="f:inline" visibility="final"/>
		<xsl:override>

			<xsl:template mode="f:outline" match="
				office:meta/*
				| dc:creator | dc:date
				| loext:sender-initials
			">
				<xsl:apply-templates select="." mode="f:inline"/>
			</xsl:template>

		</xsl:override>
	</xsl:use-package>

</xsl:package>
