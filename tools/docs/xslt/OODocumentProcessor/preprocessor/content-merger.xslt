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

	<xsl:template match="office:document-content"
		mode="p:external-objects-files-content-merging"
	>
		<xsl:param name="p:embed-objects" as=" element( manifest:file-entry )* " required="yes" tunnel="yes"/>
		<xsl:copy>
			<xsl:copy-of select="@*"/>

			<xsl:element name="office:scripts" inherit-namespaces="no">
				<xsl:element name="office:event-listeners" inherit-namespaces="no">
					<xsl:merge>
						<xsl:merge-source name="source-document" for-each-item=" office:scripts/office:event-listeners "
							select=" script:event-listener "
							sort-before-merge="yes"
						>
							<xsl:merge-key select=" @script:event-name " order="ascending"/>
						</xsl:merge-source>
						<xsl:merge-source name="embed-objects" for-each-item=" $p:embed-objects ! office:document-content/office:scripts/office:event-listeners "
							select=" script:event-listener "
							sort-before-merge="yes"
						>
							<xsl:merge-key select=" @script:event-name " order="ascending"/>
						</xsl:merge-source>
						<xsl:merge-action>
							<xsl:copy-of select=" head( current-merge-group() ) "/>
						</xsl:merge-action>
					</xsl:merge>
				</xsl:element>
			</xsl:element>

			<xsl:element name="office:font-face-decls" inherit-namespaces="no">
				<xsl:merge>
					<xsl:merge-source
						for-each-item="
							$p:embed-objects!office:document-content/office:font-face-decls,
							office:font-face-decls
						"
						select=" style:font-face "
						sort-before-merge="yes"
					>
						<xsl:merge-key select=" @style:name " order="ascending"/>
					</xsl:merge-source>
					<xsl:merge-action>
						<xsl:copy-of select=" head( current-merge-group() ) "/>
					</xsl:merge-action>
				</xsl:merge>
			</xsl:element>

			<xsl:element name="office:automatic-styles" inherit-namespaces="no">
				<xsl:merge>
					<xsl:merge-source
						for-each-item="
							$p:embed-objects!office:document-content/office:automatic-styles,
							office:automatic-styles
						"
						select=" style:style "
						sort-before-merge="yes"
					>
						<xsl:merge-key select=" @style:name " order="ascending"/>
					</xsl:merge-source>
					<xsl:merge-action>
						<xsl:copy-of select=" head( current-merge-group() ) "/>
					</xsl:merge-action>
				</xsl:merge>
			</xsl:element>

			<xsl:apply-templates mode="#current" select=" * except ( office:scripts, office:font-face-decls, office:automatic-styles ) "/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="office:document-content/office:body/office:text"
		mode="p:external-objects-files-content-merging"
	>
		<xsl:param name="p:embed-objects" as=" element( manifest:file-entry )* " required="yes" tunnel="yes"/>
		<xsl:copy>
			<xsl:apply-templates mode="#current" select=" office:forms "/>

			<xsl:element name="text:variable-decls" inherit-namespaces="no">
				<xsl:merge>
					<xsl:merge-source
						for-each-item="
							$p:embed-objects!office:document-content/office:body/office:text/text:variable-decls,
							text:variable-decls
						"
						select=" text:variable-decl "
						sort-before-merge="yes"
					>
						<xsl:merge-key select=" @text:name " order="ascending"/>
					</xsl:merge-source>
					<xsl:merge-action>
						<xsl:copy-of select=" head( current-merge-group() ) "/>
					</xsl:merge-action>
				</xsl:merge>
			</xsl:element>

			<xsl:element name="text:sequence-decls" inherit-namespaces="no">
				<xsl:merge>
					<xsl:merge-source
						for-each-item="
							$p:embed-objects!office:document-content/office:body/office:text/text:sequence-decls,
							text:sequence-decls
						"
						select=" text:sequence-decl "
						sort-before-merge="yes"
					>
						<xsl:merge-key select=" @text:name " order="ascending"/>
					</xsl:merge-source>
					<xsl:merge-action>
						<xsl:copy-of select=" head( current-merge-group() ) "/>
					</xsl:merge-action>
				</xsl:merge>
			</xsl:element>

			<xsl:element name="text:section" inherit-namespaces="no">
				<xsl:attribute name="text:name" select=" 'Служебный' "/>
				<xsl:attribute name="text:display" select="
					if ( exists( text:section[ @text:name = 'Служебный' ][ 1 ]/@text:display ) )
						then text:section[ @text:name = 'Служебный' ][ 1 ]/@text:display
						else 'none'
				"/>
				<xsl:copy-of select="
					text:section[ @text:name = 'Служебный' ][ 1 ]/@* except (
						text:section[ @text:name = 'Служебный' ][ 1 ]/@text:name,
						text:section[ @text:name = 'Служебный' ][ 1 ]/@text:display
					)
				"/>
				<xsl:element name="text:p" inherit-namespaces="no">
					<xsl:attribute name="text:style-name" select=" 'НачалоСлужебнойСтраницы' "/>
				</xsl:element>
				<xsl:merge>
					<xsl:merge-source
						for-each-item="
							text:section[ @text:name = 'Служебный' ][ 1 ],
							$p:embed-objects!office:document-content/office:body/office:text/text:section[ @text:name = 'Служебный' ][ 1 ]
						"
						select=" //text:variable-set "
						sort-before-merge="yes"
					>
						<xsl:merge-key select=" @text:name " order="ascending"/>
					</xsl:merge-source>
					<xsl:merge-action>
						<xsl:element name="text:p" inherit-namespaces="no">
							<xsl:attribute name="text:style-name" select=" 'Preformatted_20_Text' "/>
							<xsl:copy-of select=" head( current-merge-group() ) "/>
						</xsl:element>
					</xsl:merge-action>
				</xsl:merge>
				<xsl:element name="text:p" inherit-namespaces="no">
					<xsl:attribute name="text:style-name" select=" 'Preformatted_20_Text' "/>
				</xsl:element>
			</xsl:element>

			<xsl:apply-templates mode="#current" select=" * except (
				office:forms,
				text:variable-decls,
				text:sequence-decls,
				text:section[ @text:name = 'Служебный' ][ 1 ],
				text:section[ @text:name = 'РазделяемыеКомпоненты' ]
			)"/>

			<xsl:element name="text:section" inherit-namespaces="no">
				<xsl:attribute name="text:name" select=" 'РазделяемыеКомпоненты' "/>
				<xsl:attribute name="text:display" select=" 'none' "/>
				<xsl:attribute name="text:protected" select=" true() "/>

				<xsl:element name="text:p" inherit-namespaces="no">
					<xsl:attribute name="text:style-name" select=" 'НачалоСлужебнойСтраницы' "/>
				</xsl:element>
				<xsl:merge>
					<xsl:merge-source
						for-each-item="
							text:section[ @text:name = 'РазделяемыеКомпоненты' ],
							$p:embed-objects!office:document-content/office:body/office:text/text:section[ @text:name = 'РазделяемыеКомпоненты' ]
						"
						select=" text:section "
						sort-before-merge="yes"
					>
						<xsl:merge-key select=" @text:name " order="ascending"/>
					</xsl:merge-source>
					<xsl:merge-action>
						<xsl:copy-of select=" head( current-merge-group() ) "/>
					</xsl:merge-action>
				</xsl:merge>
				<xsl:element name="text:p" inherit-namespaces="no">
					<xsl:attribute name="text:style-name" select=" 'ПустойАбзац' "/>
				</xsl:element>
			</xsl:element>

		</xsl:copy>
	</xsl:template>

</xsl:transform>
