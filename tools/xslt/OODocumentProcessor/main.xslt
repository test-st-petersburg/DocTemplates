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

	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"

	xmlns:f="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"
	xmlns:p="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
>

	<xsl:global-context-item use="absent"/>

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

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OO.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:outline" visibility="final"/>
		<xsl:accept component="mode" names="f:inline" visibility="final"/>
	</xsl:use-package>

	<xsl:template name="p:process" visibility="final">
		<xsl:context-item use="absent"/>
		<xsl:param name="p:document-folder-uri" as="xs:anyURI" required="yes" tunnel="yes"/>
		<xsl:source-document href="{ iri-to-uri( concat(  $p:document-folder-uri, 'META-INF/manifest.xml' ) ) }"
			streamable="no" use-accumulators="" validation="preserve"
		>
			<xsl:apply-templates select="/manifest:manifest/manifest:file-entry" mode="p:process-document-file"/>
		</xsl:source-document>
	</xsl:template>

	<xsl:template mode="p:process-document-file" match="/manifest:manifest/manifest:file-entry[
		( @manifest:media-type='text/xml' )
		or ( @manifest:media-type='' and ends-with( @manifest:full-path, '.xml' ) )
	]">
		<xsl:param name="p:document-folder-uri" as="xs:anyURI" required="yes" tunnel="yes"/>
		<xsl:variable name="p:file-relative-uri" select="data( @manifest:full-path )"/>
		<xsl:try rollback-output="yes">
			<xsl:source-document href="{ iri-to-uri( concat( $p:document-folder-uri, $p:file-relative-uri ) ) }"
				streamable="no" use-accumulators="#all" validation="preserve"
			>
				<xsl:result-document href="{ iri-to-uri( $p:file-relative-uri ) }" format="p:OOXmlFile" validation="preserve">
					<xsl:apply-templates select="/" mode="p:process-document-file-document-node"/>
				</xsl:result-document>
			</xsl:source-document>
			<xsl:catch errors="*"/>
		</xsl:try>
	</xsl:template>

	<xsl:template mode="p:process-document-file" match="/manifest:manifest/manifest:file-entry[
		@manifest:media-type='application/rdf+xml'
	]">
		<xsl:param name="p:document-folder-uri" as="xs:anyURI" required="yes" tunnel="yes"/>
		<xsl:variable name="file-full-path" select="data( @manifest:full-path )"/>
		<xsl:try rollback-output="yes">
			<xsl:source-document href="{ concat( iri-to-uri($p:document-folder-uri), $file-full-path ) }"
				streamable="no" use-accumulators="" validation="preserve"
			>
				<xsl:result-document href="{ $file-full-path }" format="p:OORdfFile" validation="preserve">
					<xsl:apply-templates select="/" mode="p:process-document-file-document-node"/>
				</xsl:result-document>
			</xsl:source-document>
			<xsl:catch errors="*"/>
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
