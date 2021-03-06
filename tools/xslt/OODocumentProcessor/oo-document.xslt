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

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-merger.xslt" package-version="2.3">
		<xsl:accept component="template" names="p:merge-document-files" visibility="private"/>
	</xsl:use-package>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-writer.xslt" package-version="1.5">
		<xsl:accept component="mode" visibility="private" names="
			p:create-outline-document-files
			p:create-inline-document-files
			p:create-preprocessed-document-files
		"/>
	</xsl:use-package>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-preprocessor.xslt" package-version="2.3">
		<xsl:accept component="mode" names="p:document-preprocessing" visibility="private"/>
	</xsl:use-package>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/optimizer/OOOptimizer.xslt" package-version="1.5">
		<xsl:accept component="mode" names="o:optimize" visibility="private"/>
	</xsl:use-package>

	<!-- обработка XML файлов, полученных непосредственно после распаковки документа либо шаблона -->

	<xsl:template name="ood:prepare-after-unpacking" visibility="final">
		<xsl:context-item use="absent"/>
		<xsl:param name="ood:source-directory" as="xs:string" required="yes"/>
		<xsl:variable name="ood:complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:call-template name="p:merge-document-files">
				<xsl:with-param name="p:source-directory" select="$ood:source-directory"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:apply-templates select="$ood:complex-document" mode="p:create-outline-document-files"/>
	</xsl:template>

	<xsl:template name="ood:optimize" visibility="final">
		<xsl:context-item use="absent"/>
		<xsl:param name="ood:source-directory" as="xs:string" required="yes"/>
		<xsl:variable name="ood:complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:call-template name="p:merge-document-files">
				<xsl:with-param name="p:source-directory" select="$ood:source-directory"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="ood:optimized-document" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="$ood:complex-document" mode="o:optimize"/>
		</xsl:variable>
		<xsl:apply-templates select="$ood:optimized-document" mode="p:create-outline-document-files"/>
	</xsl:template>

	<!-- обработка XML файлов перед сборкой документа либо шаблона -->

	<xsl:template name="ood:preprocess" visibility="final">
		<xsl:context-item use="absent"/>
		<xsl:param name="ood:source-directory" as="xs:string" required="yes"/>
		<xsl:param name="ood:version" as="xs:string" required="no" select="''"/>
		<xsl:variable name="ood:complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:call-template name="p:merge-document-files">
				<xsl:with-param name="p:source-directory" select="$ood:source-directory"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="ood:preprocessed-complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="$ood:complex-document" mode="p:document-preprocessing">
				<xsl:with-param name="p:version" select="$ood:version"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:apply-templates select="$ood:preprocessed-complex-document" mode="p:create-preprocessed-document-files"/>
	</xsl:template>

	<xsl:template name="ood:prepare-for-packing" visibility="final">
		<xsl:context-item use="absent"/>
		<xsl:param name="ood:source-directory" as="xs:string" required="yes"/>
		<xsl:variable name="ood:complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:call-template name="p:merge-document-files">
				<xsl:with-param name="p:source-directory" select="$ood:source-directory"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:apply-templates select="$ood:complex-document" mode="p:create-inline-document-files"/>
	</xsl:template>

</xsl:package>
