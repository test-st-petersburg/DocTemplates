<?xml version="1.0" encoding="UTF-8"?><xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"

	xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0"

	xmlns:p="http://github.com/test-st-petersburg/DocTemplates/tools/xslt/OODocumentProcessor"
>

	<xsl:variable name="manifest:version" as="xs:string" static="yes" select="'1.2'" visibility="private"/>
	<xsl:variable name="p:manifest-uri" as="xs:anyURI" static="yes" select="xs:anyURI( 'META-INF/manifest.xml' )" visibility="private"/>
	<xsl:variable name="p:manifest-binary-uri" as="xs:anyURI" static="yes" select="xs:anyURI( 'META-INF/manifest.binary.xml' )" visibility="private"/>

	<xsl:variable name="p:basic-script-module-in-container-media-type" as="xs:string" static="yes" select="'text/xml'" visibility="private"/>
	<xsl:variable name="p:basic-script-module-in-container-file-name-ext" as="xs:string" static="yes" select="'.xml'" visibility="private"/>
	<xsl:variable name="p:basic-script-lib-in-container-media-type" as="xs:string" static="yes" select="'text/xml'" visibility="private"/>
	<xsl:variable name="p:basic-script-lib-in-container-uri" as="xs:anyURI" static="yes" select="xs:anyURI( 'script-lb.xml' )" visibility="private"/>
	<xsl:variable name="p:basic-script-container-media-type" as="xs:string" static="yes" select="'text/xml'" visibility="private"/>
	<xsl:variable name="p:basic-script-container-uri" as="xs:anyURI" static="yes" select="xs:anyURI( 'script-lc.xml' )" visibility="private"/>

	<xsl:variable name="p:basic-script-module-media-type" as="xs:string" static="yes" select="'text/xml'" visibility="private"/>
	<xsl:variable name="p:basic-script-module-file-name-ext" as="xs:string" static="yes" select="'.xba'" visibility="private"/>
	<xsl:variable name="p:basic-script-lib-media-type" as="xs:string" static="yes" select="'text/xml'" visibility="private"/>
	<xsl:variable name="p:basic-script-lib-uri" as="xs:anyURI" static="yes" select="xs:anyURI( 'script.xlb' )" visibility="private"/>

</xsl:transform>
