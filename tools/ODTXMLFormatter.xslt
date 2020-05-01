<?xml version="1.0" encoding="UTF-8"?><xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:array="http://www.w3.org/2005/xpath-functions/array"
	xmlns:saxon="http://saxon.sf.net/"

	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
	xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
	xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
	xmlns:ooo="http://openoffice.org/2004/office"
	xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
	xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
	xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
	xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
	xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
	xmlns:rpt="http://openoffice.org/2005/report"
	xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0"
	xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0"
	xmlns:ooow="http://openoffice.org/2004/writer"
	xmlns:oooc="http://openoffice.org/2004/calc"
	xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2"
	xmlns:css3t="http://www.w3.org/TR/css3-text/"
	xmlns:tableooo="http://openoffice.org/2009/table"
	xmlns:calcext="urn:org:documentfoundation:names:experimental:calc:xmlns:calcext:1.0"
	xmlns:drawooo="http://openoffice.org/2010/draw"
	xmlns:loext="urn:org:documentfoundation:names:experimental:office:xmlns:loext:1.0"
	xmlns:grddl="http://www.w3.org/2003/g/data-view#"
	xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
	xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
	xmlns:dom="http://www.w3.org/2001/xml-events"
	xmlns:xforms="http://www.w3.org/2002/xforms"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:officeooo="http://openoffice.org/2009/office"
	xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
>

	<xsl:mode
		name="#default"
		on-no-match="fail" warning-on-no-match="true"
		on-multiple-match="fail" warning-on-multiple-match="true"
		visibility="public"
		use-accumulators=""
	/>

	<xsl:mode
		name="inline"
		on-no-match="shallow-copy" warning-on-no-match="false"
		on-multiple-match="fail" warning-on-multiple-match="true"
		visibility="public"
		use-accumulators=""
	/>

	<xsl:mode
		name="outline"
		on-no-match="fail" warning-on-no-match="true"
		on-multiple-match="fail" warning-on-multiple-match="true"
		visibility="public"
		use-accumulators=""
	/>

	<!-- строки для форматирования -->
	<xsl:param name="indent-chars" as="xs:string" select="'&#x9;'" />
	<xsl:param name="indent-line" as="xs:string" select="'&#xa;'" />

	<!-- обработаем текст, в том числе - пробелы, используемые для форматирования -->

	<xsl:preserve-space elements="text:p text:span text:variable-set"/>
	<xsl:strip-space elements="*" />

	<!-- правила выше не работают для xsl:source-document -->

	<xsl:template mode="#all" match="text()[ not( matches( data(), '\S+' ) ) ]"/>

	<xsl:template mode="#all" match="text()">
		<xsl:copy />
	</xsl:template>

	<xsl:template mode="#all" match="(
		text:p | text:span | text:variable-set
	)/text()" priority="10">
		<xsl:copy/>
	</xsl:template>

	<!-- переводим обработку корня в режим outline -->

	<xsl:template match="/*">
		<xsl:param name="indent" as="xs:string" select="$indent-line" tunnel="yes"/>
		<xsl:apply-templates select="." mode="outline"/>
	</xsl:template>

	<!-- обработка в режиме outline -->

	<xsl:template mode="outline" match="processing-instruction() | comment()">
		<xsl:copy/>
	</xsl:template>

	<xsl:template mode="outline" match="@*">
		<xsl:copy />
	</xsl:template>

	<xsl:template mode="outline" match="element()">
		<xsl:param name="indent" as="xs:string" select="$indent-line" tunnel="yes"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="outline"/>
			<xsl:sequence>
				<xsl:for-each select="node()">
					<xsl:sequence>
						<xsl:on-non-empty select="concat( $indent, $indent-chars )"/>
						<xsl:apply-templates select="." mode="outline">
							<xsl:with-param name="indent" select="concat( $indent, $indent-chars )" tunnel="yes"/>
						</xsl:apply-templates>
					</xsl:sequence>
				</xsl:for-each>
				<xsl:on-non-empty select="$indent"/>
			</xsl:sequence>
		</xsl:copy>
	</xsl:template>

	<!-- правила для элементов, содержимое которых нельзя "форматировать" -->

	<xsl:template mode="outline" match="
		text:p | text:h | text:span | text:table-of-content-entry-template | text:index-title-template
		| config:config-item
		| office:meta/*
		| dc:creator | dc:date | loext:sender-initials
		| script:module
	">
		<xsl:apply-templates select="." mode="inline"/>
	</xsl:template>

	<xsl:template mode="inline" match="element()">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="inline"/>
			<xsl:apply-templates select="node()" mode="inline"/>
		</xsl:copy>
	</xsl:template>

	<!-- правило для элементов, которые следует всегда "форматировать" -->

	<xsl:template mode="inline" match="office:annotation | draw:frame">
		<xsl:apply-templates select="." mode="outline"/>
	</xsl:template>

</xsl:transform>
