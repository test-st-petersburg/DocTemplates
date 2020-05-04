<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="BasicXMLFormatter"
	name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter/basic.xslt"
	package-version="1.5.0"
	input-type-annotations="preserve"
	declared-modes="yes"
	default-mode="f:outline"
	default-validation="preserve"
	expand-text="no"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:f="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/formatter"
>

	<xsl:mode
		name="f:inline"
		on-no-match="shallow-copy" warning-on-no-match="false"
		on-multiple-match="fail" warning-on-multiple-match="true"
		visibility="public"
	/>

	<xsl:mode
		name="f:outline"
		on-no-match="fail" warning-on-no-match="true"
		on-multiple-match="fail" warning-on-multiple-match="true"
		visibility="public"
	/>

	<xsl:mode
		name="f:outline-child"
		on-no-match="fail" warning-on-no-match="true"
		on-multiple-match="fail" warning-on-multiple-match="true"
		visibility="public"
	/>

	<xsl:mode
		name="f:outline-self"
		on-no-match="fail" warning-on-no-match="true"
		on-multiple-match="fail" warning-on-multiple-match="true"
		visibility="final"
	/>

	<xsl:variable name="f:default-indent-chars" as="xs:string" select="'&#x9;'" static="yes" visibility="private"/>
	<xsl:variable name="f:default-indent-line" as="xs:string" select="'&#xa;'" static="yes" visibility="private"/>

	<!--
		Обработаем текст, в том числе - пробелы, используемые для форматирования.
		При обработке уже форматированного текста будем иметь на входе "лишние" text(),
		которые необходимо исключить.
		Следующие два правила удаляют text(), состоящие только из пробельных символов,
		и копируют другие text().
		Для иной обработки text() в конкретном случае необходимо переопределять
		шаблоны для всех указанных ниже режимов, указывая более высокий приоритет.
	-->

	<xsl:template mode="f:outline f:outline-self" match="text()[ not( matches( data(), '\S+' ) ) ]" priority="-5"/>

	<xsl:template mode="f:inline f:outline f:outline-self" match="text()" priority="-10">
		<xsl:copy />
	</xsl:template>

	<!--
		Обработка в режиме f:outline (форматируем XML, формируем древовидную структуру).
		Режим f:outline отвечает за обработку узла целиком.
		Переопределять правила для режима f:outline,
		если при этом формирование структуры всё-таки требуется, нежелательно.
		См. f:outline-child.
	-->

	<xsl:template mode="f:outline" match="/">
		<xsl:param name="f:indent" as="xs:string" select="$f:default-indent-line" tunnel="yes"/>
		<xsl:param name="f:indent-chars" as="xs:string" select="$f:default-indent-chars" tunnel="yes"/>
		<xsl:apply-templates select="element()" mode="f:outline"/>
	</xsl:template>

	<xsl:template mode="f:outline" match="processing-instruction() | comment()">
		<xsl:copy/>
	</xsl:template>

	<xsl:template mode="f:outline" match="@*">
		<xsl:copy />
	</xsl:template>

	<xsl:template mode="f:outline" match="element()">
		<xsl:param name="f:indent" as="xs:string" select="$f:default-indent-line" tunnel="yes"/>
		<xsl:param name="f:indent-chars" as="xs:string" select="$f:default-indent-chars" tunnel="yes"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="f:outline"/>
			<xsl:sequence>
				<xsl:apply-templates select="." mode="f:outline-child"/>
				<xsl:on-non-empty select="$f:indent"/>
			</xsl:sequence>
		</xsl:copy>
	</xsl:template>

	<!--
		TODO: рассмотреть вариант динамического определения элементов,
		содержащих только текст, с переводом их в режим inline.
	-->

	<!--
		Режим f:outline-child выделен для облегчения переопределения порядка вывода
		потомков без нарушения нормализации правил, генерирующих форматирование.
		Если требуеся изменить порядок вывода потомков, переопределять следует
		правило для элемента именно в режиме f:outline-child.
	-->

	<xsl:template mode="f:outline-child" match="element()">
		<xsl:apply-templates select="node()" mode="f:outline-self"/>
	</xsl:template>

	<!--
		Режим f:outline-self выделен для инкапсуляции правил,
		генерирующих отступы в тексте XML при его форматировании.
		Переопределение шаблонов данного режима крайне нежелательно
		(как наружение инкапсуляции и нормализации кода).
		В целях изменения поведения используйте режимы f:outline, ouline-child.
	-->

	<xsl:template mode="f:outline-self" match="element()">
		<xsl:param name="f:indent" as="xs:string" select="$f:default-indent-line" tunnel="yes"/>
		<xsl:param name="f:indent-chars" as="xs:string" select="$f:default-indent-chars" tunnel="yes"/>
		<xsl:variable name="f:next-indent" as="xs:string" select="concat( $f:indent, $f:indent-chars )"/>
		<xsl:sequence>
			<xsl:on-non-empty select="$f:next-indent"/>
			<xsl:apply-templates select="." mode="f:outline">
				<xsl:with-param name="f:indent" select="$f:next-indent" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:sequence>
	</xsl:template>

</xsl:package>
