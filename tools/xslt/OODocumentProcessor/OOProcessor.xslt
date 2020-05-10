<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOProcessor"
	name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/OOProcessor.xslt"
	package-version="1.5.0"
	input-type-annotations="preserve"
	declared-modes="yes"
	default-validation="preserve"
	expand-text="no"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:err="http://www.w3.org/2005/xqt-errors"
	xmlns:saxon="http://saxon.sf.net/"

	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"

	xmlns:f="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"
	xmlns:p="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
>

	<xsl:variable name="p:dont-stop-on-empty-files" as="xs:boolean" static="yes" select="false()" visibility="private"/>

	<!--
		Сбор всех XML файлов документа в единый файл.
		Основа структуры - файл манифеста.
		Содержимое файлов включаем в элементы манифеста.
	-->
	<xsl:mode
		name="p:merge-document-files"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<!--
		Разбор единого XML файла в отдельные XML файлы с форматированием.
	-->
	<xsl:mode
		name="p:create-outline-document-files"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OO.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:outline f:inline" visibility="final"/>
	</xsl:use-package>

	<!-- Сборка XML файлов в один на базе манифеста -->

	<xsl:template mode="p:merge-document-files" match="/manifest:manifest/manifest:file-entry[
		( @manifest:media-type='text/xml' )
		or ( @manifest:media-type='application/rdf+xml' )
		or ( @manifest:media-type='' and ends-with( @manifest:full-path, '.xml' ) )
	]">
		<xsl:param name="p:document-folder-uri" as="xs:anyURI" select="resolve-uri( '..', base-uri() )" tunnel="yes"/>
		<xsl:try rollback-output="yes">
			<xsl:copy>
				<xsl:apply-templates select="@*" mode="#current"/>
				<xsl:source-document href="{ iri-to-uri( resolve-uri( data( @manifest:full-path ), $p:document-folder-uri ) ) }"
					streamable="no" use-accumulators="#all" validation="preserve"
				>
					<xsl:apply-templates select="." mode="f:inline"/>
				</xsl:source-document>
			</xsl:copy>
			<xsl:catch errors="plug"/>
			<!-- <xsl:catch errors="SXXP0003" use-when="$p:dont-stop-on-empty-files"> -->
			<xsl:catch errors="*" use-when="$p:dont-stop-on-empty-files">
				<xsl:message terminate="no" error-code="SXXP0003" expand-text="yes">Empty XML file! Check file "{ resolve-uri( data( @manifest:full-path ), $p:document-folder-uri ) }".</xsl:message>
			</xsl:catch>
		</xsl:try>
	</xsl:template>

	<!-- Сохранение XML файлов из одного с форматированием -->

	<xsl:template mode="p:create-outline-document-files" match="/">
		<xsl:context-item use="required" as="document-node()"/>
		<!-- <xsl:context-item use="required" as="document-node( schema-element( manifest:manifest ) )"/> -->
		<xsl:apply-templates select="/manifest:manifest/manifest:file-entry" mode="#current"/>
	</xsl:template>

	<xsl:template mode="p:create-outline-document-files" match="/manifest:manifest/manifest:file-entry[
		( @manifest:media-type='text/xml' )
		or ( @manifest:media-type='' and ends-with( @manifest:full-path, '.xml' ) )
	]">
		<xsl:result-document href="{ iri-to-uri( data( @manifest:full-path ) ) }" format="p:OOXmlFile" validation="preserve">
			<xsl:apply-templates select="*" mode="f:outline"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template mode="p:create-outline-document-files" match="/manifest:manifest/manifest:file-entry[
		@manifest:media-type='application/rdf+xml'
	]">
		<xsl:result-document href="{ iri-to-uri( data( @manifest:full-path ) ) }" format="p:OORdfFile" validation="preserve">
			<xsl:apply-templates select="*" mode="f:outline"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:output name="p:OOXmlFile"
		media-type="text/xml"
		method="xml" omit-xml-declaration="no" version="1.0" standalone="omit"
		encoding="UTF-8" byte-order-mark="no"
		indent="no"
	/>
	<xsl:output name="p:OORdfFile"
		media-type="application/rdf+xml"
		method="xml" omit-xml-declaration="no" version="1.0" standalone="omit"
		encoding="UTF-8" byte-order-mark="no"
		indent="no"
	/>

</xsl:package>
