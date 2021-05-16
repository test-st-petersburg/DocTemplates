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
	<xsl:mode name="t:properties" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:property-type" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:parameters" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:parameters-values" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="true"/>
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

		<xsl:apply-templates mode="t:head" select="xcard:kind"/>
		<xsl:apply-templates mode="t:head" select="xcard:source"/>

		<xsl:apply-templates mode="t:body" select=" * except xcard:kind, xcard:source "/>

		<xsl:text>END:VCARD</xsl:text>
		<xsl:value-of select="$t:new-line"/>
	</xsl:template>

	<?region обработка свойств ?>

	<xsl:template name="t:process-property">
		<!-- TODO: выполнить разделение строк https://datatracker.ietf.org/doc/html/rfc6350#section-3.2 -->
		<!-- наименование свойства -->
		<xsl:value-of select=" upper-case( local-name(.) ) "/>
		<!-- параметры свойства -->
		<xsl:apply-templates mode="t:parameters" select=" xcard:parameters/* "/>
		<!-- TODO: проверить корректное выделение первого значения при наличии параметров -->
		<xsl:apply-templates mode="t:property-type" select=" ( * except xcard:parameters )[1] "/>
		<!-- значение свойства -->
		<xsl:text>:</xsl:text>
		<xsl:apply-templates mode="t:properties" select=" . "/>
		<xsl:value-of select="$t:new-line"/>
	</xsl:template>

	<xsl:template mode="t:head" match="
		xcard:kind | xcard:source
	">
		<xsl:call-template name="t:process-property"/>
	</xsl:template>

	<xsl:template mode="t:body" match=" * ">
		<xsl:call-template name="t:process-property"/>
	</xsl:template>

	<xsl:template mode="t:properties" match=" * ">
		<xsl:variable name="t:property-value-components" select=" * except xcard:parameters "/>
		<xsl:apply-templates mode="t:property-value-component" select=" $t:property-value-components[ position() = 1 ] "/>
		<xsl:for-each select=" $t:property-value-components[ position() > 1 ] ">
			<xsl:text>;</xsl:text>
			<xsl:apply-templates mode="t:property-value-component" select=" . "/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template mode="t:properties" match=" xcard:n ">
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

	<?endregion обработка свойств ?>

	<?region обработка параметров свойств ?>

	<xsl:template mode="t:parameters" match=" * ">
		<xsl:value-of select=" concat( ';', upper-case( local-name(.) ), '=' ) "/>
		<xsl:apply-templates mode="t:parameters-values" select=" * "/>
	</xsl:template>

	<xsl:template mode="t:parameters-values" match=" xcard:text ">
		<xsl:value-of select=" text() "/>
	</xsl:template>

	<xsl:template mode="t:parameters-values" match=" * ">
		<xsl:value-of select=" text() "/>
	</xsl:template>

	<?endregion обработка параметров свойств ?>

	<?region обработка типа свойств ?>

	<xsl:template mode="t:property-type" match=" * ">
		<xsl:value-of select=" concat( ';VALUE=', local-name(.) ) "/>
	</xsl:template>

	<xsl:template mode="t:property-type" match="
		xcard:kind/xcard:text
		| xcard:source/xcard:uri
		| xcard:fn/xcard:text
		| xcard:n/*
	"/>

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
	">
		<xsl:value-of select=" t:escape-property-value-component-value( text() ) "/>
	</xsl:template>

	<xsl:function name="t:escape-property-value-component-value">
		<xsl:param name="input"/>
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

	<?endregion ?>

</xsl:transform>