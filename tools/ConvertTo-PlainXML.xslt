<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:saxon="http://saxon.sf.net/"

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

	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
>
	<xsl:output
		method="xml"
		version="1.0"
		encoding="UTF-8"
		omit-xml-declaration="no"
		indent="yes"
		suppress-indentation="text:p text:h text:table-of-content-entry-template text:span script:module"
	/>

	<!-- строки для форматирования -->
	<xsl:variable name="indent-chars" select="'&#x9;'" />
	<!-- применимо для dotNet XslTransformer -->
	<!-- <xsl:variable name="indent-line" select="'&#xd;&#xa;'" /> -->
	<xsl:variable name="indent-line" select="'&#xa;'" />

	<!-- правило для элементов, подвергаемых форматированию -->
	<xsl:template name="indent-self">
		<xsl:param name="indent" select="$indent-line"/>
		<xsl:copy>
			<xsl:apply-templates select="attribute::*" mode="indent">
				<xsl:with-param name="indent" select="concat($indent, $indent-chars)"/>
			</xsl:apply-templates>
			<xsl:for-each select="node()|text()|processing-instruction()|comment()">
				<xsl:apply-templates select="." mode="preindent">
					<xsl:with-param name="indent" select="concat($indent, $indent-chars)"/>
				</xsl:apply-templates>
			</xsl:for-each>
			<xsl:if test="child::*">
				<xsl:value-of select="$indent"/>
			</xsl:if>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="node()|processing-instruction()|comment()" mode="preindent">
		<xsl:param name="indent" select="$indent-line"/>
		<xsl:value-of select="$indent"/>
		<xsl:apply-templates select="." mode="indent">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="text()" mode="preindent">
		<xsl:param name="indent"/>
		<xsl:copy />
	</xsl:template>

	<!-- правило для элементов, не подвергаемых форматированию -->
	<xsl:template name="noindent-self">
		<xsl:param name="indent" select="$indent-line"/>
		<xsl:copy>
			<xsl:apply-templates select="attribute::*" mode="indent">
				<xsl:with-param name="indent" select="$indent"/>
			</xsl:apply-templates>
			<xsl:apply-templates select="node()|text()|processing-instruction()|comment()" mode="noindent">
				<xsl:with-param name="indent" select="$indent"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<!-- обработка элементов -->

	<xsl:template match="processing-instruction()" mode="indent">
		<xsl:copy />
	</xsl:template>

	<xsl:template match="processing-instruction()" mode="noindent">
		<xsl:copy />
	</xsl:template>

	<xsl:template match="comment()" mode="indent">
		<xsl:copy />
	</xsl:template>

	<xsl:template match="comment()" mode="noindent">
		<xsl:copy />
	</xsl:template>


	<xsl:template match="node()">
		<xsl:param name="indent" select="$indent-line"/>
		<xsl:call-template name="indent-self">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="node()" mode="indent">
		<xsl:param name="indent" select="$indent-line"/>
		<xsl:call-template name="indent-self">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="node()" mode="noindent">
		<xsl:param name="indent" select="$indent-line"/>
		<xsl:call-template name="noindent-self">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
	</xsl:template>

	<!-- правила для элементов, содержимое которых нельзя "форматировать" -->

	<xsl:template match="text:p" mode="indent">
		<xsl:param name="indent"/>
		<xsl:call-template name="noindent-self">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="text:h" mode="indent">
		<xsl:param name="indent"/>
		<xsl:call-template name="noindent-self">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="text:table-of-content-entry-template" mode="indent">
		<xsl:param name="indent"/>
		<xsl:call-template name="noindent-self">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="text:span" mode="indent">
		<xsl:param name="indent"/>
		<xsl:call-template name="noindent-self">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="script:module" mode="indent">
		<xsl:param name="indent"/>
		<xsl:call-template name="noindent-self">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
	</xsl:template>

	<!-- правило для элементов, которые следует всегда "форматировать" -->

	<xsl:template match="office:annotation" mode="noindent">
		<xsl:param name="indent"/>
		<xsl:call-template name="indent-self">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="draw:frame" mode="noindent">
		<xsl:param name="indent"/>
		<xsl:call-template name="indent-self">
			<xsl:with-param name="indent" select="$indent"/>
		</xsl:call-template>
	</xsl:template>

	<!-- правила для обработки "особых" элементов -->

	<xsl:template match="/manifest:manifest">
		<xsl:param name="indent" select="$indent-line"/>
		<xsl:copy>
			<xsl:apply-templates select="attribute::*" mode="indent">
				<xsl:with-param name="indent" select="concat($indent, $indent-chars)"/>
			</xsl:apply-templates>
			<xsl:for-each select="manifest:file-entry">
				<xsl:sort select="@manifest:full-path" data-type="text" order="ascending" case-order="upper-first" />
				<xsl:apply-templates select="." mode="preindent">
					<xsl:with-param name="indent" select="concat($indent, $indent-chars)"/>
				</xsl:apply-templates>
			</xsl:for-each>
			<xsl:value-of select="$indent"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="office:font-face-decls" mode="indent">
		<xsl:param name="indent" select="$indent-line"/>
		<xsl:copy>
			<xsl:apply-templates select="attribute::*" mode="indent">
				<xsl:with-param name="indent" select="concat($indent, $indent-chars)"/>
			</xsl:apply-templates>
			<xsl:for-each select="style:font-face">
				<xsl:sort select="@style:name" data-type="text" order="ascending" case-order="upper-first" />
				<xsl:apply-templates select="." mode="preindent">
					<xsl:with-param name="indent" select="concat($indent, $indent-chars)"/>
				</xsl:apply-templates>
			</xsl:for-each>
			<xsl:value-of select="$indent"/>
		</xsl:copy>
	</xsl:template>

	<!-- правила для атрибутов -->

	<xsl:template match="attribute::*" mode="indent">
		<xsl:param name="indent"/>
		<xsl:copy />
	</xsl:template>

	<xsl:template match="attribute::*" mode="noindent">
		<xsl:param name="indent"/>
		<xsl:copy />
	</xsl:template>

	<!-- правила для обработки text() -->

	<xsl:preserve-space elements="text:p text:span text:variable-set"/>
	<xsl:strip-space elements="*" />

	<xsl:template match="text()" mode="indent">
		<xsl:param name="indent"/>
		<xsl:copy />
	</xsl:template>

	<xsl:template match="text()" mode="noindent">
		<xsl:param name="indent"/>
		<xsl:copy />
	</xsl:template>

</xsl:stylesheet>
