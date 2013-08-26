<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2009 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                exclude-result-prefixes="xs"
                version="2.0">
  
  <!-- imagemap ========================================================== -->

  <xsl:attribute-set name="imagemap"
                     use-attribute-sets="display-style split-border-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' ut-d/imagemap ')]">
    <fo:block xsl:use-attribute-sets="imagemap">
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="displayAttributes"/>
    <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- area ============================================================== -->

  <xsl:template match="*[contains(@class,' ut-d/area ')]"/>

  <!-- OMITTED: shape, coords -->

</xsl:stylesheet>
