<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2009-2012 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs ditac"
                version="2.0">

  <xsl:template match="ditac:anchor">
    <fo:block id="{@xml:id}" hyphenate="false">
      <xsl:call-template name="addIndexAnchor">
        <xsl:with-param name="id" select="@xml:id"/>
      </xsl:call-template>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>