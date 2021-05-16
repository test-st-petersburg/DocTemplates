<?xml version="1.0" encoding="UTF-8"?><xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:ms="urn:schemas-microsoft-com:xslt"

	xmlns:xcard="urn:ietf:params:xml:ns:vcard-4.0"

	xmlns:t="http://github.com/test-st-petersburg/DocTemplates/tools/xCard/xslt/xCard-to-vCard"
>

	<xsl:output method="text" indent="no" encoding="UTF-8" omit-xml-declaration="yes" media-type="text/x-vcard"/>

	<xsl:variable name="t:new-line" select="'&#xd;&#xa;'"/>

	<xsl:mode default-validation="preserve" on-multiple-match="fail" on-no-match="shallow-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:head" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="false"/>
	<xsl:mode name="t:body" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:property-value" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:property-name" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-parameters" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-parameter" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-parameter-value" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-type" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-type-by-value" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>

	<xsl:mode name="t:property-value-component" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>
	<xsl:mode name="t:property-value-component-values" default-validation="preserve" on-multiple-match="fail" on-no-match="fail"/>

	<xsl:template match="/">
		<xsl:apply-templates select="xcard:vcards/xcard:vcard"/>
	</xsl:template>

	<xsl:template match="/xcard:vcards/xcard:vcard">
		<xsl:text>BEGIN:VCARD</xsl:text>
		<xsl:value-of select="$t:new-line"/>
		<xsl:text>VERSION:4.0</xsl:text>
		<xsl:value-of select="$t:new-line"/>

		<xsl:call-template name="t:process-property-with-default">
			<xsl:with-param name="t:result">
				<xsl:apply-templates mode="t:head" select="xcard:kind"/>
			</xsl:with-param>
			<xsl:with-param name="t:name" select=" 'KIND' "/>
			<xsl:with-param name="t:default" select=" 'individual' "/>
		</xsl:call-template>
		<xsl:apply-templates mode="t:head" select="xcard:source"/>

		<xsl:apply-templates mode="t:body" select=" * except xcard:kind, xcard:source "/>

		<xsl:text>END:VCARD</xsl:text>
		<xsl:value-of select="$t:new-line"/>
	</xsl:template>

	<?region обработка свойств ?>

	<xsl:template name="t:process-property-with-default" as=" text() ">
		<xsl:context-item use="optional"/>
		<xsl:param name="t:result" as=" xsd:string " required="false"/>
		<xsl:param name="t:name" as=" xsd:string " select=" upper-case( local-name(.) ) " required="false"/>
		<xsl:param name="t:default" as=" xsd:string " select=" '' " required="false"/>

		<!-- TODO: выполнить разделение строк https://datatracker.ietf.org/doc/html/rfc6350#section-3.2 -->
		<xsl:choose>
			<xsl:when test=" $t:result != null ">
				<xsl:value-of select=" $t:result "/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of separator="">
					<xsl:value-of select="  $t:name "/>
					<xsl:text>:</xsl:text>
					<xsl:value-of select=" $t:default "/>
					<xsl:value-of select="$t:new-line"/>
				</xsl:value-of>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="t:process-property" as=" text() ">
		<xsl:context-item use="required"/>

		<!-- TODO: выполнить разделение строк https://datatracker.ietf.org/doc/html/rfc6350#section-3.2 -->
		<xsl:value-of separator="">
			<!-- наименование свойства -->
			<xsl:apply-templates mode="t:property-name" select=" . "/>
			<!-- параметры свойства -->
			<xsl:variable name="t:property-parameters" as=" element()* ">
				<xsd:union>
					<xsl:call-template name="t:get-property-type"/>
					<xsl:apply-templates mode="t:property-parameters" select=" . "/>
				</xsd:union>
			</xsl:variable>
			<xsl:for-each select=" $t:property-parameters/* ">
				<xsl:text>;</xsl:text>
				<xsl:value-of select=" upper-case( local-name(.) ) "/>
				<xsl:text>=</xsl:text>
				<xsl:value-of separator=",">
					<xsl:apply-templates mode="t:property-parameter-value" select=" * "/>
				</xsl:value-of>
			</xsl:for-each>
			<!-- значение свойства -->
			<xsl:text>:</xsl:text>
			<xsl:apply-templates mode="t:property-value" select=" . "/>
			<xsl:value-of select="$t:new-line"/>
		</xsl:value-of>
	</xsl:template>

	<xsl:template mode="t:head" match="
		xcard:kind
		| xcard:source
	" as=" text() " >
		<xsl:call-template name="t:process-property"/>
	</xsl:template>

	<xsl:template mode="t:body" match=" * " as=" text() ">
		<xsl:call-template name="t:process-property"/>
	</xsl:template>

	<xsl:template mode="t:property-name" match=" * " as=" xsd:token ">
		<xsl:value-of select=" upper-case( local-name(.) ) "/>
	</xsl:template>

	<xsl:template mode="t:property-value" match=" * ">
		<xsl:variable name="t:property-value-components" select=" * except xcard:parameters "/>
		<xsl:apply-templates mode="t:property-value-component" select=" $t:property-value-components[ position() = 1 ] "/>
		<xsl:for-each select=" $t:property-value-components[ position() > 1 ] ">
			<xsl:text>,</xsl:text>
			<xsl:apply-templates mode="t:property-value-component" select=" . "/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template mode="t:property-value" match=" xcard:n ">
		<xsl:call-template name="t:process-property-value-component">
			<xsl:with-param name="t:property-value-component-values" select="xcard:surname"/>
		</xsl:call-template>
		<xsl:text>;</xsl:text>
		<xsl:call-template name="t:process-property-value-component">
			<xsl:with-param name="t:property-value-component-values" select="xcard:given"/>
		</xsl:call-template>
		<xsl:text>;</xsl:text>
		<xsl:call-template name="t:process-property-value-component">
			<xsl:with-param name="t:property-value-component-values" select="xcard:additional"/>
		</xsl:call-template>
		<xsl:text>;</xsl:text>
		<xsl:call-template name="t:process-property-value-component">
			<xsl:with-param name="t:property-value-component-values" select="xcard:prefix"/>
		</xsl:call-template>
		<xsl:text>;</xsl:text>
		<xsl:call-template name="t:process-property-value-component">
			<xsl:with-param name="t:property-value-component-values" select="xcard:suffix"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template mode="t:property-value" match=" xcard:adr ">
		<xsl:call-template name="t:process-property-value-component">
			<xsl:with-param name="t:property-value-component-values" select="xcard:pobox"/>
		</xsl:call-template>
		<xsl:text>;</xsl:text>
		<xsl:call-template name="t:process-property-value-component">
			<xsl:with-param name="t:property-value-component-values" select="xcard:ext"/>
		</xsl:call-template>
		<xsl:text>;</xsl:text>
		<xsl:call-template name="t:process-property-value-component">
			<xsl:with-param name="t:property-value-component-values" select="xcard:street"/>
		</xsl:call-template>
		<xsl:text>;</xsl:text>
		<xsl:call-template name="t:process-property-value-component">
			<xsl:with-param name="t:property-value-component-values" select="xcard:locality"/>
		</xsl:call-template>
		<xsl:text>;</xsl:text>
		<xsl:call-template name="t:process-property-value-component">
			<xsl:with-param name="t:property-value-component-values" select="xcard:region"/>
		</xsl:call-template>
		<xsl:text>;</xsl:text>
		<xsl:call-template name="t:process-property-value-component">
			<xsl:with-param name="t:property-value-component-values" select="xcard:code"/>
		</xsl:call-template>
		<xsl:text>;</xsl:text>
		<xsl:call-template name="t:process-property-value-component">
			<xsl:with-param name="t:property-value-component-values" select="xcard:country"/>
		</xsl:call-template>
	</xsl:template>

	<?endregion обработка свойств ?>

	<?region обработка параметров свойств ?>

	<xsl:template mode="t:property-parameters" match=" * " as=" element()* ">
		<xsl:apply-templates mode="t:property-parameter" select=" xcard:parameters/* "/>
	</xsl:template>

	<xsl:template mode="t:property-parameter" match=" * " as=" element() ">
		<xsl:copy-of select=" . "/>
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

	<xsl:template name="t:get-property-type" as=" element()? ">
		<xsl:context-item as=" element() "/>
		<!-- должно быть указано именно свойство, а не его значения -->
		<xsl:variable name="t:property-type" as=" xsd:string? ">
			<xsl:apply-templates mode="t:property-type" select=" . "/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test=" $t:property-type ">
				<xsl:element name="xcard:value">
					<xsl:element name="xcard:text">
						<xsl:value-of select=" $t:property-type "/>
					</xsl:element>
				</xsl:element>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template mode="t:property-type" match="
		xcard:kind
	"/>

	<xsl:template mode="t:property-type" match="
		xcard:gender
		| xcard:n
		| xcard:adr
	" as=" xsd:string ">
		<xsl:text>text</xsl:text>
	</xsl:template>

	<xsl:template mode="t:property-type" match=" * ">
		<xsl:apply-templates mode="t:property-type-by-value" select=" ( * except xcard:parameters )[1] "/>
	</xsl:template>

	<xsl:template mode="t:property-type-by-value" match=" * ">
		<xsl:value-of select=" local-name(.) "/>
	</xsl:template>

	<?endregion обработка типа свойств ?>

	<?region обработка значений свойств ?>

	<xsl:template mode="t:property-value-component" match=" * ">
		<xsl:value-of select=" text() "/>
	</xsl:template>

	<xsl:template name="t:process-property-value-component">
		<xsl:param name="t:property-value-component-values"/>
		<xsl:apply-templates mode="t:property-value-component-values" select=" $t:property-value-component-values[ position()=1 ] "/>
		<xsl:for-each select=" $t:property-value-component-values[ position() > 1 ] ">
			<xsl:text>,</xsl:text>
			<xsl:apply-templates mode="t:property-value-component-values" select=" . "/>
		</xsl:for-each>
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

	<xsl:function name="t:escape-text-value" as=" xsd:string ">
		<xsl:param name="input" as=" xsd:string "/>
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