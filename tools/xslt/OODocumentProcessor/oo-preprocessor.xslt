<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOPreprocessor"
	name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-preprocessor.xslt"
	package-version="2.2.0"
	declared-modes="yes"
	expand-text="no"
	input-type-annotations="strip"
	default-validation="strip"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:err="http://www.w3.org/2005/xqt-errors"
	xmlns:saxon="http://saxon.sf.net/"

	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
	xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"

	xmlns:f="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"
	xmlns:p="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
>

	<xsl:variable name="p:update-document-meta" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="p:update-document-date" as="xs:boolean" static="yes" select="$p:update-document-meta" visibility="private"/>
	<xsl:variable name="p:update-document-editing-cycles" as="xs:boolean" static="yes" select="$p:update-document-meta" visibility="private"/>

	<!-- обновление метаданных документа (meta.xml) перед сборкой шаблонов документов и документов -->
	<xsl:mode
		name="p:update-document-meta"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<xsl:template mode="p:update-document-meta" use-when="$p:update-document-date" match="
		office:document-meta/office:meta/dc:date
	">
		<xsl:copy>
			<xsl:value-of select="format-dateTime(
				adjust-dateTime-to-timezone( current-dateTime(), xs:dayTimeDuration( 'PT0H' ) ),
				'[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01.000000000]'
			)"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template mode="p:update-document-meta" use-when="$p:update-document-editing-cycles" match="
		office:document-meta/office:meta/meta:editing-cycles
	">
		<xsl:copy>
			<xsl:value-of select="xs:int( text() ) + 1"/>
		</xsl:copy>
	</xsl:template>

</xsl:package>
