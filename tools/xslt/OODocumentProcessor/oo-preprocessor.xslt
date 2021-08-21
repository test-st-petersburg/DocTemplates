<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOPreprocessor"
	name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-preprocessor.xslt"
	package-version="2.3.0"
	declared-modes="yes"
	expand-text="no"
	input-type-annotations="strip"
	default-validation="strip"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:err="http://www.w3.org/2005/xqt-errors"

	xmlns:array="http://www.w3.org/2005/xpath-functions/array"
	xmlns:css3t="http://www.w3.org/TR/css3-text/"
	xmlns:dom="http://www.w3.org/2001/xml-events"
	xmlns:grddl="http://www.w3.org/2003/g/data-view#"
	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:xforms="http://www.w3.org/2002/xforms"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"

	xmlns:calcext="urn:org:documentfoundation:names:experimental:calc:xmlns:calcext:1.0"
	xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
	xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
	xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
	xmlns:drawooo="http://openoffice.org/2010/draw"
	xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0"
	xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
	xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
	xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0"
	xmlns:library="http://openoffice.org/2000/library"
	xmlns:loext="urn:org:documentfoundation:names:experimental:office:xmlns:loext:1.0"
	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
	xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
	xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
	xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2"
	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
	xmlns:officeooo="http://openoffice.org/2009/office"
	xmlns:ooo="http://openoffice.org/2004/office"
	xmlns:oooc="http://openoffice.org/2004/calc"
	xmlns:ooow="http://openoffice.org/2004/writer"
	xmlns:rpt="http://openoffice.org/2005/report"
	xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
	xmlns:script-module="http://openoffice.org/2000/script"
	xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
	xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
	xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
	xmlns:tableooo="http://openoffice.org/2009/table"
	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
	xmlns:toolbar="http://openoffice.org/2001/toolbar"

	xmlns:p="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
	xmlns:oom="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
	xmlns:fix="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/system/fix"
>

	<xsl:import href="oo-defs.xslt"/>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-merger.xslt" package-version="2.3">
		<xsl:accept component="template" names="p:merge-document-files" visibility="private"/>
	</xsl:use-package>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-macrolib.xslt" package-version="2.3">
		<xsl:accept component="template" names="oom:get-macro-library-container" visibility="final"/>
	</xsl:use-package>

	<xsl:use-package name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/system/fix-saxon.xslt" package-version="2.3">
		<xsl:accept component="function" names="fix:doc" visibility="private"/>
	</xsl:use-package>

	<xsl:param name="p:comment-preprocessing-results" as="xs:boolean" static="yes" select="true()"/>
	<xsl:param name="p:embed-linked-libraries" as="xs:boolean" static="yes" select="true()"/>
	<xsl:param name="p:embed-linked-templates" as="xs:boolean" static="yes" select="true()"/>

	<?region препроцессирование документа ?>

	<xsl:mode name="p:document-preprocessing"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<xsl:key name="p:document-settings"
		match=" office:document-settings/office:settings/config:config-item-set/config:config-item "
		use="@config:name"
	/>

	<xsl:template mode="p:document-preprocessing" as="document-node( element( manifest:manifest ) )" match="/">
		<xsl:context-item use="required" as="document-node( element( manifest:manifest ) )"/>
		<xsl:param name="p:version" as="xs:string" required="no" select="''"/>
		<xsl:variable name="p:document-aux-1" as="document-node( element( manifest:manifest ) )">
			<xsl:copy-of select="."/>
		</xsl:variable>
		<xsl:variable name="p:document-aux-2" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="$p:document-aux-1" mode="p:external-objects-embedding"/>
		</xsl:variable>
		<xsl:variable name="p:document-aux-3" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="$p:document-aux-2" mode="p:internal-links-embedding"/>
		</xsl:variable>
		<xsl:variable name="p:document-aux-4" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="$p:document-aux-3" mode="p:automatic-styles-generation"/>
		</xsl:variable>
		<xsl:variable name="p:document-aux-5" as="document-node( element( manifest:manifest ) )">
			<xsl:choose>
				<xsl:when test=" key( 'p:document-settings', 'EmbedFonts' ) = 'true' ">
					<xsl:copy-of select=" $p:document-aux-4 "/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="$p:document-aux-4" mode="p:embedded-fonts-removing"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="p:updated-complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="$p:document-aux-5" mode="p:document-meta-updating">
				<xsl:with-param name="p:version" select="$p:version" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:copy-of select="$p:updated-complex-document"/>
	</xsl:template>

	<?endregion препроцессирование документа ?>
	<?region document meta updating ?>
	<xsl:include href="preprocessor/document-meta-updating.xslt"/>

	<?endregion document meta updating ?>
	<?region internal links embedding ?>

	<xsl:mode name="p:internal-links-embedding"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:template mode="p:internal-links-embedding" match="@*[
		namespace-uri() = 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor'
	]"/>

	<xsl:include href="preprocessor/internal-links-embedding-section-source.xslt"/>

	<?endregion internal links embedding ?>
	<?region automatic styles generation #62 ?>

	<xsl:mode name="p:automatic-styles-generation"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:include href="preprocessor/automatic-styles-generation.xslt"/>

	<?endregion automatic styles generation #62 ?>
	<?region внедрение дополнительных групп файлов с манифестами ?>

	<xsl:mode name="p:external-objects-embedding"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:mode name="p:get-embed-objects-collection"
		on-no-match="shallow-skip" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:mode name="p:external-objects-links-replacing"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:template mode="p:external-objects-embedding" as="document-node( element( manifest:manifest ) )" match="/">
		<xsl:context-item use="required" as="document-node( element( manifest:manifest ) )"/>
		<xsl:variable name="p:complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:copy-of select="."/>
		</xsl:variable>
		<xsl:variable name="p:embed-objects" as="document-node( element( manifest:manifest ) )*">
			<xsl:apply-templates select="$p:complex-document" mode="p:get-embed-objects-collection"/>
		</xsl:variable>
		<xsl:variable name="p:complex-document-with-embedded-objects" as="document-node( element( manifest:manifest ) )">
			<xsl:document>
				<xsl:copy select="$p:complex-document/manifest:manifest">
					<xsl:copy-of select="@*"/>
					<xsl:merge>
						<xsl:merge-source name="source-document" for-each-item=" $p:complex-document "
							select=" /manifest:manifest/manifest:file-entry "
							sort-before-merge="yes"
						>
							<xsl:merge-key select="@manifest:full-path" order="ascending"/>
						</xsl:merge-source>
						<xsl:merge-source name="embed-objects" for-each-item=" $p:embed-objects "
							select=" /manifest:manifest/manifest:file-entry "
							sort-before-merge="yes"
						>
							<xsl:merge-key select="@manifest:full-path" order="ascending"/>
						</xsl:merge-source>
						<xsl:merge-action>
							<xsl:choose>
								<xsl:when test=" count( current-merge-group() ) = 1 ">
									<xsl:copy-of select=" current-merge-group() "/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:copy select=" head( current-merge-group() )">
										<xsl:copy-of select=" head( current-merge-group() )/@* "/>
										<xsl:apply-templates mode="p:external-objects-files-merging" select=" current-merge-key() ">
											<xsl:with-param name="p:source-document" select=" current-merge-group( 'source-document' ) "/>
											<xsl:with-param name="p:embed-objects" select=" current-merge-group( 'embed-objects' ) "/>
										</xsl:apply-templates>
									</xsl:copy>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:merge-action>
					</xsl:merge>
				</xsl:copy>
			</xsl:document>
		</xsl:variable>
		<xsl:variable name="p:complex-document-without-links-to-objects" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="$p:complex-document-with-embedded-objects" mode="p:external-objects-links-replacing"/>
		</xsl:variable>
		<xsl:copy-of select="$p:complex-document-without-links-to-objects"/>
	</xsl:template>

	<?endregion внедрение дополнительных групп файлов с манифестами ?>
	<?region слияние файлов при наличии во включаемых объектах тех же файлов, что и в основном документе ?>

	<xsl:mode name="p:external-objects-files-merging"
		on-no-match="deep-skip" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:mode name="p:external-objects-files-content-merging"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:template mode="p:external-objects-files-merging" match=" . " priority="-1">
		<xsl:param name="p:source-document" as=" element( manifest:file-entry )? " required="yes"/>
		<xsl:param name="p:embed-objects" as=" element( manifest:file-entry )* " required="yes"/>
		<xsl:choose>
			<xsl:when test=" exists( $p:source-document ) ">
				<xsl:copy-of select=" $p:source-document/* "/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:assert test=" count( $p:embed-objects ) = 1 " select="
					'More just one linked object can add same file: ' || . || '.'
				"/>
				<xsl:copy-of select=" $p:embed-objects "/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="p:external-objects-files-merging" match=" .[
		. = 'content.xml'
	] ">
		<xsl:param name="p:source-document" as=" element( manifest:file-entry ) " required="yes"/>
		<xsl:param name="p:embed-objects" as=" element( manifest:file-entry )* " required="yes"/>
		<xsl:apply-templates mode="p:external-objects-files-content-merging" select=" $p:source-document/* ">
			<xsl:with-param name="p:embed-objects" select=" $p:embed-objects " tunnel="yes"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:include href="preprocessor/content-merger.xslt"/>

	<xsl:include href="preprocessor/settings-merger.xslt"/>

	<?endregion слияние файлов при наличии во включаемых объектах тех же файлов, что и в основном документе ?>
	<?region внедрение связанных библиотек (`library:library[ @library:link = 'true' ]`) #83 ?>

	<xsl:template mode="p:get-embed-objects-collection" as="document-node( element( manifest:manifest ) )"
		 use-when="$p:embed-linked-libraries"
		 match=" library:libraries/library:library[ @library:link = 'true' ] "
	>
		<xsl:assert test="exists( @library:name )" select=" 'Library name must be specified.' "/>
		<xsl:variable name="library:name" as="xs:string" select=" @library:name "/>
		<!-- TODO: путь к собранным библиотекам макросов вынести в константы, а лучше - в параметры -->
		<xsl:variable name="xlink:href" as="xs:anyURI" select="
			if ( exists( @xlink:href ) )
				then @xlink:href
				else resolve-uri(
					'../../../output/basic/' || iri-to-uri( $library:name ) || '/' || $p:basic-script-lib-uri,
					base-uri()
				)
		"/>
		<xsl:call-template name="oom:get-macro-library-container">
			<xsl:with-param name="oom:source-directory" select=" resolve-uri( './', $xlink:href ) "/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template mode="p:external-objects-links-replacing" use-when="$p:embed-linked-libraries" match="
		library:libraries/library:library[ @library:link = 'true' ]
	">
		<xsl:copy>
			<xsl:copy-of select=" @library:name "/>
			<xsl:attribute name="library:link" select=" false() "/>
			<xsl:attribute name="library:readonly" select="
				if ( exists( @library:readonly ) )
					then @library:readonly
					else true()
			"/>
		</xsl:copy>
	</xsl:template>

	<?endregion внедрение связанных библиотек (`library:library[ @library:link = 'true' ]`) #83 ?>
	<?region внедрение шаблона документа в документ (`meta:template`) #75 ?>

	<xsl:template mode="p:get-embed-objects-collection" as="document-node( element( manifest:manifest ) )"
		 use-when="$p:embed-linked-templates"
		 match=" meta:template "
	>
		<xsl:assert test="exists( @xlink:title )" select=" 'Template name must be specified.' "/>
		<!-- TODO: путь к препроцессированным шаблонам вынести в константы, а лучше - в параметры -->
		<!-- TODO: расширение шаблона документа .ott вынести в константы -->
		<!-- TODO: реализовать определение расширения имени шаблона документа исходя из типа документа (.ott подходит только для .odt) -->
		<!-- TODO: или же использовать @xlink:href, а точнее - только имя файла из него -->
		<xsl:variable name="xlink:href" as="xs:anyURI" select=" resolve-uri(
			'../../../tmp/template/' || iri-to-uri( @xlink:title ) || '.ott' || '/',
			base-uri()
		) "/>
		<xsl:call-template name="p:merge-document-files">
			<xsl:with-param name="p:source-directory" select=" $xlink:href "/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template mode="p:external-objects-links-replacing" use-when="$p:embed-linked-templates"
		 match=" meta:template "
	>
		<xsl:assert test="exists( @xlink:title )" select=" 'Template name must be specified.' "/>
		<xsl:copy>
			<xsl:attribute name="xlink:type" select=" 'simple' "/>
			<xsl:copy-of select="@xlink:title"/>
			<!-- TODO: путь к собранным шаблонам вынести в константы, а лучше - в параметры -->
			<!-- TODO: расширение шаблона документа .ott вынести в константы -->
			<!-- TODO: реализовать определение расширения имени шаблона документа исходя из типа документа (.ott подходит только для .odt) -->
			<!-- TODO: или же использовать @xlink:href, а точнее - только имя файла из него -->
			<xsl:attribute name="xlink:href" select=" '../template/' || iri-to-uri( @xlink:title ) || '.ott' "/>
			<xsl:attribute name="xlink:actuate" select=" 'onRequest' "/>
			<!-- TODO: путь к препроцессированным шаблонам вынести в константы, а лучше - в параметры -->
			<!-- TODO: расширение шаблона документа .ott вынести в константы -->
			<!-- TODO: реализовать определение расширения имени шаблона документа исходя из типа документа (.ott подходит только для .odt) -->
			<!-- TODO: или же использовать @xlink:href, а точнее - только имя файла из него -->
			<xsl:attribute name="meta:date" select="
				format-dateTime(
					adjust-dateTime-to-timezone(
						xs:dateTime( fix:doc( resolve-uri(
							'../../../tmp/template/' || iri-to-uri( @xlink:title ) || '.ott' || '/meta.xml',
							base-uri()
						) )/office:document-meta/office:meta/dc:date ),
						xs:dayTimeDuration( 'PT0H' )
					),
					'[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01.000000000]'
				)
			"/>
		</xsl:copy>
	</xsl:template>

	<?endregion внедрение шаблона документа в документ (`meta:template`) #75 ?>
	<?region удаление внедрённых шрифтов в случае запрета внедрения в настройках документа #90 ?>

	<xsl:mode name="p:embedded-fonts-removing"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:template match=" /manifest:manifest/manifest:file-entry[ starts-with( @manifest:full-path, 'Fonts/' ) ] "
		mode="p:embedded-fonts-removing"
	/>

	<xsl:template match=" svg:font-face-src " mode="p:embedded-fonts-removing"/>

	<?endregion удаление внедрённых шрифтов в случае запрета внедрения в настройках документа #90 ?>

</xsl:package>
