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

	<xsl:variable name="p:comment-preprocessing-results" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="p:update-document-meta" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="p:replace-section-source" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="p:rename-elements-on-insert" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="p:embed-linked-libraries" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="p:embed-linked-templates" as="xs:boolean" static="yes" select="true()" visibility="private"/>

	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- препроцессирование документа                                                              -->
	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:mode
		name="p:document-preprocessing"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<xsl:template mode="p:document-preprocessing" as="document-node( element( manifest:manifest ) )" match="/">
		<xsl:context-item use="required" as="document-node( element( manifest:manifest ) )"/>
		<xsl:param name="p:version" as="xs:string" required="no" select="''"/>
		<xsl:variable name="p:complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:copy-of select="."/>
		</xsl:variable>
		<xsl:variable name="p:complex-document-with-embedded-objects" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="$p:complex-document" mode="p:external-objects-embedding"/>
		</xsl:variable>
		<xsl:variable name="p:complex-document-with-expanded-links" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="$p:complex-document-with-embedded-objects" mode="p:internal-links-embedding"/>
		</xsl:variable>
		<xsl:variable name="p:updated-complex-document" as="document-node( element( manifest:manifest ) )">
			<xsl:apply-templates select="$p:complex-document-with-expanded-links" mode="p:document-meta-updating">
				<xsl:with-param name="p:version" select="$p:version" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:variable>
		<xsl:copy-of select="$p:updated-complex-document"/>
	</xsl:template>

	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- обновление метаданных документа (meta.xml) перед сборкой шаблонов документов и документов -->
	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:mode
		name="p:document-meta-updating"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:template mode="p:document-meta-updating"
		 use-when="$p:update-document-meta"
		 match=" office:document-meta/office:meta "
	>
		<xsl:param name="p:version" as="xs:string" required="no" select="''" tunnel="yes"/>
		<!-- TODO: вынести наименование свойства документа 'Версия шаблона' в локализуемые константы -->
		<xsl:param name="p:version-meta-name" as="xs:string" required="no" select="'Версия шаблона'" tunnel="yes"/>
		<!-- TODO: определиться с передачей p:generator-name -->
		<xsl:param name="p:generator-name" as="xs:string" required="no" tunnel="yes"
			select="'http://github.com/test-st-petersburg/DocTemplates/tools/Build-OODocument.ps1'"
		/>
		<xsl:copy validation="preserve">
			<xsl:apply-templates mode="#current" select="@*"/>
			<xsl:apply-templates mode="#current" select="
				node() except (
					meta:generator
					| dc:date
					| meta:user-defined[ @meta:name = $p:version-meta-name ]
				)
			"/>
			<xsl:element name="meta:generator" inherit-namespaces="no">
				<xsl:value-of select="$p:generator-name"/>
				<xsl:if test="$p:version">
					<xsl:value-of select="concat( '/', $p:version )"/>
				</xsl:if>
			</xsl:element>
			<xsl:element name="dc:date" inherit-namespaces="no">
				<xsl:value-of select="format-dateTime(
					adjust-dateTime-to-timezone( current-dateTime(), xs:dayTimeDuration( 'PT0H' ) ),
					'[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01.000000000]'
				)"/>
			</xsl:element>
			<xsl:if test="$p:version">
				<xsl:element name="meta:user-defined" inherit-namespaces="no">
					<xsl:attribute name="meta:name" select="$p:version-meta-name"/>
					<xsl:value-of select="$p:version"/>
				</xsl:element>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- препроцессирование документа                                                              -->
	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:mode
		name="p:internal-links-embedding"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<!-- замещение `<text:section-source>` содержанием разделов #81 -->

	<xsl:key name="p:sections" use-when="$p:replace-section-source"
		match="text:section"
		use="@text:name"
	/>

	<xsl:template mode="p:internal-links-embedding" use-when="$p:replace-section-source" match="
		text:section/text:section-source[
			@text:section-name and not( @xlink:href )
			and ( @xlink:type = 'simple' ) and ( @xlink:show = 'embed')
		]
	">
		<!-- TODO: localize messages: https://www.codeproject.com/Articles/338731/LocalizeXSLT -->
		<xsl:comment use-when="$p:comment-preprocessing-results" expand-text="yes">begin expanding `text:section-source` with @text:section-name="{ @text:section-name }"</xsl:comment>
		<!-- TODO: переделать параметр `p:embed-link-title` на аккумулятор -->
		<xsl:apply-templates select="key( 'p:sections', @text:section-name )/*" mode="#current">
			<xsl:with-param name="p:embed-link-title" select="@xlink:title" as="xs:string" tunnel="yes"/>
		</xsl:apply-templates>
		<!-- TODO: localize messages: https://www.codeproject.com/Articles/338731/LocalizeXSLT -->
		<xsl:comment use-when="$p:comment-preprocessing-results" expand-text="yes">end expanding `text:section-source` with @text:section-name="{ @text:section-name }"</xsl:comment>
	</xsl:template>

	<!--
		при подстановке элементов (например - вместо `text:section-source`) переименование вставляемых
		разделов, таблиц, врезок
		(с учётом реквизита `text:section-source/@xlink:title`) #81
	-->

	<xsl:template mode="p:internal-links-embedding" use-when="$p:rename-elements-on-insert" match="
		@table:name
	">
		<!-- TODO: переделать параметр `p:embed-link-title` на аккумулятор -->
		<xsl:param name="p:embed-link-title" as="xs:string" required="no" select="''" tunnel="yes"/>
		<xsl:choose>
			<xsl:when test="$p:embed-link-title">
				<xsl:attribute name="{ name() }" select="concat( data(), $p:embed-link-title )"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="p:internal-links-embedding" use-when="$p:rename-elements-on-insert" match="
		text:section/@text:name | @draw:name
	">
		<!-- TODO: переделать параметр `p:embed-link-title` на аккумулятор -->
		<xsl:param name="p:embed-link-title" as="xs:string" required="no" select="''" tunnel="yes"/>
		<xsl:choose>
			<xsl:when test="$p:embed-link-title">
				<xsl:attribute name="{ name() }" select="concat( data(), ' (', $p:embed-link-title, ')' )"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- удаление атрибутов препроцессора из документа #81 -->

	<xsl:template mode="p:internal-links-embedding" match="@*[
		namespace-uri() = 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor'
	]"/>

	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->
	<!-- внедрение дополнительных групп файлов с манифестами                                       -->
	<!-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ -->

	<xsl:mode
		name="p:external-objects-embedding"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:mode
		name="p:get-embed-objects-collection"
		on-no-match="shallow-skip" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:mode
		name="p:external-objects-links-replacing"
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
								<xsl:when test=" exists( current-merge-group( 'source-document' ) ) ">
									<xsl:copy-of select=" current-merge-group( 'source-document' ) "/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:assert test=" count( current-merge-group( 'embed-objects' ) ) = 1 " select="
										'More just one linked object can add same file: ' || current-merge-key() || '.'
									"/>
									<xsl:copy-of select=" current-merge-group( 'embed-objects' ) "/>
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

	<!-- внедрение связанных библиотек (`library:library[ @library:link = 'true' ]`) #83 -->

	<xsl:template mode="p:get-embed-objects-collection" as="document-node( element( manifest:manifest ) )"
		 use-when="$p:embed-linked-libraries"
		 match=" library:libraries/library:library[ @library:link = 'true' ] "
	>
		<xsl:assert test="exists( @library:name )" select=" 'Library name must be specified.' "/>
		<xsl:variable name="library:name" as="xs:string" select=" @library:name "/>
		<xsl:variable name="xlink:href" as="xs:anyURI">
			<xsl:choose>
				<xsl:when test="exists( @xlink:href )">
					<xsl:value-of select="@xlink:href"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- TODO: путь к собранным библиотекам макросов вынести в константы, а лучше - в параметры -->
					<xsl:value-of select=" resolve-uri(
						'../../../../output/basic/' || iri-to-uri( $library:name ) || '/' || $p:basic-script-lib-uri,
						base-uri()
					) "/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
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

	<!-- внедрение шаблона документа в документ (`meta:template`) #75 -->

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

</xsl:package>