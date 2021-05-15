<?xml version="1.0" encoding="UTF-8"?><xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ms="urn:schemas-microsoft-com:xslt"

	xmlns:xcard="urn:ietf:params:xml:ns:vcard-4.0"

	xmlns:t="http://github.com/test-st-petersburg/DocTemplates/tools/xCard/xslt/xCard-to-vCard"
	xmlns:tf="http://github.com/test-st-petersburg/DocTemplates/tools/xCard/xslt/xCard-to-vCard/xPath-3.0-compatibility"
>

	<xsl:output method="text" indent="no" encoding="UTF-8" omit-xml-declaration="yes" media-type="text/x-vcard"/>

	<xsl:variable name="t:new-line" select="'&#xd;&#xa;'"/>

	<xsl:mode default-validation="preserve" on-multiple-match="fail" on-no-match="shallow-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:head" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="false"/>
	<xsl:mode name="t:body" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:properties" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:properties-values" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:property-type" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:parameters" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="true"/>
	<xsl:mode name="t:parameters-values" default-validation="preserve" on-multiple-match="fail" on-no-match="deep-skip" warning-on-no-match="true"/>

	<?region Замена upper-case для XSLT 1.0 ?>

	<xsl:variable name="tf:upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:variable name="tf:lower" select="'abcdefghijklmnopqrstuvwxyz'"/>

	<?endregion ?>


	<?region Замена replace для XSLT 1.0 ?>

	<xsl:template name="tf:replace">
		<xsl:param name="input" />
		<xsl:param name="pattern" />
		<xsl:param name="replacement" />
		<xsl:choose>
			<xsl:when test=" contains( $input, $pattern ) ">
				<xsl:value-of select="concat(
					substring-before( $input, $pattern ),
					$replacement
				)" />
				<xsl:call-template name="tf:replace">
					<xsl:with-param name="input" select=" substring-after( $input, $pattern ) "/>
					<xsl:with-param name="pattern" select="$pattern"/>
					<xsl:with-param name="replacement" select="$replacement"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$input" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<?endregion ?>

	<xsl:template match="/">
		<xsl:apply-templates select="xcard:vcards/xcard:vcard"/>
	</xsl:template>

	<xsl:template match="/xcard:vcards/xcard:vcard">
		<xsl:text>BEGIN:VCARD</xsl:text>
		<xsl:value-of select="$t:new-line"/>
		<xsl:text>VERSION:4.0</xsl:text>
		<xsl:value-of select="$t:new-line"/>

		<xsl:apply-templates select="xcard:kind" mode="t:head"/>
		<xsl:apply-templates select="xcard:source" mode="t:head"/>

		<!-- <xsl:apply-templates select="* except xcard:kind"/> -->
		<xsl:apply-templates select="*[ not( self::xcard:kind | self::xcard:source ) ]" mode="t:body"/>

		<xsl:text>END:VCARD</xsl:text>
		<xsl:value-of select="$t:new-line"/>
	</xsl:template>

	<xsl:template name="t:process-property">
		<!-- TODO: выполнить разделение строк https://datatracker.ietf.org/doc/html/rfc6350#section-3.2 -->
		<!-- наименование свойства -->
		<!-- <xsl:value-of select=" upper-case( local-name(.) ) "/> -->
		<xsl:value-of select=" translate( local-name(.), $tf:lower, $tf:upper ) "/>
		<!-- параметры свойства -->
		<xsl:apply-templates mode="t:parameters" select=" xcard:parameters/* "/>
		<xsl:apply-templates mode="t:property-type" select=" *[ not( self::xcard:parameters ) ][1] "/>
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

	<xsl:template mode="t:values" match=" xcard:text ">
		<xsl:value-of select=" text() "/>
	</xsl:template>

	<xsl:template mode="t:parameters" match=" * ">
		<xsl:text>;</xsl:text>
		<xsl:value-of select=" translate( local-name(.), $tf:lower, $tf:upper ) "/>
		<xsl:text>=</xsl:text>
		<xsl:apply-templates mode="t:parameters-values" select=" * "/>
	</xsl:template>

	<xsl:template mode="t:parameters-values" match=" xcard:text ">
		<xsl:value-of select=" text() "/>
	</xsl:template>

	<xsl:template mode="t:parameters-values" match=" * ">
		<xsl:value-of select=" text() "/>
	</xsl:template>

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

	<?endregion ?>

	<?region обработка значений свойств ?>

	<xsl:template mode="t:properties" match=" xcard:n ">
		<xsl:apply-templates mode="t:properties-values" select="xcard:surname"/>
		<xsl:text>;</xsl:text>
		<xsl:apply-templates mode="t:properties-values" select="xcard:given"/>
		<xsl:text>;</xsl:text>
		<xsl:apply-templates mode="t:properties-values" select="xcard:additional"/>
		<xsl:text>;</xsl:text>
		<xsl:apply-templates mode="t:properties-values" select="xcard:prefix"/>
		<xsl:text>;</xsl:text>
		<xsl:apply-templates mode="t:properties-values" select="xcard:suffix"/>
	</xsl:template>

	<xsl:template mode="t:properties" match=" * ">
		<xsl:variable name="t:property-value-parts" select=" *[ not( self::xcard:parameters ) ] "/>
		<xsl:apply-templates mode="t:properties-values" select=" $t:property-value-parts[ position() = 1 ] "/>
		<xsl:for-each select=" $t:property-value-parts[ position() > 1 ] ">
			<xsl:text>;</xsl:text>
			<xsl:apply-templates mode="t:properties-values" select=" . "/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="t:escape-property-value">
		<xsl:param name="input"/>
		<xsl:call-template name="tf:replace">
			<xsl:with-param name="input">
				<xsl:call-template name="tf:replace">
					<xsl:with-param name="input">
						<xsl:call-template name="tf:replace">
							<xsl:with-param name="input">
								<xsl:call-template name="tf:replace">
									<xsl:with-param name="input">
										<xsl:call-template name="tf:replace">
											<xsl:with-param name="input" select=" $input "/>
											<xsl:with-param name="pattern" select=" '\' "/>
											<xsl:with-param name="replacement" select=" '\\' "/>
										</xsl:call-template>
									</xsl:with-param>
									<xsl:with-param name="pattern" select=" ',' "/>
									<xsl:with-param name="replacement" select=" '\,' "/>
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="pattern" select=" ';' "/>
							<xsl:with-param name="replacement" select=" '\;' "/>
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="pattern" select=" $t:new-line "/>
					<xsl:with-param name="replacement" select=" '\n' "/>
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="pattern" select=" '&#xa;' "/>
			<xsl:with-param name="replacement" select=" '\n' "/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template mode="t:properties-values" match=" xcard:text ">
		<xsl:call-template name="t:escape-property-value">
			<xsl:with-param name="input" select=" text() "/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template mode="t:properties-values" match=" * ">
		<xsl:value-of select=" text() "/>
	</xsl:template>

	<?endregion ?>

</xsl:transform>