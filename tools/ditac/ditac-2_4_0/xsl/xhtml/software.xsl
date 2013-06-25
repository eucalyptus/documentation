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
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="xs"
                version="2.0">

  <!-- msgph ============================================================= -->

  <xsl:template match="*[contains(@class,' sw-d/msgph ')]">
    <samp>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </samp>
  </xsl:template>

  <!-- msgblock ========================================================== -->

  <xsl:template match="*[contains(@class,' sw-d/msgblock ')]">
    <pre>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="displayAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </pre>
  </xsl:template>

  <!-- msgnum ============================================================ -->

  <xsl:template match="*[contains(@class,' sw-d/msgnum ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- cmdname =========================================================== -->

  <xsl:template match="*[contains(@class,' sw-d/cmdname ')]">
    <code>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </code>
  </xsl:template>

  <!-- varname =========================================================== -->

  <xsl:template match="*[contains(@class,' sw-d/varname ')]">
    <var>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </var>
  </xsl:template>

  <!-- filepath =========================================================== -->

  <xsl:template match="*[contains(@class,' sw-d/filepath ')]">
    <code>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </code>
  </xsl:template>

  <!-- userinput ========================================================= -->

  <xsl:template match="*[contains(@class,' sw-d/userinput ')]">
    <kbd>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </kbd>
  </xsl:template>

  <!-- systemoutput ====================================================== -->

  <xsl:template match="*[contains(@class,' sw-d/systemoutput ')]">
    <samp>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </samp>
  </xsl:template>

</xsl:stylesheet>
