<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="SystemUri"
	name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/system/uri.xslt"
	package-version="2.3.0"
	declared-modes="yes"
	expand-text="no"
	input-type-annotations="strip"
	default-validation="strip"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:err="http://www.w3.org/2005/xqt-errors"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"

	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:s="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/system"
>

	<!-- TODO: очень упрощенное regexp. Доработать, учесть punycode, параметры в url -->
	<xsl:variable name="s:file-uri-regexp" as="xs:string" static="yes" visibility="private" select="
		concat(
			'^((?:(?:file|https?|ftps?):/{1,3})?)',
			'((?:[A-Z]:/)?)',
			'((?:(?:[^/]+)/)*)',
			'([^/]+?)',
			'((?:\.[^/.]+)?)$'
		)
	"/>

	<xsl:function name="s:get-parent-directory-name" as="xs:string" visibility="final">
		<xsl:param name="s:uri" as="xs:anyURI"/>
		<xsl:value-of select="
			tokenize(
				data(
					analyze-string(
						resolve-uri( $s:uri ),
						$s:file-uri-regexp
					)/fn:match/fn:group[ @nr = '3' ]/text()
				),
				'/'
			)[ position() = last() - 1 ]
		"/>
	</xsl:function>

	<xsl:function name="s:get-file-name-without-extension" as="xs:string" visibility="final">
		<xsl:param name="s:uri" as="xs:anyURI"/>
		<xsl:value-of select="
			data(
				analyze-string(
					resolve-uri( $s:uri ),
					$s:file-uri-regexp
				)/fn:match/fn:group[ @nr = '4' ]/text()
			)
		"/>
	</xsl:function>

	<xsl:function name="s:get-relative-uri" as="xs:string" visibility="final">
		<xsl:param name="s:uri" as="xs:anyURI"/>
		<xsl:param name="s:base-uri" as="xs:anyURI"/>
		<!-- TODO: переработать код s:get-relative-uri -->
		<xsl:value-of select="
			substring-after(
				replace( resolve-uri( $s:uri ), '^(?:(?:\w{2,}):/{1,3})', '' ),
				replace( resolve-uri( $s:base-uri ), '^(?:(?:\w{2,}):/{1,3})', '' )
			)
		"/>
	</xsl:function>

</xsl:package>
