<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOMacroLib"
	name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-macrolib.xslt"
	package-version="2.3.0"
	declared-modes="yes"
	expand-text="no"
	input-type-annotations="strip"
	default-validation="strip"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:err="http://www.w3.org/2005/xqt-errors"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"

	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:script="http://openoffice.org/2000/script"
	xmlns:library="http://openoffice.org/2000/library"

	xmlns:p="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
>

	<xsl:param name="p:basic-module-header" as="xs:string" required="no">
		<xsl:text>
REM  *****  BASIC  *****

</xsl:text>
	</xsl:param>
	<xsl:param name="p:basic-module-footer" as="xs:string" required="no">
		<xsl:text/>
	</xsl:param>

	<!-- сборка библиотеки сценариев из "исходных" файлов -->
	<xsl:mode
		name="p:build-macro-library"
		on-no-match="fail" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<xsl:template name="p:build-macro-library" visibility="final">
		<xsl:context-item use="optional"/>
		<xsl:param name="p:source-directory" as="xs:string" required="no" select="''"/>
		<xsl:param name="p:destination-directory" as="xs:string" required="no" select="''"/>
		<xsl:param name="library:name" as="xs:string" required="no" select="
			tokenize(
				replace( resolve-uri( $p:source-directory ), '/$', '' ),
				'/'
			)[ last() ]
		"/>
		<xsl:param name="library:readonly" as="xs:boolean" required="no" select="false()"/>
		<xsl:param name="library:passwordprotected" as="xs:boolean" required="no" select="false()"/>
		<xsl:param name="script:language" as="xs:Name" select="xs:Name( 'StarBasic' )"/>
		<xsl:param name="script:moduleType" as="xs:NMTOKEN" select="xs:NMTOKEN( 'normal' )"/>

		<xsl:result-document href="{ concat( $p:destination-directory, 'script.xlb' ) }"
			format="p:OOXmlFileFormat"
			doctype-system="library.dtd"
			indent="yes"
		>
			<xsl:element name="library:library" inherit-namespaces="no">
				<xsl:attribute name="library:name" select="$library:name"/>
				<xsl:attribute name="library:readonly" select="$library:readonly"/>
				<xsl:attribute name="library:passwordprotected" select="$library:passwordprotected"/>

				<xsl:for-each select="uri-collection( concat( $p:source-directory, '?recurse=yes,select=*.bas' ) )">
					<xsl:variable name="p:relative-current-uri" as="xs:string" select="
						substring-after(
							replace( current(), '^(?:(?:\w{2,}):/{1,3})', '' ),
							replace( resolve-uri( $p:source-directory ), '^(?:(?:\w{2,}):/{1,3})', '' )
						)
					"/>
					<xsl:variable name="script:name" as="xs:string" select="
						data( analyze-string(
							current(),
							'^((?:(?:\w{2,}):/{1,3})?)((?:\w:)?)((?:(?:[^/]+)/)*)([^/]+?)((?:\.[^/.]+)?)$'
						)/fn:match/fn:group[ @nr = '4' ]/text() )
					"/>
					<xsl:fork>
						<xsl:sequence>
							<xsl:element name="library:element" inherit-namespaces="no">
								<xsl:attribute name="library:name" select="$script:name"/>
							</xsl:element>
						</xsl:sequence>
						<xsl:sequence>
							<xsl:result-document href="{ concat( $p:destination-directory, $script:name, '.xba' ) }"
								format="p:OOXmlFileFormat"
							>
								<xsl:element name="script:module" inherit-namespaces="no">
									<xsl:attribute name="script:name" select="$script:name"/>
									<xsl:attribute name="script:language" select="$script:language"/>
									<xsl:attribute name="script:moduleType" select="$script:moduleType"/>
									<xsl:value-of select="$p:basic-module-header"/>
									<xsl:value-of select="unparsed-text( current(), 'utf-8' )"/>
									<xsl:value-of select="$p:basic-module-footer"/>
								</xsl:element>
							</xsl:result-document>
						</xsl:sequence>
					</xsl:fork>
				</xsl:for-each>
			</xsl:element>
		</xsl:result-document>
	</xsl:template>

	<xsl:output name="p:OOXmlFileFormat"
		media-type="text/xml"
		method="xml" omit-xml-declaration="no" version="1.0" standalone="omit"
		encoding="UTF-8" byte-order-mark="no"
		indent="no"
		doctype-public="-//OpenOffice.org//DTD OfficeDocument 1.0//EN"
	/>

</xsl:package>
