<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOPreprocessor"
	name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor/oo-preprocessor.xslt"
	package-version="2.2.0"
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
>

	<xsl:variable name="p:comment-preprocessing-results" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="p:update-document-meta" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="p:update-document-date" as="xs:boolean" static="yes" select="$p:update-document-meta" visibility="private"/>
	<xsl:variable name="p:update-document-editing-cycles" as="xs:boolean" static="yes" select="$p:update-document-meta" visibility="private"/>
	<xsl:variable name="p:update-document-version" as="xs:boolean" static="yes" select="$p:update-document-meta" visibility="private"/>
	<xsl:variable name="p:replace-section-source" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="p:rename-elements-on-insert" as="xs:boolean" static="yes" select="true()" visibility="private"/>

	<!-- обновление метаданных документа (meta.xml) перед сборкой шаблонов документов и документов -->
	<xsl:mode
		name="p:update-document-meta"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<!--
		Препроцессирование документа:
		- включение содержания разделов вместо `<text:section-source>`
		  #81
	-->
	<xsl:mode
		name="p:preprocess-document"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<!-- обновление метаданных документа (meta.xml) перед сборкой шаблонов документов и документов -->

	<xsl:template mode="p:update-document-meta" use-when="$p:update-document-date" match="
		office:document-meta/office:meta/dc:date
	">
		<xsl:copy>
			<xsl:value-of select="format-dateTime(
				adjust-dateTime-to-timezone( current-dateTime(), xs:dayTimeDuration( 'PT0H' ) ),
				'[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01.000000000]'
			)"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template mode="p:update-document-meta" use-when="$p:update-document-editing-cycles" match="
		office:document-meta/office:meta/meta:editing-cycles
	">
		<xsl:copy>
			<xsl:value-of select="xs:int( text() ) + 1"/>
		</xsl:copy>
	</xsl:template>

	<!-- обновление / установка версии документа -->

	<xsl:template mode="p:update-document-meta" use-when="$p:update-document-version" match="
		office:document-meta/office:meta
	">
		<xsl:param name="p:version" as="xs:string" required="no" select="''" tunnel="yes"/>
		<!-- TODO: вынести наименование свойства документа 'Версия шаблона' в локализуемые константы -->
		<xsl:param name="p:version-meta-name" as="xs:string" required="no" select="'Версия шаблона'" tunnel="yes"/>
		<xsl:copy validation="preserve">
			<xsl:apply-templates mode="#current" select="@*"/>
			<xsl:apply-templates mode="#current" select="node() except meta:user-defined[ @meta:name = $p:version-meta-name ]"/>
			<xsl:if test="$p:version">
				<xsl:element name="meta:user-defined" inherit-namespaces="no">
					<xsl:attribute name="meta:name" select="$p:version-meta-name"/>
					<xsl:value-of select="$p:version"/>
				</xsl:element>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<!-- препроцессирование документа -->

	<!-- замещение `<text:section-source>` содержанием разделов #81 -->

	<xsl:key name="p:sections" use-when="$p:replace-section-source"
		match="text:section"
		use="@text:name"
	/>

	<xsl:template mode="p:preprocess-document" use-when="$p:replace-section-source" match="
		text:section/text:section-source[
			@text:section-name and not( @xlink:href )
			and ( @xlink:type = 'simple' ) and ( @xlink:show = 'embed')
		]
	">
		<!-- TODO: localize messages: https://www.codeproject.com/Articles/338731/LocalizeXSLT -->
		<xsl:comment use-when="$p:comment-preprocessing-results" expand-text="yes">begin expanding `text:section-source` with @text:section-name="{ @text:section-name }"</xsl:comment>
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

	<xsl:template mode="p:preprocess-document" use-when="$p:rename-elements-on-insert" match="
		@table:name
	">
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

	<xsl:template mode="p:preprocess-document" use-when="$p:rename-elements-on-insert" match="
		text:section/@text:name | @draw:name
	">
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

	<xsl:template mode="p:preprocess-document" match="@*[
		namespace-uri() = 'http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor'
	]"/>

</xsl:package>
