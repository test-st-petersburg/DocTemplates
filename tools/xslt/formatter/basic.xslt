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

	<!--
		Обработка в режиме f:inline убирает форматирование.
	-->
	<xsl:mode
		name="f:inline"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="public"
	/>

	<!--
		Обработка в режиме f:inline-preserve-space сохраняет text() без изменений.
	-->
	<xsl:mode
		name="f:inline-preserve-space"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="public"
	/>

	<!--
		Обработка text() в режиме f:strip-space убирает text(), состоящие из пробельных символов,
		а также убирает начальные и завершающие пробелы в остальных text().
	-->
	<xsl:mode
		name="f:strip-space"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="public"
	/>

	<!--
		Обработка text() в режиме f:preserve-space сохраняет text() без изменений.
	-->
	<xsl:mode
		name="f:preserve-space"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="public"
	/>

	<!--
		Обработка в режиме f:outline (форматируем XML, формируем древовидную структуру).
		Режим f:outline отвечает за обработку узла целиком.
		Переопределять правила для режима f:outline,
		если при этом формирование структуры всё-таки требуется, нежелательно.
		См. f:outline-child.
	-->
	<xsl:mode
		name="f:outline"
		on-no-match="fail" warning-on-no-match="yes"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="public"
	/>

	<xsl:mode
		name="f:outline-available"
		on-no-match="fail" warning-on-no-match="yes"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="public"
	/>

	<!--
		Обработка в режиме f:outline-preserve-space допускает форматирование для потомков
		(если режим будет явно изменён последующими правилами),
		но запрещает форматирование для текущего элемента.
	-->
	<xsl:mode
		name="f:outline-preserve-space"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="public"
	/>

	<!--
		Режим f:outline-child выделен для облегчения переопределения порядка вывода
		потомков без нарушения нормализации правил, генерирующих форматирование.
		Если требуеся изменить порядок вывода потомков, переопределять следует
		правило для элемента именно в режиме f:outline-child.
	-->
	<xsl:mode
		name="f:outline-child"
		on-no-match="fail" warning-on-no-match="yes"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="public"
	/>

	<!--
		Режим f:outline-self выделен для инкапсуляции правил,
		генерирующих отступы в тексте XML при его форматировании.
		Переопределение шаблонов данного режима крайне нежелательно
		(как наружение инкапсуляции и нормализации кода).
		В целях изменения поведения используйте режимы f:outline, ouline-child.
	-->
	<xsl:mode
		name="f:outline-self"
		on-no-match="fail" warning-on-no-match="yes"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<xsl:variable name="f:default-indent-chars" as="xs:string" select="'&#x9;'" visibility="final"/>
	<xsl:variable name="f:new-line" as="xs:string" select="'&#xa;'" visibility="final"/>
	<xsl:variable name="f:default-indent-line" as="xs:string" select="$f:new-line" visibility="final"/>

	<!--
		Обработаем текст, в том числе - пробелы, используемые для форматирования.
		При обработке уже форматированного текста будем иметь на входе "лишние" text(),
		которые необходимо исключить.
		Следующие два правила удаляют text(), состоящие только из пробельных символов,
		и копируют другие text().
		Для иной обработки text() в конкретном случае необходимо переопределять
		шаблоны для всех указанных ниже режимов, указывая более высокий приоритет.
	-->

	<xsl:template mode="f:inline f:outline f:outline-self" match="text()">
		<xsl:apply-templates select="." mode="f:strip-space"/>
	</xsl:template>

	<xsl:template mode="f:outline-preserve-space f:inline-preserve-space" match="text()">
		<xsl:apply-templates select="." mode="f:preserve-space"/>
	</xsl:template>

	<xsl:template mode="f:strip-space" match="text()">
		<xsl:analyze-string select="." regex="^\s*(.*?)\s*$" flags="ms">
			<xsl:matching-substring>
				<xsl:value-of select="regex-group(1)"/>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>

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
		<xsl:variable name="f:next-indent" as="xs:string" select="concat( $f:indent, $f:indent-chars )"/>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="f:outline"/>
			<xsl:iterate select="*">
				<xsl:param name="f:indent-available" as="xs:boolean" select="true()"/>
				<xsl:param name="f:indent-expected" as="xs:boolean" select="false()"/>
				<xsl:on-completion>
					<xsl:if test="$f:indent-available and $f:indent-expected">
						<xsl:value-of select="$f:indent"/>
					</xsl:if>
				</xsl:on-completion>
				<xsl:variable name="f:next-indent-available" as="xs:boolean">
					<xsl:apply-templates select="." mode="f:outline-available"/>
				</xsl:variable>
				<xsl:if test="$f:indent-available and $f:next-indent-available">
					<xsl:value-of select="$f:next-indent"/>
				</xsl:if>
				<xsl:apply-templates select="." mode="f:outline">
					<xsl:with-param name="f:indent" as="xs:string" select="$f:next-indent" tunnel="yes"/>
				</xsl:apply-templates>
				<xsl:next-iteration>
					<xsl:with-param name="f:indent-available" as="xs:boolean" select="$f:next-indent-available"/>
					<xsl:with-param name="f:indent-expected" as="xs:boolean" select="$f:next-indent-available"/>
				</xsl:next-iteration>
			</xsl:iterate>
		</xsl:copy>
	</xsl:template>

	<xsl:template mode="f:outline-available" match="*">
		<xsl:value-of select="true()"/>
	</xsl:template>

	<xsl:template mode="f:outline-available" match="text()"/>

</xsl:package>
