<?xml version="1.0" encoding="UTF-8"?><xsl:transform version="3.0"
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

	<xsl:param name="p:update-document-meta" as="xs:boolean" static="yes" select="true()"/>

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

</xsl:transform>
