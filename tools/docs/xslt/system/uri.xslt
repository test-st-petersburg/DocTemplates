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

	xmlns:u="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/system/uri"
	xmlns:ur="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/system/uri/regexps"
>

	<!-- https://saxonica.com/html/documentation/xsl-elements/analyze-string.html -->

	<!-- https://tools.ietf.org/html/rfc3986 -->
	<!-- https://tools.ietf.org/html/rfc3986#appendix-B -->

	<!-- https://tools.ietf.org/html/rfc3986#section-2 -->
	<xsl:variable name="ur:HEXDIG" as="xs:string" static="yes" visibility="private" select=" '[a-fA-F\d]' "/>
	<xsl:variable name="ur:ALPHA" as="xs:string" static="yes" visibility="private" select=" '[a-zA-Z]' "/>
	<xsl:variable name="ur:DIGIT" as="xs:string" static="yes" visibility="private" select=" '\d' "/>

	<!-- TODO: разобраться с экранированием указанных символов в регулярных выражениях. Не уверен, что работает -->
	<xsl:variable name="ur:AMP" as="xs:string" static="yes" visibility="private" select=" '&amp;' "/>
	<xsl:variable name="ur:APOS" as="xs:string" static="yes" visibility="private" select=" '&amp;apos;' "/>

	<!-- https://tools.ietf.org/html/rfc3986#section-2.1 -->
	<xsl:variable name="ur:pct-encoded" as="xs:string" static="yes" visibility="private" select=" '(?:%' || $ur:HEXDIG || '{2})' "/>

	<!-- https://tools.ietf.org/html/rfc3986#section-2.2 -->
	<xsl:variable name="ur:gen-delims" as="xs:string" static="yes" visibility="private" select=" '[:/?#\[\]@]' "/>
	<xsl:variable name="ur:sub-delims" as="xs:string" static="yes" visibility="private" select=" '[!\$' || $ur:AMP || $ur:APOS || '\(\)*+,;=]' "/>
	<xsl:variable name="ur:reserved" as="xs:string" static="yes" visibility="private" select="
		$ur:gen-delims || '|' || $ur:sub-delims
	"/>

	<!-- https://tools.ietf.org/html/rfc3986#section-2.2 -->
	<xsl:variable name="ur:unreserved" as="xs:string" static="yes" visibility="private" select="
		'(?:' || $ur:ALPHA || '|' || $ur:DIGIT || '|' || '[\-\._~]' || ')'
	"/>

	<!-- https://tools.ietf.org/html/rfc3986#section-3.1 -->
	<xsl:variable name="ur:scheme" as="xs:string" static="yes" visibility="private" select="
		'(?:' || $ur:ALPHA || '(?:' || $ur:ALPHA || '|' || $ur:DIGIT || '|' || '[\+\-\.]' || ')*)'
	"/>

	<!-- https://tools.ietf.org/html/rfc3986#section-3.2.1 -->
	<xsl:variable name="ur:userinfo" as="xs:string" static="yes" visibility="private" select="
		'(?:(?:' || $ur:unreserved || '|' || $ur:pct-encoded || '|' || $ur:sub-delims || '|' || '[:]' || ')*)'
	"/>

	<!-- https://tools.ietf.org/html/rfc3986#section-3.2.2 -->
	<!-- TODO: IPv6address / IPvFuture / IPv4address -->
	<xsl:variable name="ur:reg-name" as="xs:string" static="yes" visibility="private" select="
		'(?:(?:' || $ur:unreserved || '|' || $ur:pct-encoded || '|' || $ur:sub-delims || ')*)'
	"/>
	<xsl:variable name="ur:host" as="xs:string" static="yes" visibility="private" select=" '(?:' || $ur:reg-name || ')' "/>

	<!-- https://tools.ietf.org/html/rfc3986#section-3.2.3 -->
	<xsl:variable name="ur:port" as="xs:string" static="yes" visibility="private" select=" '(?:' || $ur:DIGIT || '*)' "/>

	<!-- https://tools.ietf.org/html/rfc3986#section-3.2 -->
	<xsl:variable name="ur:authority" as="xs:string" static="yes" visibility="private" select="
		'(?:'
			|| '(?:' || $ur:userinfo || '|' || '[@]' || ')?'
			|| $ur:host
			|| '(?:' || '[:]' || $ur:port || ')?'
		|| ')'
	"/>

	<!-- https://tools.ietf.org/html/rfc3986#section-3.3 -->
	<xsl:variable name="ur:pchar" as="xs:string" static="yes" visibility="private" select="
		'(?:' || $ur:unreserved || '|' || $ur:pct-encoded || '|' || $ur:sub-delims || '|' || '[:@]' || ')'
	"/>
	<xsl:variable name="ur:segment-nz-nc" as="xs:string" static="yes" visibility="private" select="
		'(?:(?:' || $ur:unreserved || '|' || $ur:pct-encoded || '|' || $ur:sub-delims || '|' || '[@]' || ')+)'
	"/>
	<xsl:variable name="ur:segment-nz" as="xs:string" static="yes" visibility="private" select=" '(?:' || $ur:pchar || '+)' "/>
	<xsl:variable name="ur:segment" as="xs:string" static="yes" visibility="private" select=" '(?:' || $ur:pchar || '*)' "/>
	<xsl:variable name="ur:path-rootless" as="xs:string" static="yes" visibility="private" select="
		'(?:'
		|| $ur:segment-nz
		|| '(?:' || '[/]' || $ur:segment || ')*'
		|| ')'
	"/>
	<xsl:variable name="ur:path-noscheme" as="xs:string" static="yes" visibility="private" select="
		'(?:'
		|| $ur:segment-nz-nc
		|| '(?:' || '[/]' || $ur:segment || ')*'
		|| ')'
	"/>
	<xsl:variable name="ur:path-absolute" as="xs:string" static="yes" visibility="private" select="
		'(?:' || '[/]' || $ur:path-rootless || '?' || ')'
	"/>
	<xsl:variable name="ur:path-abempty" as="xs:string" static="yes" visibility="private" select="
		'(?:' || '[/]' || $ur:segment || '*' || ')'
	"/>
	<xsl:variable name="ur:path-empty" as="xs:string" static="yes" visibility="private" select=" '(?:)' "/>
	<xsl:variable name="ur:path" as="xs:string" static="yes" visibility="private" select="
		'(?:'
			|| $ur:path-abempty
			|| '|' || $ur:path-absolute
			|| '|' || $ur:path-noscheme
			|| '|' || $ur:path-rootless
			|| '|' || $ur:path-empty
		|| ')'
	"/>

	<!-- https://tools.ietf.org/html/rfc3986#section-3.4 -->
	<xsl:variable name="ur:query" as="xs:string" static="yes" visibility="private" select="
		'(?:(?:' || $ur:pchar || '|' || '[/?]' || ')*)'
	"/>

	<!-- https://tools.ietf.org/html/rfc3986#section-3.5 -->
	<xsl:variable name="ur:fragment" as="xs:string" static="yes" visibility="private" select="
		'(?:(?:' || $ur:pchar || '|' || '[/?]' || ')*)'
	"/>

	<!-- https://tools.ietf.org/html/rfc3986#section-3 -->
	<xsl:variable name="ur:hier-part" as="xs:string" static="yes" visibility="private" select="
		'(?:'
		|| '//' || $ur:authority
		|| '(?:'
			||  $ur:path-abempty
			|| '|' || $ur:path-absolute
			|| '|' || $ur:path-rootless
			|| '|' || $ur:path-empty
			|| ')'
		|| ')'
	"/>
	<xsl:variable name="ur:URI" as="xs:string" static="yes" visibility="private" select="
		'^'
		|| '(' || $ur:scheme || ')' || '[:]'
		|| '//' || '(' || $ur:authority || ')'
		|| '('
			||  $ur:path-abempty
			|| '|' || $ur:path-absolute
			|| '|' || $ur:path-rootless
			|| '|' || $ur:path-empty
			|| ')'
		|| '(' || '(?:' || '[?]' || $ur:query || ')?' || ')'
		|| '(' || '(?:' || '[#]' || $ur:fragment || ')?' || ')'
		|| '$'
	"/>
	<!--
		'^'
		|| '(' || $ur:scheme || ')' || '[:]'
		|| '(' || $ur:hier-part || ')'
		|| '(' || '(?:' || '[?]' || $ur:query || ')?' || ')'
		|| '(' || '(?:' || '[#]' || $ur:fragment || ')?' || ')'
		|| '$'
 	-->

	<!-- https://tools.ietf.org/html/rfc3986#section-4.1 -->
	<!-- https://tools.ietf.org/html/rfc3986#section-4.2 -->
	<!-- TODO: URI Reference -->

	<!-- https://tools.ietf.org/html/rfc3986#section-4.3 -->
	<xsl:variable name="ur:absolute-URI" as="xs:string" static="yes" visibility="private" select="
		'^'
		|| '(' || $ur:scheme || ')' || '[:]'
		|| '//' || '(' || $ur:authority || ')'
		|| '('
			||  $ur:path-abempty
			|| '|' || $ur:path-absolute
			|| '|' || $ur:path-rootless
			|| '|' || $ur:path-empty
			|| ')'
		|| '(' || '(?:' || '[?]' || $ur:query || ')?' || ')'
		|| '$'
	"/>
	<!--
		'^'
		|| '(' || $ur:scheme || ')' || '[:]'
		|| '(' || $ur:hier-part || ')'
		|| '(' || '(?:' || '[?]' || $ur:query || ')?' || ')'
		|| '$'
	-->

	<xsl:function name="u:fix-uri" as="xs:anyURI" visibility="final">
		<!-- fix file:/ uri (to RFC 3986 file:///) -->
		<xsl:param name="u:uri" as="xs:anyURI"/>
		<xsl:sequence select=" xs:anyURI( replace( $u:uri, '^file:/([^/])', 'file:///$1' ) ) "/>
	</xsl:function>

	<xsl:function name="u:get-scheme" as="xs:string" visibility="final">
		<xsl:param name="u:uri" as="xs:anyURI"/>
		<xsl:sequence select="
			analyze-string(
				u:fix-uri( resolve-uri( $u:uri ) ),
				$ur:absolute-URI
			)/fn:match/fn:group[ @nr = 1 ]/text()/string()
		"/>
	</xsl:function>

	<xsl:function name="u:get-authority" as="xs:string?" visibility="final">
		<xsl:param name="u:uri" as="xs:anyURI"/>
		<xsl:sequence select="
			analyze-string(
				u:fix-uri( resolve-uri( $u:uri ) ),
				$ur:absolute-URI
			)/fn:match/fn:group[ @nr = 2 ]/text()/string()
		"/>
	</xsl:function>

	<xsl:function name="u:get-fragment" as="xs:string?" visibility="final">
		<xsl:param name="u:uri" as="xs:anyURI"/>
		<xsl:value-of select="
			analyze-string(
				u:fix-uri( $u:uri ),
				$ur:URI
			)/fn:match/fn:group[ @nr = 5 ]/text()/string()
		"/>
	</xsl:function>

	<xsl:function name="u:get-query" as="xs:string?" visibility="final">
		<xsl:param name="u:uri" as="xs:anyURI"/>
		<xsl:value-of select="
			analyze-string(
				u:fix-uri( $u:uri ),
				$ur:URI
			)/fn:match/fn:group[ @nr = 4 ]/text()/string()
		"/>
	</xsl:function>

	<xsl:function name="u:get-segments" as="xs:string*" visibility="final">
		<!--
			https://docs.microsoft.com/en-us/dotnet/api/system.uri.segments?view=netframework-4.8#System_Uri_Segments
			but without '/'
		-->
		<xsl:param name="u:uri" as="xs:anyURI"/>
		<xsl:sequence select="
			tokenize(
				analyze-string(
					u:fix-uri( resolve-uri( $u:uri ) ),
					$ur:URI
				)/fn:match/fn:group[ @nr = 3 ]/text()/string(),
				'/'
			)
		"/>
	</xsl:function>

	<xsl:function name="u:get-parent-directory-name" as="xs:string?" visibility="final">
		<xsl:param name="u:uri" as="xs:anyURI"/>
		<xsl:sequence select="
			u:get-segments( $u:uri )[ position() = last() - 1 ]
		"/>
	</xsl:function>

	<xsl:function name="u:get-file-name" as="xs:string?" visibility="final">
		<xsl:param name="u:uri" as="xs:anyURI"/>
		<xsl:sequence select="
			u:get-segments( $u:uri )[ last() ]
		"/>
	</xsl:function>

	<xsl:function name="u:get-file-name-without-extension" as="xs:string?" visibility="final">
		<xsl:param name="u:uri" as="xs:anyURI"/>
		<xsl:sequence select="
			string-join(
				tokenize( u:get-file-name( $u:uri ), '\.' )[ position() lt last() ],
				'.'
			)
		"/>
	</xsl:function>

	<xsl:function name="u:make-relative-uri" as="xs:string" visibility="final">
		<xsl:param name="u:uri" as="xs:anyURI"/>
		<xsl:param name="u:base-uri" as="xs:anyURI"/>
		<xsl:value-of select="
			substring-after(
				u:fix-uri( resolve-uri( $u:uri ) ),
				u:fix-uri( resolve-uri( $u:base-uri ) )
			)
		"/>
	</xsl:function>

</xsl:package>
