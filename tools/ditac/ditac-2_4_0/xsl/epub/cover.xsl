<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2013 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:URI="java:com.xmlmind.ditac.xslt.URI"
                exclude-result-prefixes="xs u URI"
                version="2.0">

  <!-- See Best practices in ePub cover images:
       http://blog.threepress.org/2009/11/20/
           best-practices-in-epub-cover-images/ -->

  <xsl:template name="generateCover">
    <xsl:param name="basename" select="''"/>

    <xsl:call-template name="copyCoverImage"/>

    <xsl:result-document href="{resolve-uri($basename, base-uri())}"
                         format="{if ($xhtmlVersion eq '5.0') 
                                  then 'outputFormatXHTML5'
                                  else 'outputFormatXHTML1_1'}">

      <xsl:if test="$xhtmlVersion eq '5.0'">
        <xsl:text
            disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&#xA;</xsl:text>
      </xsl:if>

      <html xml:lang="{u:documentLang()}">
        <head>
          <xsl:if test="$xhtmlVersion eq '5.0'">
            <meta charset="UTF-8"/>
          </xsl:if>
          <title><xsl:value-of select="u:localize('cover', .)"/></title>
          <style type="text/css">img { max-width: 100%; }</style>
        </head>

        <body>

          <div id="cover-image">
            <img src="{$coverImageName}" alt="{u:documentTitle()}" />
          </div>
        </body>
      </html>
    </xsl:result-document>
  </xsl:template>

  <xsl:template name="copyCoverImage">
    <xsl:variable name="srcURI" 
                  select="resolve-uri($cover-image, URI:userDirectory())" />
    <xsl:variable name="dstURI" 
                  select="resolve-uri($coverImageName, base-uri())" />

    <!-- A simple way to ensure that URI:copyFile is actually invoked. -->
    <xsl:message select="concat('&quot;', $srcURI, '&quot;: ', 
                         URI:copyFile($srcURI, $dstURI), 'bytes')" />
  </xsl:template>

</xsl:stylesheet>
