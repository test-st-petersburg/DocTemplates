<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
	xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"
	xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
	xmlns:ooo="http://openoffice.org/2004/office"
	xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
	xmlns:xlink="http://www.w3.org/1999/xlink"
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
	xmlns:script-module="http://openoffice.org/2000/script"
	xmlns:dom="http://www.w3.org/2001/xml-events"
	xmlns:xforms="http://www.w3.org/2002/xforms"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:officeooo="http://openoffice.org/2009/office"
>
	<xsl:output
		method="xml"
		version="1.0"
		encoding="UTF-8"
		omit-xml-declaration="no"
		indent="yes"
		suppress-indentation="text:p text:h text:span text:variable-set text:table-of-content-entry-template script:module"
	/>

	<xsl:preserve-space elements="text:p text:h text:span text:variable-set text:table-of-content-entry-template script:module"/>

	<xsl:strip-space elements="*"/>

	<xsl:template match="processing-instruction()">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="element()">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="@*">
		<xsl:copy />
	</xsl:template>

	<xsl:template match="comment()">
		<xsl:copy/>
	</xsl:template>

	<xsl:template match="text()">
		<xsl:copy/>
	</xsl:template>

	<!-- удаляем автоматические стили символов -->

	<xsl:key name="auto-text-styles"
		match="office:automatic-styles/style:style[ @style:family='text' ]"
		use="@style:name"
	/>

	<xsl:template match="office:automatic-styles/style:style[ @style:family='text' ]" />

	<xsl:template match="text:span[ key( 'auto-text-styles', @text:style-name ) ]">
		<xsl:apply-templates select="node()" />
	</xsl:template>

	<!-- форматируем текст модулей -->

	<xsl:template match="script-module:module/text()">
		<xsl:variable name="module-text" select="." />
		<xsl:variable name="module-text">
			<!-- удаляем лишние пробелы в конце строк -->
			<xsl:analyze-string select="$module-text" regex="^(.*?)\s*$" flags="s">
				<xsl:matching-substring>
					<xsl:value-of select='regex-group(1)' />
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:variable>
		<xsl:variable name="module-text">
			<!-- удаляем лишние пустые строки в начале и конце модуля -->
			<xsl:analyze-string select="$module-text" regex="^\s*(.*?)\s*$" flags="ms">
				<xsl:matching-substring>
					<xsl:value-of select="'&#x0A;'" />
					<xsl:value-of select='regex-group(1)' />
					<xsl:value-of select="'&#x0A;'" />
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:variable>
		<xsl:value-of select="$module-text" />
	</xsl:template>

	<!-- удаляем лишние аттрибуты -->

	<xsl:template match="@style:language-asian" />
	<xsl:template match="@style:language-complex" />

	<xsl:template match="@style:country-asian" />
	<xsl:template match="@style:country-complex" />

	<xsl:template match="@style:font-name-asian" />
	<xsl:template match="@style:font-family-asian" />
	<xsl:template match="@style:font-pitch-asian" />
	<xsl:template match="@style:font-family-generic-asian" />
	<xsl:template match="@style:font-size-asian" />
	<xsl:template match="@style:font-weight-asian" />
	<xsl:template match="@style:font-style-asian" />

	<xsl:template match="@style:font-name-complex" />
	<xsl:template match="@style:font-family-complex" />
	<xsl:template match="@style:font-family-generic-complex" />
	<xsl:template match="@style:font-pitch-complex" />
	<xsl:template match="@style:font-size-complex" />
	<xsl:template match="@style:font-weight-complex" />
	<xsl:template match="@style:font-style-complex" />

	<xsl:template match="style:text-properties/@officeooo:paragraph-rsid" />
	<xsl:template match="style:text-properties/@officeooo:rsid" />

	<xsl:template match="office:automatic-styles/style:style/style:text-properties/@fo:language" />
	<xsl:template match="office:automatic-styles/style:style/style:text-properties/@fo:country" />

</xsl:stylesheet>
