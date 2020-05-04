<?xml version="1.0" encoding="UTF-8"?><xsl:transform version="3.0"
	default-validation="preserve"
	expand-text="no"

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
	xmlns:script-module="http://openoffice.org/2000/script"
	xmlns:dom="http://www.w3.org/2001/xml-events"
	xmlns:xforms="http://www.w3.org/2002/xforms"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:officeooo="http://openoffice.org/2009/office"
	xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"

	xmlns:f="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"
>

	<xsl:param name="base-uri" as="xs:anyURI"/>

	<xsl:template name="optimize">
		<xsl:source-document href="{ iri-to-uri($base-uri) }META-INF/manifest.xml"
			streamable="no" use-accumulators="" validation="preserve"
		>
			<xsl:apply-templates select="/manifest:manifest/manifest:file-entry" mode="optimize-file"/>
		</xsl:source-document>
	</xsl:template>

	<xsl:template mode="optimize-file" match="/manifest:manifest/manifest:file-entry[
		( @manifest:media-type='text/xml' )
		or ( @manifest:media-type='' and ends-with( @manifest:full-path, '.xml' ) )
	]">
		<xsl:variable name="file-full-path" select="data( @manifest:full-path )"/>
		<xsl:try rollback-output="yes">
			<xsl:source-document href="{ concat( iri-to-uri($base-uri), $file-full-path ) }"
				streamable="no" use-accumulators="#all" validation="preserve"
			>
				<xsl:result-document href="{ $file-full-path }" format="OOXmlFile" validation="preserve">
					<xsl:apply-templates select="/" mode="f:outline"/>
				</xsl:result-document>
			</xsl:source-document>
			<xsl:catch errors="*"/>
		</xsl:try>
	</xsl:template>

	<xsl:template mode="optimize-file" match="/manifest:manifest/manifest:file-entry[
		@manifest:media-type='application/rdf+xml'
	]">
		<xsl:variable name="file-full-path" select="data( @manifest:full-path )"/>
		<xsl:try rollback-output="yes">
			<xsl:source-document href="{ concat( iri-to-uri($base-uri), $file-full-path ) }"
				streamable="no" use-accumulators="" validation="preserve"
			>
				<xsl:result-document href="{ $file-full-path }" format="OORdfFile" validation="preserve">
					<xsl:apply-templates select="/" mode="f:outline"/>
				</xsl:result-document>
			</xsl:source-document>
			<xsl:catch errors="*"/>
		</xsl:try>
	</xsl:template>

	<xsl:output name="OOXmlFile"
		media-type="text/xml"
		method="xml" omit-xml-declaration="no" version="1.0" standalone="omit"
		encoding="UTF-8" byte-order-mark="no"
		indent="no"
	/>
	<xsl:output name="OORdfFile"
		media-type="application/rdf+xml"
		method="xml" omit-xml-declaration="no" version="1.0" standalone="omit"
		encoding="UTF-8" byte-order-mark="no"
		indent="no"
	/>

	<xsl:preserve-space elements="text:p text:span text:variable-set"/>
	<xsl:strip-space elements="*"/>

	<xsl:include href="Optimize-PlainXML.xslt" />
	<xsl:include href="ODTXMLFormatter2.xslt" />

</xsl:transform>
