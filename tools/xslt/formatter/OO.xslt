<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOFormatter"
	name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OO.xslt"
	package-version="1.5.0"
	input-type-annotations="preserve"
	declared-modes="yes"
	default-validation="preserve"
	expand-text="no"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:f="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"

	xmlns:calcext="urn:org:documentfoundation:names:experimental:calc:xmlns:calcext:1.0"
	xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
	xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
	xmlns:css3t="http://www.w3.org/TR/css3-text/"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dom="http://www.w3.org/2001/xml-events"
	xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
	xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
	xmlns:drawooo="http://openoffice.org/2010/draw"
	xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0"
	xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
	xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
	xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0"
	xmlns:grddl="http://www.w3.org/2003/g/data-view#"
	xmlns:loext="urn:org:documentfoundation:names:experimental:office:xmlns:loext:1.0"
	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
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
	xmlns:xforms="http://www.w3.org/2002/xforms"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
>

	<xsl:use-package name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/basic.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:outline" visibility="public"/>
		<xsl:accept component="mode" names="f:outline-child" visibility="public"/>
		<xsl:accept component="mode" names="f:outline-self" visibility="final"/>
		<xsl:accept component="mode" names="f:inline" visibility="public"/>
		<xsl:accept component="variable" names="indent-chars" visibility="public"/>
		<xsl:accept component="variable" names="indent-line" visibility="public"/>
		<xsl:override>

			<!-- правила для элементов, не подвергаемых форматированию -->

			<xsl:template mode="f:outline" match="
				text:p | text:h | text:span
				| text:table-of-content-entry-template | text:index-title-template
				| office:meta/*
				| dc:creator | dc:date
				| loext:sender-initials
				| text:variable-set | text:variable-get
				| script:module
				| config:config-item
			">
				<xsl:apply-templates select="." mode="f:inline"/>
			</xsl:template>

			<!-- правила для элементов, подвергаемых форматированию всегда -->

			<xsl:template mode="f:inline" match="
				office:annotation
				| draw:frame
			">
				<xsl:apply-templates select="." mode="f:outline"/>
			</xsl:template>

			<!-- правила для элементов с сортировкой потомков (для минимизации изменений при сохранении OO файлов) -->

			<xsl:template mode="f:outline-child" match="office:font-face-decls">
				<xsl:apply-templates select="style:font-face" mode="f:outline-self">
					<xsl:sort select="@style:name" data-type="text" order="ascending" case-order="upper-first" />
				</xsl:apply-templates>
			</xsl:template>

			<xsl:template mode="f:outline-child" match="/manifest:manifest">
				<xsl:apply-templates select="manifest:file-entry" mode="f:outline-self">
					<xsl:sort select="@manifest:full-path" data-type="text" order="ascending" case-order="upper-first" />
				</xsl:apply-templates>
			</xsl:template>

			<xsl:template mode="f:outline-child" match="text:variable-decls">
				<xsl:apply-templates select="text:variable-decl" mode="f:outline-self">
					<xsl:sort select="@text:name" data-type="text" order="ascending" case-order="upper-first" />
				</xsl:apply-templates>
			</xsl:template>

			<!-- форматирование текста модулей -->

			<!-- TODO: упростить, переписав на XQuery -->
			<xsl:template mode="f:inline f:outline" match="script-module:module/text()">
				<xsl:variable name="module-text-ph1" as="xs:string" select="." />
				<xsl:variable name="module-text-ph2" as="xs:string">
					<!-- удаляем лишние пробелы в конце строк -->
					<xsl:analyze-string select="$module-text-ph1" regex="^(.*?)\s*$" flags="s">
						<xsl:matching-substring>
							<xsl:value-of select='regex-group(1)' />
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:variable>
				<xsl:variable name="module-text-ph3" as="xs:string">
					<!-- удаляем лишние пустые строки в начале и конце модуля -->
					<xsl:analyze-string select="$module-text-ph2" regex="^\s*(.*?)\s*$" flags="ms">
						<xsl:matching-substring>
							<xsl:value-of select="concat( $indent-line, regex-group(1), $indent-line )" />
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:variable>
				<xsl:value-of select="$module-text-ph3" />
			</xsl:template>

		</xsl:override>
	</xsl:use-package>

</xsl:package>
