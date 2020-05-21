<?xml version="1.0" encoding="UTF-8"?><xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:f="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"
	xmlns:p="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
	xmlns:o="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/optimizer"

	xmlns:t="http://github.com/test-st-petersburg/DocTemplates/tools/xslt"

	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
	xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"

	default-validation="strip"
	input-type-annotations="strip"

	default-mode="t:optimize"
>

	<xsl:variable name="t:inline-document-files-before-pack" as="xs:boolean" static="yes" select="false()" visibility="private"/>

	<xsl:mode
		name="t:after-unpack"
		on-no-match="fail" warning-on-no-match="yes"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<xsl:mode
		name="t:before-pack"
		on-no-match="fail" warning-on-no-match="yes"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<xsl:mode
		name="t:optimize"
		on-no-match="fail" warning-on-no-match="yes"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<xsl:mode
		name="t:update-document-meta"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-merger.xslt" package-version="1.5">
		<xsl:accept component="mode" names="p:merge-document-files" visibility="private"/>
	</xsl:use-package>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-writer.xslt" package-version="1.5">
		<xsl:accept component="mode" names="p:create-outline-document-files" visibility="private"/>
		<xsl:accept component="mode" names="p:create-inline-document-files" visibility="private"/>
	</xsl:use-package>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/optimizer/OOOptimizer.xslt" package-version="1.5">
		<xsl:accept component="mode" names="o:optimize" visibility="final"/>
	</xsl:use-package>

	<xsl:template mode="t:after-unpack" match="/">
		<xsl:context-item use="required" as="document-node()"/>
		<!-- <xsl:context-item use="required" as="document-node( schema-element( manifest:manifest ) )"/> -->
		<xsl:variable name="t:complex-document" as="document-node()">
			<xsl:apply-templates select="." mode="p:merge-document-files"/>
		</xsl:variable>
		<xsl:apply-templates select="$t:complex-document" mode="p:create-outline-document-files"/>
	</xsl:template>

	<xsl:template mode="t:before-pack" match="/">
		<xsl:context-item use="required" as="document-node()"/>
		<!-- <xsl:context-item use="required" as="document-node( schema-element( manifest:manifest ) )"/> -->
		<xsl:variable name="t:complex-document" as="document-node()">
			<xsl:apply-templates select="." mode="p:merge-document-files"/>
		</xsl:variable>
		<xsl:variable name="t:updated-complex-document" as="document-node()">
			<xsl:apply-templates select="$t:complex-document" mode="t:update-document-meta"/>
		</xsl:variable>
		<xsl:apply-templates select="$t:updated-complex-document" mode="p:create-inline-document-files" use-when="$t:inline-document-files-before-pack"/>
		<xsl:apply-templates select="$t:updated-complex-document" mode="p:create-outline-document-files" use-when="not( $t:inline-document-files-before-pack )"/>
	</xsl:template>

	<xsl:template mode="t:optimize" match="/">
		<xsl:context-item use="required" as="document-node()"/>
		<!-- <xsl:context-item use="required" as="document-node( schema-element( manifest:manifest ) )"/> -->
		<xsl:variable name="t:complex-document" as="document-node()">
			<xsl:apply-templates select="." mode="p:merge-document-files"/>
		</xsl:variable>
		<xsl:variable name="t:optimized-document" as="document-node()">
			<xsl:apply-templates select="$t:complex-document" mode="o:optimize"/>
		</xsl:variable>
		<xsl:apply-templates select="$t:optimized-document" mode="p:create-outline-document-files"/>
	</xsl:template>

	<xsl:template mode="t:update-document-meta" match="office:document-meta/office:meta/dc:date">
		<xsl:copy>
			<xsl:value-of select="format-dateTime(
				adjust-dateTime-to-timezone( current-dateTime(), xs:dayTimeDuration( 'PT0H' ) ),
				'[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01.000000000]'
			)"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template mode="t:update-document-meta" match="office:document-meta/office:meta/meta:editing-cycles">
		<xsl:copy>
			<xsl:value-of select="xs:int( text() ) + 1"/>
		</xsl:copy>
	</xsl:template>

</xsl:transform>
