<xsl:stylesheet version="1.0"
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
	xmlns:dom="http://www.w3.org/2001/xml-events"
	xmlns:xforms="http://www.w3.org/2002/xforms"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:officeooo="http://openoffice.org/2009/office"
>
	<xsl:output
		version="1.0"
		encoding="UTF-8"
		omit-xml-declaration="no"
		indent="no"
		method = "xml"
	/>

	<xsl:variable name="indent-chars" select="'&#x9;'" />

	<xsl:template match="processing-instruction()|comment()">
		<xsl:copy />
	</xsl:template>

	<xsl:template match="/*">
		<xsl:param name="indent" select="'&#xd;&#xa;'"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="indent">
				<xsl:with-param name="indent" select="concat($indent, $indent-chars)"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="node()|text()|processing-instruction()|comment()" mode="indent">
				<xsl:with-param name="indent" select="concat($indent, $indent-chars)"/>
			</xsl:apply-templates>
		<xsl:value-of select="$indent"/></xsl:copy>
	</xsl:template>

	<xsl:template match="node()|processing-instruction()|comment()" mode="indent">
		<xsl:param name="indent"/>
		<xsl:value-of select="$indent"/><xsl:copy>
			<xsl:apply-templates select="@*" mode="indent">
				<xsl:with-param name="indent" select="concat($indent, $indent-chars)"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="node()|text()|processing-instruction()|comment()" mode="indent">
				<xsl:with-param name="indent" select="concat($indent, $indent-chars)"/>
			</xsl:apply-templates>
			<xsl:if test="count(child::*) &gt; 0">
				<xsl:value-of select="$indent"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="node()|processing-instruction()|comment()" mode="noindent">
		<xsl:param name="indent"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="noindent">
				<xsl:with-param name="indent" select="concat($indent, $indent-chars)"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="node()|text()|processing-instruction()|comment()" mode="noindent">
				<xsl:with-param name="indent" select="concat($indent, $indent-chars)"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="node()|processing-instruction()|comment()" mode="noindent-descendant">
		<xsl:param name="indent"/>
		<xsl:value-of select="$indent"/><xsl:copy>
			<xsl:apply-templates select="@*" mode="noindent">
				<xsl:with-param name="indent" select="concat($indent, $indent-chars)"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="node()|text()|processing-instruction()|comment()" mode="noindent">
				<xsl:with-param name="indent" select="concat($indent, $indent-chars)"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="text:line-break" mode="indent">
		<xsl:param name="indent"/>
		<xsl:copy-of select="."/>
		<xsl:value-of select="$indent"/>
		<xsl:value-of select="$indent-chars"/>
	</xsl:template>

	<!-- правило для элементов, содержимое которых нельзя "форматировать" -->
	<xsl:template match="text:p|text:h|text:table-of-content-entry-template" mode="indent">
		<xsl:param name="indent"/>
		<xsl:apply-templates select="." mode="noindent-descendant">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="text:span" mode="indent">
		<xsl:param name="indent"/>
		<xsl:apply-templates select="." mode="noindent">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="/*/@*" mode="indent">
		<xsl:param name="indent"/>
		<!-- <xsl:value-of select="$indent"/> -->
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="@*" mode="indent">
		<xsl:param name="indent"/>
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="text()" mode="indent">
		<xsl:param name="indent"/>
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="@*" mode="noindent">
		<xsl:param name="indent"/>
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="text()" mode="noindent">
		<xsl:param name="indent"/>
		<xsl:copy-of select="."/>
	</xsl:template>

</xsl:stylesheet>
