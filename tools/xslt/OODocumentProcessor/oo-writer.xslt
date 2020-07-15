<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOWriter"
	name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-writer.xslt"
	package-version="1.5.0"
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

	<xsl:variable name="p:restore-doctype" as="xs:boolean" static="yes" select="true()" visibility="private"/>

	<!--
		Разбор единого XML файла в отдельные XML файлы с форматированием.
	-->
	<xsl:mode
		name="p:create-outline-document-files"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>
	<xsl:mode
		name="p:create-inline-document-files"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>
	<xsl:mode
		name="p:create-preprocessed-document-files"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OO.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:outline f:inline" visibility="private"/>
	</xsl:use-package>

	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- запись препроцессированных файлов                                                         -->
	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:mode
		name="p:select-manifest-binary"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:template mode="p:create-preprocessed-document-files" match="/">
		<xsl:context-item use="required" as="document-node( element( manifest:manifest ) )"/>
		<xsl:variable name="p:manifest-binary" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="." mode="p:select-manifest-binary"/>
		</xsl:variable>
		<xsl:result-document href="{ $p:manifest-binary-uri }"
			format="p:OOXmlFileFormat"
		>
			<xsl:apply-templates select="$p:manifest-binary" mode="f:outline"/>
		</xsl:result-document>
		<xsl:apply-templates select="." mode="p:create-outline-document-files"/>
	</xsl:template>

	<xsl:template mode="p:create-outline-document-files p:create-inline-document-files"
		match="/manifest:manifest/manifest:file-entry[ @manifest:full-path = $p:manifest-uri ]"
	/>

	<xsl:template mode="p:select-manifest-binary" match="/manifest:manifest/manifest:file-entry[ exists( * ) ]"/>

	<xsl:template mode="p:select-manifest-binary" match="/manifest:manifest/manifest:file-entry/*"/>

	<xsl:template mode="p:select-manifest-binary" match="/manifest:manifest/manifest:file-entry[
		ends-with( @manifest:full-path, '/' )
	]"/>

	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- запись файлов                                                                             -->
	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:mode
		name="p:select-manifest"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:template mode="p:create-outline-document-files p:create-inline-document-files" match="/">
		<xsl:context-item use="required" as="document-node( element( manifest:manifest ) )"/>
		<!-- <xsl:context-item use="required" as="document-node( schema-element( manifest:manifest ) )"/> -->
		<xsl:variable name="p:manifest" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="." mode="p:select-manifest"/>
		</xsl:variable>
		<xsl:variable name="p:manifest-doctype-system" as="xs:string" select="'Manifest.dtd'" use-when="$p:restore-doctype"/>
		<xsl:variable name="p:manifest-doctype-system" as="xs:string" select="''" use-when="not( $p:restore-doctype )"/>
		<xsl:result-document href="{ $p:manifest-uri }"
			format="p:OOXmlFileFormat"
			doctype-system="{ $p:manifest-doctype-system }"
		>
			<xsl:apply-templates select="$p:manifest" mode="f:outline"/>
		</xsl:result-document>
		<xsl:apply-templates select="/manifest:manifest/manifest:file-entry" mode="#current"/>
	</xsl:template>

	<xsl:template mode="p:create-outline-document-files p:create-inline-document-files"
		match="/manifest:manifest/manifest:file-entry[ @manifest:full-path = $p:manifest-uri ]"
	/>

	<xsl:template mode="p:select-manifest" match="/manifest:manifest/manifest:file-entry/*"/>

	<xsl:template mode="p:select-manifest" match="@xml:base"/>

	<!--  -->

	<xsl:template mode="p:create-outline-document-files"
		match="/manifest:manifest/manifest:file-entry/*"
	>
		<xsl:apply-templates select="." mode="f:outline"/>
	</xsl:template>

	<xsl:template mode="p:create-inline-document-files"
		match="/manifest:manifest/manifest:file-entry/*"
	>
		<xsl:apply-templates select="." mode="f:inline"/>
	</xsl:template>

	<!--  -->

	<xsl:template mode="p:create-outline-document-files p:create-inline-document-files"
		match="/manifest:manifest/manifest:file-entry[ @manifest:full-path='/' ]"
	>
		<xsl:result-document href="mimetype" format="p:OOmimetypeFileFormat">
			<xsl:value-of select="@manifest:media-type"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template mode="p:create-outline-document-files p:create-inline-document-files" priority="-10"
		match="/manifest:manifest/manifest:file-entry[
			( @manifest:media-type='text/xml' )
			or ( @manifest:media-type='' and ends-with( @manifest:full-path, '.xml' ) )
		]"
	>
		<xsl:result-document href="{ data( @manifest:full-path ) }" format="p:OOXmlFile">
			<xsl:apply-templates mode="#current"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template mode="p:create-outline-document-files p:create-inline-document-files"
		match="/manifest:manifest/manifest:file-entry[ @manifest:media-type='application/rdf+xml' ]"
	>
		<xsl:result-document href="{ data( @manifest:full-path ) }" format="p:OORdfFile">
			<xsl:apply-templates mode="#current"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template mode="p:create-outline-document-files p:create-inline-document-files" use-when="$p:restore-doctype"
		 match="/manifest:manifest/manifest:file-entry[
			( @manifest:full-path='content.xml' )
			or ( @manifest:full-path='meta.xml' )
			or ( @manifest:full-path='settings.xml' )
			or ( @manifest:full-path='styles.xml' )
		]"
	>
		<xsl:result-document href="{ data( @manifest:full-path ) }"
			format="p:OOXmlFileFormat"
			doctype-system="office.dtd"
		>
			<xsl:apply-templates mode="#current"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template mode="p:create-outline-document-files p:create-inline-document-files" use-when="$p:restore-doctype"
		 match="/manifest:manifest/manifest:file-entry[ @manifest:full-path='Basic/script-lc.xml' ]"
	>
		<xsl:result-document href="{ data( @manifest:full-path ) }"
			format="p:OOXmlFileFormat"
			doctype-system="libraries.dtd"
		>
			<xsl:apply-templates mode="#current"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template mode="p:create-outline-document-files p:create-inline-document-files" use-when="$p:restore-doctype"
		 match="/manifest:manifest/manifest:file-entry[
			starts-with( @manifest:full-path, 'Basic/' )
			and ends-with( @manifest:full-path, '/script-lb.xml' )
		]"
		 priority="-1"
	>
		<xsl:result-document href="{ data( @manifest:full-path ) }"
			format="p:OOXmlFileFormat"
			doctype-system="library.dtd"
		>
			<xsl:apply-templates mode="#current"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template mode="p:create-outline-document-files p:create-inline-document-files" use-when="$p:restore-doctype"
		 match="/manifest:manifest/manifest:file-entry[	@manifest:full-path='Configurations2/images/lc_imagelist.xml' ]"
	>
		<xsl:result-document href="{ data( @manifest:full-path ) }"
			format="p:OOXmlFileFormat"
			doctype-system="image.dtd"
		>
			<xsl:apply-templates mode="#current"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template mode="p:create-outline-document-files p:create-inline-document-files" use-when="$p:restore-doctype"
		 match="/manifest:manifest/manifest:file-entry[
			starts-with( @manifest:full-path, 'Configurations2/menubar/' )
			or starts-with( @manifest:full-path, 'Configurations2/popupmenu/' )
		]"
	>
		<xsl:result-document href="{ data( @manifest:full-path ) }"
			format="p:OOXmlFileFormat"
			doctype-system="menubar.dtd"
		>
			<xsl:apply-templates mode="#current"/>
		</xsl:result-document>
	</xsl:template>

	<xsl:template mode="p:create-outline-document-files p:create-inline-document-files" use-when="$p:restore-doctype"
		 match="/manifest:manifest/manifest:file-entry[ starts-with( @manifest:full-path, 'Configurations2/toolbar/' ) ]"
	>
		<xsl:result-document href="{ data( @manifest:full-path ) }"
			format="p:OOXmlFileFormat"
			doctype-system="toolbar.dtd"
		>
			<xsl:apply-templates mode="#current"/>
		</xsl:result-document>
	</xsl:template>

	<!-- Описание форматов генерируемых файлов  -->

	<xsl:output name="p:OOmimetypeFileFormat"
		media-type="text/plain"
		method="text"
		encoding="UTF-8" byte-order-mark="no"
	/>

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

	<xsl:output name="p:OOXmlFileFormat"
		media-type="text/xml"
		method="xml" omit-xml-declaration="no" version="1.0" standalone="omit"
		encoding="UTF-8" byte-order-mark="no"
		indent="no"
		doctype-public="-//OpenOffice.org//DTD OfficeDocument 1.0//EN"
	/>

</xsl:package>
