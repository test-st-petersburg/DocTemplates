<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOMerger"
	name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-merger.xslt"
	package-version="2.3.0"
	declared-modes="yes"
	expand-text="no"
	input-type-annotations="strip"
	default-validation="strip"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:err="http://www.w3.org/2005/xqt-errors"
	xmlns:saxon="http://saxon.sf.net/"

	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"

	xmlns:f="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"
	xmlns:p="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
>

	<xsl:import href="oo-defs.xslt"/>

	<xsl:variable name="p:dont-stop-on-empty-files" as="xs:boolean" static="yes" select="true()" visibility="private"/>

	<!--
		Сбор всех XML файлов документа в единый файл.
		Основа структуры - файл манифеста.
		Содержимое файлов включаем в элементы манифеста.
	-->
	<xsl:mode
		name="p:document-files-merging"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<!-- собственное включение XML файлов, указанных в манифесте, в единый XML документ -->
	<xsl:mode
		name="p:document-files-including-on-merging"
		on-no-match="deep-skip" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OO.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:inline" visibility="final"/>
	</xsl:use-package>

	<xsl:template name="p:merge-document-files" as="document-node( element( manifest:manifest ) )" visibility="final">
		<xsl:context-item use="optional"/>
		<xsl:param name="p:source-directory" as="xs:string" required="yes"/>
		<xsl:source-document validation="lax" href="{ $p:source-directory || $p:manifest-uri }">
			<xsl:apply-templates select="/" mode="p:document-files-merging">
				<xsl:with-param name="p:document-folder-uri" as="xs:anyURI" tunnel="yes" select="
					resolve-uri( $p:source-directory, base-uri() )
				"/>
			</xsl:apply-templates>
		</xsl:source-document>
	</xsl:template>

	<xsl:template mode="p:document-files-merging" match="/manifest:manifest">
		<xsl:param name="p:document-folder-uri" as="xs:anyURI" select="resolve-uri( '..', base-uri() )" tunnel="yes"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="#current"/>
			<xsl:if test=" empty( @xml:base ) ">
				<xsl:attribute name="xml:base" select=" $p:document-folder-uri "/>
			</xsl:if>
			<xsl:apply-templates mode="#current"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template mode="p:document-files-merging" match="/manifest:manifest/manifest:file-entry">
		<xsl:param name="p:document-folder-uri" as="xs:anyURI" select="resolve-uri( '..', base-uri() )" tunnel="yes"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="#current"/>
			<xsl:if test=" empty( @xml:base ) ">
				<xsl:attribute name="xml:base" select=" $p:document-folder-uri "/>
			</xsl:if>
			<xsl:apply-templates select="." mode="p:document-files-including-on-merging">
				<xsl:with-param name="p:document-folder-uri" as="xs:anyURI" select="$p:document-folder-uri" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template mode="p:document-files-including-on-merging" match="/manifest:manifest/manifest:file-entry[
		( @manifest:media-type='text/xml' )
		or ( @manifest:media-type='application/rdf+xml' )
		or ( @manifest:media-type='' and ends-with( @manifest:full-path, '.xml' ) )
	]">
		<xsl:param name="p:document-folder-uri" as="xs:anyURI" select="resolve-uri( base-uri() )" tunnel="yes"/>
		<!-- TODO: решить проблему с обработкой отсутствующих файлов, указанных в манифесте -->
		<!-- <xsl:try rollback-output="yes"> -->
			<xsl:source-document streamable="no" use-accumulators="#all" href="{
				iri-to-uri( resolve-uri( data( @manifest:full-path ), $p:document-folder-uri ) )
			}">
				<xsl:apply-templates select="." mode="f:inline"/>
			</xsl:source-document>
			<!-- <xsl:catch errors="SXXP0003" use-when="$p:dont-stop-on-empty-files"> -->
			<!-- <xsl:catch errors="*" use-when="$p:dont-stop-on-empty-files">
				<xsl:message terminate="no" error-code="SXXP0003" expand-text="yes">Empty XML file! Check file "{ resolve-uri( data( @manifest:full-path ), $p:document-folder-uri ) }".</xsl:message>
			</xsl:catch> -->
		<!-- </xsl:try> -->
	</xsl:template>

</xsl:package>
