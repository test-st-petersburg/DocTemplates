<?xml version="1.0" encoding="UTF-8"?><xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:f="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"
	xmlns:p="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
	xmlns:o="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/optimizer"
>

	<xsl:global-context-item use="absent"/>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OO.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:outline f:inline" visibility="final"/>
	</xsl:use-package>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/main.xslt" package-version="1.5">
		<xsl:accept component="mode" names="p:process-document-file-document-node" visibility="public"/>
		<xsl:accept component="template" names="p:process" visibility="final"/>
		<xsl:override>

			<xsl:template mode="p:process-document-file-document-node" match="/">
				<xsl:apply-templates mode="f:outline"/>
			</xsl:template>

		</xsl:override>
	</xsl:use-package>

</xsl:transform>
