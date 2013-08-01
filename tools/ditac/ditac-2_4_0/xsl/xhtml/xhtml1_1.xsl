<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2009-2013 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs"
                version="2.0">

  <xsl:import href="xhtmlBase.xsl"/>

  <!-- Output ============================================================ -->

  <xsl:param name="xhtmlVersion" select="'1.1'"/>

  <!-- Specify the output encoding here and also below. -->
  <xsl:param name="xhtmlEncoding" select="'UTF-8'"/>

  <xsl:output method="xhtml" encoding="UTF-8"
    doctype-public="-//W3C//DTD XHTML 1.1//EN"
    doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>

</xsl:stylesheet>
