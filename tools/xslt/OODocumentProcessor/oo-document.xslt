<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OODocument"
	name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-document.xslt"
	package-version="2.3.0"
	declared-modes="yes"
	expand-text="no"
	input-type-annotations="strip"
	default-validation="strip"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:err="http://www.w3.org/2005/xqt-errors"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:f="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"
	xmlns:p="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
	xmlns:ood="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
	xmlns:o="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/optimizer"

	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
	xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"

>

	<xsl:import href="oo-defs.xslt"/>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-merger.xslt" package-version="1.5">
		<xsl:accept component="mode" names="p:merge-document-files" visibility="private"/>
	</xsl:use-package>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-writer.xslt" package-version="1.5">
		<xsl:accept component="mode" names="p:create-outline-document-files" visibility="private"/>
		<xsl:accept component="mode" names="p:create-inline-document-files" visibility="private"/>
	</xsl:use-package>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-preprocessor.xslt" package-version="2.2">
		<xsl:accept component="mode" names="p:update-document-meta" visibility="final"/>
		<xsl:accept component="mode" names="p:preprocess-document" visibility="final"/>
	</xsl:use-package>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/optimizer/OOOptimizer.xslt" package-version="1.5">
		<xsl:accept component="mode" names="o:optimize" visibility="final"/>
	</xsl:use-package>

	<!-- обработка XML файлов, полученных непосредственно после распаковки документа либо шаблона -->

	<xsl:mode
		name="ood:preparing-after-unpacking"
		on-no-match="fail" warning-on-no-match="yes"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<xsl:template name="ood:prepare-after-unpacking" visibility="final">
		<xsl:context-item use="absent"/>
		<xsl:param name="ood:source-directory" as="xs:string" required="yes"/>

		<xsl:source-document validation="lax" href="{ $ood:source-directory || $p:manifest-uri }">
			<xsl:apply-templates select="/" mode="ood:preparing-after-unpacking"/>
		</xsl:source-document>
	</xsl:template>

	<xsl:template mode="ood:preparing-after-unpacking" match="/">
		<xsl:context-item use="required" as="document-node( element( manifest:manifest ) )"/>
		<!-- <xsl:context-item use="required" as="document-node( schema-element( manifest:manifest ) )"/> -->
		<xsl:variable name="ood:complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="." mode="p:merge-document-files"/>
		</xsl:variable>
		<xsl:apply-templates select="$ood:complex-document" mode="p:create-outline-document-files"/>
	</xsl:template>

	<xsl:mode
		name="ood:optimizing"
		on-no-match="fail" warning-on-no-match="yes"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<xsl:template name="ood:optimize" visibility="final">
		<xsl:context-item use="absent"/>
		<xsl:param name="ood:source-directory" as="xs:string" required="yes"/>

		<xsl:source-document validation="lax" href="{ $ood:source-directory || $p:manifest-uri }">
			<xsl:apply-templates select="/" mode="ood:optimizing"/>
		</xsl:source-document>
	</xsl:template>

	<xsl:template mode="ood:optimizing" match="/">
		<xsl:context-item use="required" as="document-node( element( manifest:manifest ) )"/>
		<!-- <xsl:context-item use="required" as="document-node( schema-element( manifest:manifest ) )"/> -->
		<xsl:variable name="ood:complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="." mode="p:merge-document-files"/>
		</xsl:variable>
		<xsl:variable name="ood:optimized-document" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="$ood:complex-document" mode="o:optimize"/>
		</xsl:variable>
		<xsl:apply-templates select="$ood:optimized-document" mode="p:create-outline-document-files"/>
	</xsl:template>

	<!-- обработка XML файлов перед сборкой документа либо шаблона -->

	<xsl:mode
		name="ood:preprocessing"
		on-no-match="fail" warning-on-no-match="yes"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<xsl:template name="ood:preprocess" visibility="final">
		<xsl:context-item use="absent"/>
		<xsl:param name="ood:source-directory" as="xs:string" required="yes"/>
		<xsl:param name="ood:version" as="xs:string" required="no" select="''"/>

		<xsl:source-document validation="lax" href="{ $ood:source-directory || $p:manifest-uri }">
			<xsl:apply-templates select="/" mode="ood:preprocessing">
				<xsl:with-param name="ood:version" select="$ood:version"/>
			</xsl:apply-templates>
		</xsl:source-document>
	</xsl:template>

	<xsl:template mode="ood:preprocessing" match="/">
		<xsl:context-item use="required" as="document-node( element( manifest:manifest ) )"/>
		<xsl:param name="ood:version" as="xs:string" required="no" select="''"/>
		<!-- <xsl:context-item use="required" as="document-node( schema-element( manifest:manifest ) )"/> -->
		<xsl:variable name="ood:complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="." mode="p:merge-document-files"/>
		</xsl:variable>
		<xsl:variable name="ood:updated-complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="$ood:complex-document" mode="p:update-document-meta">
				<xsl:with-param name="ood:version" select="$ood:version" as="xs:string" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:variable name="ood:preprocessed-complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="$ood:updated-complex-document" mode="p:preprocess-document"/>
		</xsl:variable>
		<xsl:apply-templates select="$ood:preprocessed-complex-document" mode="p:create-outline-document-files"/>
	</xsl:template>

	<xsl:mode
		name="ood:preparing-for-packing"
		on-no-match="fail" warning-on-no-match="yes"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<xsl:template name="ood:prepare-for-packing" visibility="final">
		<xsl:context-item use="absent"/>
		<xsl:param name="ood:source-directory" as="xs:string" required="yes"/>

		<xsl:source-document validation="lax" href="{ $ood:source-directory || $p:manifest-uri }">
			<xsl:apply-templates select="/" mode="ood:preparing-for-packing"/>
		</xsl:source-document>
	</xsl:template>

	<xsl:template mode="ood:preparing-for-packing" match="/">
		<xsl:context-item use="required" as="document-node( element( manifest:manifest ) )"/>
		<!-- <xsl:context-item use="required" as="document-node( schema-element( manifest:manifest ) )"/> -->
		<xsl:variable name="ood:complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="." mode="p:merge-document-files"/>
		</xsl:variable>
		<xsl:apply-templates select="$ood:complex-document" mode="p:create-inline-document-files"/>
	</xsl:template>

</xsl:package>
