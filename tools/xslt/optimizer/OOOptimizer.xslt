<?xml version="1.0" encoding="UTF-8"?><xsl:package version="3.0"
	id="OOOptimizer"
	name="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/optimizer/OOOptimizer.xslt"
	package-version="1.5.0"
	declared-modes="yes"
	expand-text="no"
	input-type-annotations="strip"
	default-validation="strip"

	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

	xmlns:array="http://www.w3.org/2005/xpath-functions/array"
	xmlns:css3t="http://www.w3.org/TR/css3-text/"
	xmlns:dom="http://www.w3.org/2001/xml-events"
	xmlns:grddl="http://www.w3.org/2003/g/data-view#"
	xmlns:map="http://www.w3.org/2005/xpath-functions/map"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:xforms="http://www.w3.org/2002/xforms"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"

	xmlns:calcext="urn:org:documentfoundation:names:experimental:calc:xmlns:calcext:1.0"
	xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0"
	xmlns:config="urn:oasis:names:tc:opendocument:xmlns:config:1.0"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0"
	xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
	xmlns:drawooo="http://openoffice.org/2010/draw"
	xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0"
	xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
	xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0"
	xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0"
	xmlns:loext="urn:org:documentfoundation:names:experimental:office:xmlns:loext:1.0"
	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"
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
	xmlns:toolbar="http://openoffice.org/2001/toolbar"

	xmlns:o="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/optimizer"
>

	<?region Параметры преобразования?>
	<xsl:variable name="o:remove-text-auto-styles" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-unused-para-auto-styles" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-unused-table-auto-styles" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:expand-auto-styles-links" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-hidden-list-styles" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-empty-format-nodes" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-foreign-language-attributes" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-abs-size-when-relative" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-unimportant-files" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-thumbnails" as="xs:boolean" static="yes" select="$o:remove-unimportant-files" visibility="private"/>
	<xsl:variable name="o:remove-config-view-params" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-config-print-params" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-rsid" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-attributes-with-default-values" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-soft-page-breaks" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-layout-params" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:sort-sortable-nodes" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:set-config-params" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:reset-page-number-in-headers-and-footers" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-common-embedded-fonts" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-calculated-meta" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-generator-meta" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:remove-print-meta" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<xsl:variable name="o:fix-manifest" as="xs:boolean" static="yes" select="true()" visibility="private"/>
	<?endregion Параметры преобразования ?>

	<xsl:mode
		name="o:optimize"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="final"
	/>

	<!-- вспомогательный режим: выводим элемент только при наличии аттрибутов или потомков -->

	<xsl:mode
		name="o:where-attributes-or-elements"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:template mode="o:where-attributes-or-elements" match="element()">
		<xsl:variable name="o:attributes" as="attribute()*">
			<xsl:apply-templates select="@*" mode="o:optimize"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="exists( $o:attributes )">
				<xsl:copy>
					<xsl:copy-of select="$o:attributes"/>
					<xsl:apply-templates mode="o:optimize"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:where-populated>
					<xsl:copy>
						<xsl:copy-of select="$o:attributes"/>
						<xsl:apply-templates mode="o:optimize"/>
					</xsl:copy>
				</xsl:where-populated>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<?region удаляем автоматические стили символов ?>

	<xsl:key name="o:auto-text-styles"
		match="office:automatic-styles/style:style[ @style:family='text' ]"
		use="@style:name"
	/>

	<xsl:template mode="o:optimize" use-when="$o:remove-text-auto-styles"
		 match="office:automatic-styles/style:style[ @style:family='text' ]"
	/>

	<xsl:template mode="o:optimize" use-when="$o:remove-text-auto-styles"
		 match="text:span[ key( 'o:auto-text-styles', @text:style-name ) ]">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>

	<!-- TODO: убирать автоматические стили только по отношению к базовому стилю символов -->
	<!-- TODO: для автоматических стилей по отношению к другим стилям символов устанавливать ссылку на исходный стиль -->

	<?endregion удаляем автоматические стили символов ?>
	<?region удаляем неиспользуемые автоматические стили абзацев в content.xml ?>

	<xsl:key name="o:auto-paragraph-styles" use-when="$o:remove-unused-para-auto-styles"
		match="office:automatic-styles/style:style[ @style:family='paragraph' ]"
		use="@style:name"
	/>

	<xsl:key name="o:used-paragraph-styles" use-when="$o:remove-unused-para-auto-styles"
		match="
			office:document-content/office:body/office:text//text:p
			| office:document-content/office:body/office:text//text:h
		"
		use="@text:style-name"
	/>

	<xsl:template mode="o:optimize" use-when="$o:remove-unused-para-auto-styles" match="
		office:document-content/office:automatic-styles/style:style[
		 	@style:family='paragraph'
			and not( key( 'o:used-paragraph-styles', @style:name ) )
		]
	"/>

	<?endregion удаляем неиспользуемые автоматические стили абзацев в content.xml ?>
	<?region удаляем неиспользуемые автоматические стили таблиц в content.xml ?>

	<xsl:key name="o:auto-table-styles" use-when="$o:remove-unused-table-auto-styles"
		match="office:automatic-styles/style:style[ @style:family='table' ]"
		use="@style:name"
	/>

	<xsl:key name="o:used-table-styles" use-when="$o:remove-unused-table-auto-styles"
		match="office:document-content/office:body/office:text//table:table"
		use="@table:style-name"
	/>

	<xsl:template mode="o:optimize" use-when="$o:remove-unused-table-auto-styles" match="
		office:document-content/office:automatic-styles/style:style[
		 	@style:family='table'
			and not( key( 'o:used-table-styles', @style:name ) )
		]
	"/>
	<xsl:template mode="o:optimize" use-when="$o:remove-unused-table-auto-styles" match="
		office:document-content/office:automatic-styles/style:style[
		 	(
			 	( @style:family='table-column' )
				or ( @style:family='table-row' )
				or ( @style:family='table-cell' )
			) and not( key( 'o:used-table-styles', substring-before( @style:name, '.' ) ) )
		]
	"/>

	<?endregion удаляем неиспользуемые автоматические стили таблиц в content.xml ?>
	<?region заменяем ссылки на автоматические стили на описание стиля #62 ?>

	<xsl:mode
		name="o:expand-auto-styles-links"
		on-no-match="shallow-copy" warning-on-no-match="no"
		on-multiple-match="fail" warning-on-multiple-match="yes"
		visibility="private"
	/>

	<xsl:key name="o:automatic-styles"
		use-when=" $o:expand-auto-styles-links "
		match=" office:automatic-styles/style:* "
		use=" @style:name "
	/>

	<xsl:template mode="o:optimize" use-when="$o:expand-auto-styles-links" match="
		*[ namespace-uri(.) = 'urn:oasis:names:tc:opendocument:xmlns:drawing:1.0' ]
		| text:section[ not (
			text:section-source/@text:section-name and not( text:section-source/@xlink:href )
			and ( text:section-source/@xlink:type = 'simple' ) and ( text:section-source/@xlink:show = 'replace' )
			and ( text:section-source/@xlink:actuate = 'other' )
		) ]
		| *[ namespace-uri(.) = 'urn:oasis:names:tc:opendocument:xmlns:table:1.0' ]
	">
		<xsl:copy validation="preserve">
			<xsl:apply-templates select=" @* " mode="#current"/>
			<xsl:apply-templates select=" key( 'o:automatic-styles', attribute()[ local-name(.)='style-name' ] ) "
				mode="o:expand-auto-styles-links"
			/>
			<xsl:apply-templates select=" node() " mode="#current"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template mode="o:optimize" use-when="$o:expand-auto-styles-links" match=" style:master-page ">
		<xsl:copy validation="preserve">
			<xsl:apply-templates select=" @* " mode="#current"/>
			<xsl:apply-templates select=" key( 'o:automatic-styles', @style:page-layout-name ) "
				mode="o:expand-auto-styles-links"
			/>
			<xsl:apply-templates select=" node() " mode="#current"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template mode="o:optimize" use-when="$o:expand-auto-styles-links" match="
		@draw:style-name
		| text:section/@text:style-name
		| @table:style-name
		| @style:page-layout-name
	"/>

	<xsl:template mode="o:optimize" use-when="$o:expand-auto-styles-links" match="
		office:automatic-styles/style:style[
			@style:family='graphic'
			or @style:family='section'
			or @style:family='table' or @style:family='table-column' or @style:family='table-row' or @style:family='table-cell'
		]
		| office:automatic-styles/style:page-layout
	"/>

	<xsl:template mode="o:expand-auto-styles-links" use-when="$o:expand-auto-styles-links" match=" @style:name "/>

	<?endregion заменяем ссылки на автоматические стили врезок и графики на описание стиля #62 ?>
	<?region удаляем определения некоторых неиспользуемых стандартных стилей ?>

	<xsl:template mode="o:optimize" use-when="$o:remove-hidden-list-styles" match="
		text:list-style[ @style:hidden ]
	">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="#current"/>
		</xsl:copy>
	</xsl:template>

	<?endregion удаляем определения некоторых неиспользуемых стандартных стилей ?>
	<?region удаляем лишние элементы ?>

	<xsl:template mode="o:optimize" use-when="$o:remove-empty-format-nodes" match="(
		style:background-image
	)[ empty( @* | node() ) ]"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-empty-format-nodes" match="
		@style:master-page-name[ . = '' ]
	"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-empty-format-nodes" match="
		@fo:background-color[ . = 'transparent' ]
	"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-empty-format-nodes" match="
		style:paragraph-properties/@style:page-number[ . = 'auto' ]
	"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-empty-format-nodes" match="
		style:paragraph-properties[ @text:number-lines = 'false' ]/@text:line-number[ .='0' ]
	"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-empty-format-nodes" match="
		style:paragraph-properties[ @fo:keep-together = 'always' ]/@fo:orphans
		| style:paragraph-properties[ @fo:keep-together = 'always' ]/@fo:widows
	"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-empty-format-nodes" match="
		style:paragraph-properties[ @fo:text-align != 'justify' ]/@style:justify-single-word
	"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-empty-format-nodes" match="
		style:style[ style:text-properties/@fo:hyphenate = 'false' ]/style:paragraph-properties/@fo:hyphenation-ladder-count
	"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-empty-format-nodes" match="
		style:paragraph-properties | style:tab-stops
		| style:text-properties
	">
		<xsl:apply-templates select="." mode="o:where-attributes-or-elements"/>
	</xsl:template>

	<xsl:template mode="o:optimize" use-when="$o:remove-empty-format-nodes" match="
		style:text-properties[ @fo:hyphenate = 'false' ]/@fo:hyphenation-remain-char-count
		| style:text-properties[ @fo:hyphenate = 'false' ]/@fo:hyphenation-push-char-count
	"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-empty-format-nodes" match="
		*[ @draw:fill = 'none' ]/@draw:fill-color
	"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-abs-size-when-relative" match="
		*[ @style:rel-width ]/@svg:width
		| *[ @style:rel-height ]/@svg:height
		| *[ @style:vertical-rel ]/@svg:y
		| *[ @style:horizontal-rel ]/@svg:x
	"/>

	<?endregion удаляем лишние элементы ?>
	<?region удаляем некоторые файлы из манифеста ?>

	<xsl:template mode="o:optimize" use-when="$o:remove-unimportant-files" match="manifest:file-entry[ @manifest:full-path = 'layout-cache' ]"/>

	<?endregion удаляем некоторые файлы из манифеста ?>
	<?region удаляем thumbnails ?>

	<xsl:template mode="o:optimize" use-when="$o:remove-thumbnails" match="manifest:file-entry[ @manifest:full-path = 'Thumbnails/thumbnail.png' ]"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-thumbnails" match="
		config:config-item[ @config:name = 'SaveThumbnail' ]/text()
	">
		<xsl:value-of select=" false() "/>
	</xsl:template>

	<?endregion удаляем thumbnails ?>
	<?region исправляем `@manifest:media-type` в манифесте для раздела Configurations2 ?>

	<xsl:template mode="o:optimize" use-when="$o:fix-manifest" match="
		/manifest:manifest/manifest:file-entry[
			( @manifest:media-type = '' )
			and ( starts-with( @manifest:full-path, 'Configurations2/' ) and ends-with( @manifest:full-path, '.xml' ) )
		]/@manifest:media-type
	">
		<xsl:attribute name="manifest:media-type" select=" 'text/xml' "/>
	</xsl:template>

	<xsl:template mode="o:optimize" use-when="$o:fix-manifest" match="
		/manifest:manifest/manifest:file-entry[
			( @manifest:media-type = '' )
			and ( starts-with( @manifest:full-path, 'Configurations2/images/Bitmaps/' ) and ends-with( @manifest:full-path, '.png' ) )
		]/@manifest:media-type
	">
		<xsl:attribute name="manifest:media-type" select=" 'image/png' "/>
	</xsl:template>

	<?endregion исправляем `@manifest:media-type` в манифесте для раздела Configurations2 ?>
	<?region удаляем доступные на рабочих станциях шрифты из встроенных в шаблон ?>

	<xsl:variable name="o:common-fonts" as="map( xs:string, xs:boolean )" static="yes" visibility="private" select='
		map:merge(
			for $font-name in (
				"Liberation Mono", "Segoe UI", "Tahoma", "Times New Roman"
			) return map:entry( concat( "&apos;", $font-name, "&apos;" ), true() )
		)
	'/>

	<xsl:key name="o:common-font-face-uris" use-when="$o:remove-common-embedded-fonts"
		match="office:font-face-decls/style:font-face[
			map:contains( $o:common-fonts, @svg:font-family )
		]/svg:font-face-src/svg:font-face-uri"
		use="@xlink:href"
	/>

	<xsl:template mode="o:optimize" use-when="$o:remove-common-embedded-fonts" match="
		office:font-face-decls/style:font-face[
			map:contains( $o:common-fonts, @svg:font-family )
		]/svg:font-face-src
	"/>
	<xsl:template mode="o:optimize" use-when="$o:remove-common-embedded-fonts" match="
		manifest:file-entry[ key( 'o:common-font-face-uris', @manifest:full-path ) ]
	"/>

	<?endregion удаляем доступные на рабочих станциях шрифты из встроенных в шаблон ?>
	<?region удаляем некоторые параметры конфигурации просмотра и печати ?>

	<xsl:variable name="o:removed-config-params" as="map( xs:string, xs:boolean )" static="yes" visibility="private" select='
		map:merge(
			for $config-param in (
				"PrinterName", "PrintFaxName", "PrinterSetup", "PrinterPaperFromSetup", "PrintPaperFromSetup",
				"PrintSingleJobs", "PrinterIndependentLayout", "AllowPrintJobCancel"
			) return map:entry( $config-param, true() )
		)
	'/>

	<xsl:template mode="o:optimize" use-when="$o:remove-config-view-params" match="
		config:config-item-set[ @config:name = 'ooo:view-settings' ]
	"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-config-print-params" match="
		config:config-item[ map:contains( $o:removed-config-params, @config:name ) ]
	"/>

	<?endregion удаляем некоторые параметры конфигурации просмотра и печати ?>
	<?region удаляем некоторые несущественные элементы ?>

	<xsl:template mode="o:optimize" use-when="$o:remove-soft-page-breaks" match="text:soft-page-break"/>

	<?endregion удаляем некоторые несущественные элементы ?>
	<?region удаляем лишние аттрибуты ?>

	<xsl:template mode="o:optimize" use-when="$o:remove-foreign-language-attributes" match="(
		@style:language-asian | @style:language-complex
		| @style:country-asian | @style:country-complex
		| @style:font-name-asian | @style:font-family-asian | @style:font-family-generic-asian
		| @style:font-style-asian | @style:font-pitch-asian| @style:font-size-asian | @style:font-weight-asian
		| @style:font-name-complex | @style:font-family-complex | @style:font-family-generic-complex
		| @style:font-style-complex | @style:font-pitch-complex | @style:font-size-complex | @style:font-weight-complex
		| @style:writing-mode
	)"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-foreign-language-attributes" match="(
		office:automatic-styles/style:style/style:text-properties/@fo:language
		| office:automatic-styles/style:style/style:text-properties/@fo:country
	)"/>

	<?endregion удаляем лишние аттрибуты ?>
	<?region удаляем параметры разметки страницы при отключенной разметке ?>

	<xsl:template mode="o:optimize" use-when="$o:remove-layout-params" match="
		style:page-layout-properties[ @style:layout-grid-mode = 'none' ]/@style:layout-grid-color"/>
	<xsl:template mode="o:optimize" use-when="$o:remove-layout-params" match="
		style:page-layout-properties[ @style:layout-grid-mode = 'none' ]/@style:layout-grid-lines"/>
	<xsl:template mode="o:optimize" use-when="$o:remove-layout-params" match="
		style:page-layout-properties[ @style:layout-grid-mode = 'none' ]/@style:layout-grid-base-height"/>
	<xsl:template mode="o:optimize" use-when="$o:remove-layout-params" match="
		style:page-layout-properties[ @style:layout-grid-mode = 'none' ]/@style:layout-grid-ruby-height"/>
	<xsl:template mode="o:optimize" use-when="$o:remove-layout-params" match="
		style:page-layout-properties[ @style:layout-grid-mode = 'none' ]/@style:layout-grid-ruby-below"/>
	<xsl:template mode="o:optimize" use-when="$o:remove-layout-params" match="
		style:page-layout-properties[ @style:layout-grid-mode = 'none' ]/@style:layout-grid-print"/>
	<xsl:template mode="o:optimize" use-when="$o:remove-layout-params" match="
		style:page-layout-properties[ @style:layout-grid-mode = 'none' ]/@style:layout-grid-display"/>

	<?endregion удаляем параметры разметки страницы при отключенной разметке ?>
	<?region удаляем аттрибуты со значениями по умолчанию ?>

	<xsl:template mode="o:optimize" use-when="$o:remove-attributes-with-default-values" match="(
		@style:auto-update[ . = 'false' ]
		| @style:display[ . = 'true' ]
		| @style:leader-char[ . = ' ' ]
		| @style:num-letter-sync[ . = 'false' ]
		| @style:type[ . = 'left' ]
		| @style:vertical-align[ . = 'top' ]
		| @style:auto-update[ . = 'false' ]
		| text:variable-set/@text:display[ . = 'value' ]
		| text:variable-get/@text:display[ . = 'value' ]
		| @number:display-factor[ . = '1' ]
		| @number:grouping[ . = 'false' ]
		| @number:transliteration-format[ . = '1' ]
		| @number:transliteration-style[ . = 'short' ]
		| office:annotation/@office:display[ . = 'false' ]
		| @table:number-columns-repeated[ . = '1' ]
		| @table:number-columns-spanned[ . = '1' ]
		| @table:number-rows-spanned[ . = '1' ]
		| @table:protected[ . = 'false' ]
		| @table:number-rows-repeated[ . = '1' ]
		| @table:structure-protected[ . = 'false' ]
		| @table:value-type[ . = 'string' ]
		| @table:visibility[ . = 'visible' ]
		| @text:c[ . = '1' ]
		| @text:consecutive-numbering[ . = 'false' ]
		| @text:index-scope[ . = 'document' ]
		| @text:protected[ . = 'false' ]
		| @text:relative-tab-stop-position[ . = 'true' ]
		| @text:restart-numbering[ . = 'false' ]
		| @text:start-value[ . = '1' ]
		| @text:use-outline-level[ . = 'true' ]
		| @text:use-index-source-styles[ . = 'false' ]
		| text:hidden-paragraph/@text:is-hidden[ . = 'false' ]
		| text:section/@text:display[ . = 'true' ]
		| text:index-entry-chapter/@text:display[ . = 'number-and-name' ]
		| text:index-entry-tab-stop/@style:with-tab[ . = 'true' ]
		| text:h/@text:level[ . = '1' ]
		| toolbar:toolbaritem/@toolbar:visible[ . = 'true' ]
		| @xlink:actuate[ . = 'onRequest' ]
		| @xlink:show[ . = 'embed' ]
		| @style:auto-update[ . = 'false' ]
	)"/>

	<?endregion удаляем аттрибуты со значениями по умолчанию ?>
	<?region удаляем упоминания о сессии, в которой внесены изменения ?>

	<xsl:template mode="o:optimize" use-when="$o:remove-rsid" match="(
		style:text-properties/@officeooo:paragraph-rsid
		| style:text-properties/@officeooo:rsid
	)"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-rsid" match="
		config:config-item[ @config:name = 'Rsid' ]
	"/>

	<?endregion удаляем упоминания о сессии, в которой внесены изменения ?>
	<?region правила для элементов с сортировкой потомков (для минимизации изменений при сохранении OO файлов) ?>

	<xsl:template mode="o:optimize" use-when="$o:sort-sortable-nodes" match="office:font-face-decls">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="#current"/>
			<xsl:apply-templates select="style:font-face" mode="#current">
				<xsl:sort select="@style:name" data-type="text" order="ascending" case-order="upper-first" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template mode="o:optimize" use-when="$o:sort-sortable-nodes" match="manifest:manifest">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="#current"/>
			<xsl:apply-templates select="manifest:file-entry" mode="#current">
				<xsl:sort select="@manifest:full-path" data-type="text" order="ascending" case-order="upper-first" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<xsl:template mode="o:optimize" use-when="$o:sort-sortable-nodes" match="text:variable-decls">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="#current"/>
			<xsl:apply-templates select="text:variable-decl" mode="#current">
				<xsl:sort select="@text:name" data-type="text" order="ascending" case-order="upper-first" />
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:template>

	<?endregion правила для элементов с сортировкой потомков (для минимизации изменений при сохранении OO файлов) ?>
	<?region сброс номера страницы в колонтитулах мастер-страниц ?>

	<xsl:template mode="o:optimize" use-when="$o:reset-page-number-in-headers-and-footers" match="
		style:master-page//text:page-number[ @text:select-page = 'current' ]/text()
	">
		<xsl:text>0</xsl:text>
	</xsl:template>

	<?endregion сброс номера страницы в колонтитулах мастер-страниц ?>
	<?region удаление из meta.xml вычисляемых при сборке метаданных ?>

	<xsl:template mode="o:optimize" use-when="$o:remove-calculated-meta" match="
		office:meta/meta:editing-cycles
		| office:meta/meta:editing-duration
		| office:meta/meta:document-statistic
		| office:meta/dc:date
	"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-print-meta" match="
		office:meta/meta:printed-by
		| office:meta/meta:print-date
	"/>

	<xsl:template mode="o:optimize" use-when="$o:remove-generator-meta" match="office:meta/meta:generator"/>

	<?endregion удаление из meta.xml вычисляемых при сборке метаданных ?>

</xsl:package>
