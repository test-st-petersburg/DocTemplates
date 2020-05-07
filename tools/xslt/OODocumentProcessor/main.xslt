<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OODocumentProcessor"
	name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/main.xslt"
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

	<!--
		Режим обработки файла манифеста документа (при запуске с передачей потока манифеста)
	-->
	<xsl:mode
		name="p:process-document-manifest"
		on-no-match="fail" warning-on-no-match="yes"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<!--
		Режим, предназначенный для обработки XML файлов документа
	-->
	<xsl:mode
		name="p:process-document-file"
		on-no-match="deep-skip" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<!--
		Для определения порядка обработки файлов документа необходимо переопределить шаблоны в указанном ниже режиме
		в преобразовании, использующем данный пакет
	-->
	<xsl:mode
		name="p:process-document-file-document-node"
		on-no-match="fail" warning-on-no-match="yes"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="public"
	/>

	<xsl:template name="p:process" visibility="final">
		<xsl:context-item use="absent"/>
		<xsl:param name="p:document-folder-uri" as="xs:anyURI" required="yes" tunnel="yes"/>
		<xsl:source-document href="{ iri-to-uri( resolve-uri( 'META-INF/manifest.xml', $p:document-folder-uri ) ) }"
			streamable="no" use-accumulators="" validation="preserve"
		>
			<xsl:apply-templates select="." mode="p:process-document-manifest"/>
		</xsl:source-document>
	</xsl:template>

	<xsl:template mode="p:process-document-manifest" match="/">
		<xsl:context-item use="required" as="document-node()"/>
		<!-- <xsl:context-item use="required" as="document-node( schema-element( manifest:manifest ) )"/> -->
		<xsl:apply-templates select="/manifest:manifest/manifest:file-entry" mode="p:process-document-file">
			<xsl:with-param name="p:document-folder-uri" as="xs:anyURI" select="resolve-uri( '..', base-uri() )" tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template mode="p:process-document-file" match="/manifest:manifest/manifest:file-entry[
		( @manifest:media-type='text/xml' )
		or ( @manifest:media-type='' and ends-with( @manifest:full-path, '.xml' ) )
	]">
		<xsl:param name="p:document-folder-uri" as="xs:anyURI" required="yes" tunnel="yes"/>
		<xsl:variable name="p:file-relative-uri" select="data( @manifest:full-path )"/>
		<xsl:try rollback-output="yes">
			<xsl:source-document href="{ iri-to-uri( resolve-uri( $p:file-relative-uri, $p:document-folder-uri ) ) }"
				streamable="no" use-accumulators="#all" validation="preserve"
			>
				<xsl:result-document href="{ iri-to-uri( $p:file-relative-uri ) }" format="p:OOXmlFile" validation="preserve">
					<xsl:apply-templates select="/" mode="p:process-document-file-document-node"/>
				</xsl:result-document>
			</xsl:source-document>
			<!-- <xsl:catch errors="SXXP0003"> -->
			<xsl:catch errors="*">
				<xsl:message terminate="no" error-code="SXXP0003" expand-text="yes">Empty XML file! Check file "{ resolve-uri( $p:file-relative-uri, $p:document-folder-uri ) }".</xsl:message>
			</xsl:catch>
		</xsl:try>
	</xsl:template>

	<xsl:template mode="p:process-document-file" match="/manifest:manifest/manifest:file-entry[
		@manifest:media-type='application/rdf+xml'
	]">
		<xsl:param name="p:document-folder-uri" as="xs:anyURI" required="yes" tunnel="yes"/>
		<xsl:variable name="p:file-relative-uri" select="data( @manifest:full-path )"/>
		<xsl:try rollback-output="yes">
			<xsl:source-document href="{ iri-to-uri( resolve-uri( $p:file-relative-uri, $p:document-folder-uri ) ) }"
				streamable="no" use-accumulators="#all" validation="preserve"
			>
				<xsl:result-document href="{ iri-to-uri( $p:file-relative-uri ) }" format="p:OORdfFile" validation="preserve">
					<xsl:apply-templates select="/" mode="p:process-document-file-document-node"/>
				</xsl:result-document>
			</xsl:source-document>
			<!-- <xsl:catch errors="SXXP0003"> -->
			<xsl:catch errors="*">
				<xsl:message terminate="no" error-code="SXXP0003" expand-text="yes">Empty XML file! Check file "{ resolve-uri( $p:file-relative-uri, $p:document-folder-uri ) }".</xsl:message>
			</xsl:catch>
		</xsl:try>
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
