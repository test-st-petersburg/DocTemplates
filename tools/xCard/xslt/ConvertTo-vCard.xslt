<?xml version="1.0" encoding="UTF-8"?><xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:ms="urn:schemas-microsoft-com:xslt"

	xmlns:xcard="urn:ietf:params:xml:ns:vcard-4.0"

	xmlns:t="http://github.com/test-st-petersburg/DocTemplates/tools/xCard/xslt/xCard-to-vCard"
>

	<?region Параметры преобразования?>
	<xsl:variable name="t:remove-default-types" as=" xsd:boolean " select=" true() " static="yes" visibility="private"/>
	<?endregion Параметры преобразования ?>

	<xsl:output method="text" indent="no" encoding="UTF-8" omit-xml-declaration="yes" media-type="text/x-vcard"/>

	<xsl:variable name="t:new-line" select="'&#xd;&#xa;'" static="yes" visibility="private"/>

	<xsl:mode default-validation="preserve" on-multiple-match="fail" on-no-match="shallow-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:property" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:property-value" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:property-value-components" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-value-required-components" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip"/>
	<xsl:mode name="t:property-value-component-values" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-name" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-parameters-aux" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-parameter-aux" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-parameter-value" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-type" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-type-non-default" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-type-parameter" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-type-by-value" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-type-default" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="no"/>

	<xsl:template match="/" as=" xsd:string* ">
		<xsl:apply-templates select="xcard:vcards/xcard:vcard"/>
	</xsl:template>

	<xsl:template match="/xcard:vcards/xcard:vcard" as=" xsd:string ">
		<xsl:value-of separator="{$t:new-line}">
			<xsl:element name="t:header">
				<xsl:text>BEGIN:VCARD</xsl:text>
			</xsl:element>
			<xsl:element name="t:header">
				<xsl:text>VERSION:4.0</xsl:text>
			</xsl:element>

			<xsl:call-template name="t:out-property">
				<xsl:with-param name="t:vcard-property-content">
					<xsl:call-template name="t:process-property-with-default">
						<xsl:with-param name="t:result">
							<xsl:apply-templates mode="t:property" select="xcard:kind"/>
						</xsl:with-param>
						<xsl:with-param name="t:name" select=" 'KIND' "/>
						<xsl:with-param name="t:default" select=" 'individual' "/>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:for-each select=" xcard:source ">
				<xsl:call-template name="t:out-property">
					<xsl:with-param name="t:vcard-property-content">
						<xsl:apply-templates mode="t:property" select="."/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:for-each select=" * except xcard:kind, xcard:source ">
				<xsl:call-template name="t:out-property">
					<xsl:with-param name="t:vcard-property-content">
						<xsl:apply-templates mode="t:property" select="."/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>

			<xsl:element name="t:footer">
				<xsl:text>END:VCARD</xsl:text>
			</xsl:element>
		</xsl:value-of>
	</xsl:template>

	<?region дополнительная обработка при генерации vCard ?>

	<xsl:template name="t:out-property" as=" xsd:string? ">
		<!-- strings folding: https://datatracker.ietf.org/doc/html/rfc6350#section-3.2 -->
		<xsl:context-item use="optional"/>
		<xsl:param name="t:vcard-property-content" as=" xsd:string? " required="yes"/>
		<xsl:value-of select=" replace( $t:vcard-property-content, '(.{75})', concat( '$1', $t:new-line, ' ' ) )"/>
	</xsl:template>

	<?endregion дополнительная обработка при генерации vCard ?>

	<?region обработка свойств ?>

	<xsl:template name="t:process-property-with-default" as=" xsd:string ">
		<xsl:context-item use="optional"/>
		<xsl:param name="t:result" as=" xsd:string " required="false"/>
		<xsl:param name="t:name" as=" xsd:string " select=" upper-case( local-name(.) ) " required="false"/>
		<xsl:param name="t:default" as=" xsd:string " select=" '' " required="false"/>

		<xsl:choose>
			<xsl:when test=" $t:result != null ">
				<xsl:value-of select=" $t:result "/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of separator="">
					<xsl:value-of select="  $t:name "/>
					<xsl:text>:</xsl:text>
					<xsl:value-of select=" $t:default "/>
				</xsl:value-of>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="t:process-property" as=" text() ">
		<xsl:context-item use="required"/>
		<xsl:value-of separator="">
			<xsl:value-of separator=";">
				<!-- наименование свойства -->
				<xsl:apply-templates mode="t:property-name" select="."/>
				<!-- параметры свойства -->
				<xsl:apply-templates mode="t:property-type-parameter" select="."/>
				<xsl:apply-templates mode="t:property-parameters-aux" select="."/>
			</xsl:value-of>
			<!-- значение свойства -->
			<xsl:text>:</xsl:text>
			<xsl:apply-templates mode="t:property-value" select="."/>
		</xsl:value-of>
	</xsl:template>

	<xsl:template mode="t:property" match=" * " as=" xsd:string ">
		<xsl:call-template name="t:process-property"/>
	</xsl:template>

	<xsl:template mode="t:property-name" match=" * " as=" xsd:token ">
		<xsl:value-of select=" upper-case( local-name(.) ) "/>
	</xsl:template>

	<?endregion обработка свойств ?>

	<?region обработка параметров свойств ?>

	<xsl:template mode="t:property-parameters-aux" match=" * " as=" xsd:string* ">
		<xsl:context-item as=" element() " use="required"/>
		<xsl:apply-templates mode="t:property-parameter-aux" select=" xcard:parameters/* "/>
	</xsl:template>

	<xsl:template mode="t:property-parameter-aux" match=" * " as=" xsd:string ">
		<xsl:context-item as=" element() " use="required"/>

		<xsl:value-of separator="">
			<xsl:value-of select=" upper-case( local-name(.) ) "/>
			<xsl:text>=</xsl:text>
			<xsl:value-of separator=",">
				<xsl:apply-templates mode="t:property-parameter-value" select="*"/>
			</xsl:value-of>
		</xsl:value-of>
	</xsl:template>

	<xsl:template mode="t:property-parameter-value" match=" * " as=" xsd:string ">
		<xsl:value-of select=" text() "/>
	</xsl:template>

	<xsl:template mode="t:property-parameter-value" match="
		xcard:label/xcard:text
	" as=" xsd:string ">
		<xsl:value-of select=" t:escape-text-value( text() ) "/>
	</xsl:template>

	<?endregion обработка параметров свойств ?>

	<?region обработка типа свойств ?>

	<xsl:template mode="t:property-type-parameter" match=" * " as=" text()? ">
		<xsl:context-item as=" element() " use="required"/>
		<xsl:value-of separator="">
			<xsl:on-non-empty>
				<xsl:text>VALUE=</xsl:text>
			</xsl:on-non-empty>
			<xsl:apply-templates mode="t:property-type" select=" . " use-when=" not( $t:remove-default-types ) "/>
			<xsl:apply-templates mode="t:property-type-non-default" select=" . " use-when=" $t:remove-default-types "/>
		</xsl:value-of>
	</xsl:template>

	<xsl:template mode="t:property-type-non-default" match=" * " as=" text()? ">
		<xsl:variable name="t:type" as=" text()? ">
			<xsl:apply-templates mode="t:property-type" select=" . "/>
		</xsl:variable>
		<xsl:variable name="t:default-type" as=" text()? ">
			<xsl:apply-templates mode="t:property-type-default" select=" . "/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test=" not( string( $t:type ) = string( $t:default-type ) ) ">
				<xsl:copy-of select=" $t:type "/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="t:property-type" match=" * " as=" text()? ">
		<xsl:apply-templates mode="t:property-type-by-value" select=" ( * except xcard:parameters )[1] "/>
	</xsl:template>

	<xsl:template mode="t:property-type" match="
		xcard:kind
		| xcard:clientpidmap
	" as=" text()? "/>

	<xsl:template mode="t:property-type" match="
		xcard:gender
		| xcard:n
		| xcard:adr
	" as=" text()? ">
		<xsl:text>text</xsl:text>
	</xsl:template>

	<xsl:template mode="t:property-type-by-value" match=" * " as=" text()? ">
		<xsl:value-of select=" local-name(.) "/>
	</xsl:template>

	<xsl:template mode="t:property-type-default" match="
		xcard:kind
		| xcard:fn
		| xcard:n
		| xcard:nickname
		| xcard:gender
		| xcard:adr
		| xcard:tel
		| xcard:email
		| xcard:tz
		| xcard:title
		| xcard:role
		| xcard:org
		| xcard:categories
		| xcard:note
		| xcard:prodid
		| xcard:version
	" as=" text() ">
		<xsl:text>text</xsl:text>
	</xsl:template>

	<xsl:template mode="t:property-type-default" match="
		xcard:source
		| xcard:photo
		| xcard:impp
		| xcard:geo
		| xcard:logo
		| xcard:member
		| xcard:related
		| xcard:sound
		| xcard:uid
		| xcard:url
		| xcard:key
		| xcard:fburl
		| xcard:caladruri
		| xcard:caluri
	" as=" text() ">
		<xsl:text>uri</xsl:text>
	</xsl:template>

	<xsl:template mode="t:property-type-default" match="
		xcard:bday
		| xcard:anniversary
	" as=" text() ">
		<xsl:text>date-and-or-time</xsl:text>
	</xsl:template>

	<xsl:template mode="t:property-type-default" match="
		xcard:rev
	" as=" text() ">
		<xsl:text>timestamp</xsl:text>
	</xsl:template>

	<xsl:template mode="t:property-type-default" match="
		xcard:lang
	" as=" text() ">
		<xsl:text>language-tag</xsl:text>
	</xsl:template>

	<?endregion обработка типа свойств ?>

	<?region обработка значений свойств ?>

	<xsl:template mode="t:property-value" match=" * " as=" xsd:string ">
		<xsl:value-of separator=";">
			<xsl:apply-templates mode="t:property-value-components" select="." />
		</xsl:value-of>
	</xsl:template>

	<xsl:template mode="t:property-value-components" match=" * " as=" item()* ">
		<xsl:variable name="t:property-value-required-components" as=" item()* ">
			<xsl:apply-templates mode="t:property-value-required-components" select="." />
		</xsl:variable>
		<xsl:choose>
			<xsl:when test=" exists( $t:property-value-required-components ) ">
				<xsl:variable name="t:property-element" as=" item() " select=" current() "/>
				<xsl:for-each select=" $t:property-value-required-components ">
					<xsl:variable name="t:property-value-required-component-name" as=" xsd:string " select=" local-name(.) "/>
					<!-- лишний элемент добавляю для корректного слияния через сепаратор в xsl:value-of -->
					<xsl:element name="t:property-value-component">
						<xsl:value-of separator=",">
							<xsl:for-each select=" $t:property-element/* [ local-name(.) = $t:property-value-required-component-name ] ">
								<!-- лишний элемент добавляю для корректного слияния через сепаратор в xsl:value-of -->
								<xsl:element name="t:property-value-component-value">
									<xsl:apply-templates mode="t:property-value-component-values" select="." />
								</xsl:element>
							</xsl:for-each>
						</xsl:value-of>
					</xsl:element>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each-group select=" * except xcard:parameters " group-by=" local-name(.) ">
					<!-- лишний элемент добавляю для корректного слияния через сепаратор в xsl:value-of -->
					<xsl:element name="t:property-value-component">
						<xsl:value-of separator=",">
							<xsl:for-each select=" current-group() ">
								<!-- лишний элемент добавляю для корректного слияния через сепаратор в xsl:value-of -->
								<xsl:element name="t:property-value-component-value">
									<xsl:apply-templates mode="t:property-value-component-values" select="." />
								</xsl:element>
							</xsl:for-each>
						</xsl:value-of>
					</xsl:element>
				</xsl:for-each-group>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="t:property-value-components" match=" xcard:org " as=" item()* ">
		<xsl:for-each select=" * except xcard:parameters ">
			<!-- лишний элемент добавляю для корректного слияния через сепаратор в xsl:value-of -->
			<xsl:element name="t:property-value-component">
				<xsl:apply-templates mode="t:property-value-component-values" select="." />
			</xsl:element>
		</xsl:for-each>
	</xsl:template>

	<xsl:template mode="t:property-value-required-components" match=" xcard:n ">
		<xsl:element name="xcard:surname"/>
		<xsl:element name="xcard:given"/>
		<xsl:element name="xcard:additional"/>
		<xsl:element name="xcard:prefix"/>
		<xsl:element name="xcard:suffix"/>
	</xsl:template>

	<xsl:template mode="t:property-value-required-components" match=" xcard:adr ">
		<xsl:element name="xcard:pobox"/>
		<xsl:element name="xcard:ext"/>
		<xsl:element name="xcard:street"/>
		<xsl:element name="xcard:locality"/>
		<xsl:element name="xcard:region"/>
		<xsl:element name="xcard:code"/>
		<xsl:element name="xcard:country"/>
	</xsl:template>

	<xsl:template mode="t:property-value-component-values" match=" * ">
		<xsl:value-of select=" text() "/>
	</xsl:template>

	<xsl:template mode="t:property-value-component-values" match="
		xcard:text
		| xcard:n/xcard:*
		| xcard:adr/xcard:*
	">
		<xsl:value-of select=" t:escape-text-value( text() ) "/>
	</xsl:template>

	<?endregion обработка значений свойств ?>

	<?region обработка значений ?>

	<xsl:function name="t:escape-text-value" as=" xsd:string? ">
		<xsl:param name="input" as=" xsd:string? "/>
		<xsl:value-of select="
			replace(
				replace(
					replace(
						replace(
							replace(
								$input,
								'\\', '\\'
							), ',', '\\,'
						), ';', '\\;'
					), $t:new-line, '\\n'
				), '&#xa;', '\\n'
			)
		"/>
	</xsl:function>

	<?endregion обработка значений ?>

</xsl:transform>