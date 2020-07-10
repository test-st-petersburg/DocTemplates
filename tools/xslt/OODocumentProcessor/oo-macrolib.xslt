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

	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
	xmlns:script="http://openoffice.org/2000/script"
	xmlns:library="http://openoffice.org/2000/library"

	xmlns:p="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
	xmlns:s="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/system"
	xmlns:u="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/system/uri"
>

	<xsl:import href="oo-defs.xslt"/>

	<xsl:param name="p:basic-module-header" as="xs:string" required="no">
		<xsl:text>
REM  *****  BASIC  *****

</xsl:text>
	</xsl:param>
	<xsl:param name="p:basic-module-footer" as="xs:string" required="no">
		<xsl:text/>
	</xsl:param>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/system/uri.xslt" package-version="2.3">
		<xsl:accept component="function" names="u:get-parent-directory-name u:get-file-name-without-extension u:make-relative-uri" visibility="private"/>
	</xsl:use-package>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-writer.xslt" package-version="1.5">
		<xsl:accept component="mode" visibility="private" names="p:create-outline-document-files"/>
	</xsl:use-package>

	<!-- сборка библиотеки сценариев из "исходных" файлов -->

	<xsl:template name="p:build-macro-library" visibility="final">
		<xsl:context-item use="absent"/>
		<xsl:param name="p:source-directory" as="xs:string" required="no" select="''"/>
		<xsl:param name="library:name" as="xs:string" required="no" select="u:get-parent-directory-name( xs:anyURI( $p:source-directory ) )"/>
		<xsl:param name="library:readonly" as="xs:boolean" required="no" select="false()"/>
		<xsl:param name="library:passwordprotected" as="xs:boolean" required="no" select="false()"/>
		<xsl:param name="script:language" as="xs:Name" select="xs:Name( 'StarBasic' )"/>
		<xsl:param name="script:moduleType" as="xs:NMTOKEN" select="xs:NMTOKEN( 'normal' )"/>

		<xsl:variable name="p:basic-modules-uri-collection" as="xs:anyURI*" select="
			uri-collection( concat( $p:source-directory, '?recurse=yes,select=*.bas' ) )
		"/>

		<xsl:variable name="p:complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:document>
				<xsl:element name="manifest:manifest" inherit-namespaces="no">
					<xsl:attribute name="manifest:version" select="$manifest:version"/>

					<xsl:element name="manifest:file-entry" inherit-namespaces="no">
						<xsl:attribute name="manifest:full-path" select="$p:basic-script-lib-uri"/>
						<xsl:attribute name="manifest:media-type" select="$p:basic-script-lib-media-type"/>

						<xsl:element name="library:library" inherit-namespaces="no">
							<xsl:attribute name="library:name" select="$library:name"/>
							<xsl:attribute name="library:readonly" select="$library:readonly"/>
							<xsl:attribute name="library:passwordprotected" select="$library:passwordprotected"/>

							<xsl:for-each select="$p:basic-modules-uri-collection">
								<xsl:element name="library:element" inherit-namespaces="no">
									<xsl:attribute name="library:name" select="u:get-file-name-without-extension( current() )"/>
								</xsl:element>
							</xsl:for-each>
						</xsl:element>
					</xsl:element>

					<xsl:for-each select="$p:basic-modules-uri-collection">
						<xsl:variable name="script:name" as="xs:string" select="u:get-file-name-without-extension( current() )"/>
						<xsl:element name="manifest:file-entry" inherit-namespaces="no">
							<xsl:attribute name="manifest:full-path" select="
								concat( $script:name, $p:basic-script-module-file-name-ext )
							"/>
							<xsl:attribute name="manifest:media-type" select="$p:basic-script-module-media-type"/>

							<xsl:element name="script:module" inherit-namespaces="no">
								<xsl:attribute name="script:name" select="$script:name"/>
								<xsl:attribute name="script:language" select="$script:language"/>
								<xsl:attribute name="script:moduleType" select="$script:moduleType"/>

								<xsl:value-of select="$p:basic-module-header"/>
								<xsl:value-of select="unparsed-text( current(), 'utf-8' )"/>
								<xsl:value-of select="$p:basic-module-footer"/>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:document>
		</xsl:variable>

		<xsl:apply-templates select="$p:complex-document/manifest:manifest/manifest:file-entry" mode="p:create-outline-document-files"/>
	</xsl:template>

	<!-- сборка контейнера библиотеки сценариев из библиотеки -->

	<xsl:template name="p:build-macro-library-container" visibility="final">
		<xsl:context-item use="absent"/>
		<xsl:param name="p:source-directory" as="xs:string" required="no" select="''"/>

		<xsl:variable name="p:script-xlb" as="document-node( element( library:library ) )">
			<xsl:source-document validation="lax" href="{ $p:source-directory || $p:basic-script-lib-uri }">
				<xsl:copy-of select="/" copy-namespaces="yes" validation="lax"/>
			</xsl:source-document>
		</xsl:variable>
		<xsl:variable name="library:name" as="xs:string" select=" $p:script-xlb/library:library/@library:name "/>
		<xsl:variable name="p:destination-scripts-directory" as="xs:string" select="
			'Basic/' || $library:name || '/'
		"/>

		<xsl:variable name="p:complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:document>
				<xsl:element name="manifest:manifest" inherit-namespaces="no">
					<xsl:attribute name="manifest:version" select="$manifest:version"/>

					<!-- script-lc.xml -->
					<xsl:element name="manifest:file-entry" inherit-namespaces="no">
						<xsl:attribute name="manifest:full-path" select="
							'Basic/'
							|| $p:basic-script-container-uri
						"/>
						<xsl:attribute name="manifest:media-type" select="$p:basic-script-container-media-type"/>
						<xsl:element name="library:libraries" inherit-namespaces="no">
							<xsl:element name="library:library" inherit-namespaces="no">
								<xsl:attribute name="library:name" select="$library:name"/>
								<xsl:attribute name="library:link" select=" false() "/>
							</xsl:element>
						</xsl:element>
					</xsl:element>

					<!-- script-lb.xml -->
					<xsl:element name="manifest:file-entry" inherit-namespaces="no">
						<xsl:attribute name="manifest:full-path" select="
							$p:destination-scripts-directory
							|| $p:basic-script-lib-in-container-uri
						"/>
						<xsl:attribute name="manifest:media-type" select="$p:basic-script-lib-in-container-media-type"/>
						<xsl:copy-of select="$p:script-xlb" copy-namespaces="yes" validation="lax"/>
					</xsl:element>

					<!-- файлы модулей -->
					<xsl:for-each select="$p:script-xlb/library:library/library:element">
						<xsl:variable name="script:name" as="xs:string" select=" ./@library:name "/>
						<xsl:element name="manifest:file-entry" inherit-namespaces="no">
							<xsl:attribute name="manifest:full-path" select="
								$p:destination-scripts-directory
								|| $script:name || $p:basic-script-module-in-container-file-name-ext
							"/>
							<xsl:attribute name="manifest:media-type" select="$p:basic-script-module-in-container-media-type"/>
							<xsl:source-document validation="lax"
								href="{ $p:source-directory || $script:name || $p:basic-script-module-file-name-ext }"
							>
								<xsl:copy-of select="/" copy-namespaces="yes" validation="lax"/>
							</xsl:source-document>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:document>
		</xsl:variable>

		<xsl:apply-templates select="$p:complex-document" mode="p:create-outline-document-files"/>
	</xsl:template>

</xsl:package>
