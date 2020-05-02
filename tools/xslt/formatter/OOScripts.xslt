<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOScripts"
	name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/OOScripts.xslt"
	package-version="1.5.0"
	input-type-annotations="preserve"
	declared-modes="yes"
	default-validation="preserve"
	expand-text="no"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:f="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"

	xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0"
	xmlns:script-module="http://openoffice.org/2000/script"
>

	<xsl:use-package name="https://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/main.xslt" package-version="1.5">
		<xsl:accept component="mode" names="f:outline" visibility="public"/>
		<xsl:accept component="mode" names="f:inline" visibility="final"/>
		<xsl:accept component="mode" names="f:text" visibility="public"/>
		<xsl:override>

			<xsl:template mode="f:outline" match="script:module">
				<xsl:apply-templates select="." mode="f:inline"/>
			</xsl:template>

			<!-- форматируем текст модулей -->

			<!-- TODO: упростить, переписав на XQuery -->
			<xsl:template mode="f:text" match="script-module:module/text()">
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
