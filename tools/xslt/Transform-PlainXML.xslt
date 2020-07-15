<?xml version="1.0" encoding="UTF-8"?><xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:ood="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"

	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
	xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"

	default-validation="strip"
	input-type-annotations="strip"
>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-document.xslt" package-version="2.3">
		<xsl:accept component="template" names="ood:prepare-after-unpacking" visibility="final"/>
		<xsl:accept component="template" names="ood:optimize" visibility="final"/>
		<xsl:accept component="template" names="ood:preprocess" visibility="final"/>
		<xsl:accept component="template" names="ood:prepare-for-packing" visibility="final"/>
	</xsl:use-package>

</xsl:transform>
