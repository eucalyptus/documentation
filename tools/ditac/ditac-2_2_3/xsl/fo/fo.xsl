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

  <!-- Import (do not include) files in that order: 
       first generic elements (e.g. body.xsl) then specialized elements 
       (e.g. typographic.xsl). -->

  <xsl:import href="../common/ditacUtil.xsl"/>
  <xsl:import href="../common/commonParams.xsl"/>
  <xsl:import href="foParams.xsl"/>
  <xsl:import href="../common/commonUtil.xsl"/>
  <xsl:import href="foUtil.xsl"/>
  <xsl:import href="pagination.xsl"/>
  <xsl:import href="pdfOutline.xsl"/>

  <xsl:import href="topic.xsl"/>
  <xsl:import href="body.xsl"/>
  <xsl:import href="simpleTable.xsl"/>
  <xsl:import href="table.xsl"/>
  <xsl:import href="prolog.xsl"/>
  <xsl:import href="relatedLinks.xsl"/>
  <xsl:import href="miscellaneous.xsl"/>
  <xsl:import href="specialization.xsl"/>

  <!-- No specific rules for concept elements. 
       Examples: conbody LIKE body, conbodydiv LIKE bodydiv, etc. -->
  <xsl:import href="reference.xsl"/>
  <xsl:import href="task.xsl"/>
  <xsl:import href="glossary.xsl"/>

  <xsl:import href="typographic.xsl"/>
  <xsl:import href="programming.xsl"/>
  <xsl:import href="software.xsl"/>
  <xsl:import href="userInterface.xsl"/>
  <xsl:import href="utilities.xsl"/>
  <xsl:import href="hazardStatement.xsl"/>

  <xsl:import href="ditac_titlePage.xsl"/>
  <xsl:import href="ditac_toc.xsl"/>
  <xsl:import href="ditac_figureList.xsl"/>
  <xsl:import href="ditac_indexList.xsl"/>
  <xsl:import href="ditac_chunk.xsl"/>
  <xsl:import href="ditac_anchor.xsl"/>
  <xsl:import href="ditac_flags.xsl"/>

  <!-- ``System parameters'' automatically specified by the application hosting
       ditac. -->
  <xsl:param name="outputFormat" select="''"/>

  <!-- If the name of the system property is in the null namespace, Saxon
       returns the value of the Java system property whose name matches the
       local name. -->

  <xsl:param name="foProcessor"
    select="if ($outputFormat eq 'pdf' or $outputFormat eq 'ps') then
                if (contains(system-property('XSL_FO_PROCESSORS'),
                                             'AHF')) then
                    'AHF'
                else
                  if (contains(system-property('XSL_FO_PROCESSORS'),
                                               'XEP')) then
                      'XEP'
                  else
                      if (contains(system-property('XSL_FO_PROCESSORS'),
                                                   'FOP')) then
                          'FOP'
                      else
                          ''
            else
                if ($outputFormat eq 'rtf' or 
                    $outputFormat eq 'wml' or 
                    $outputFormat eq 'docx' or 
                    $outputFormat eq 'odt') then
                    if (contains(system-property('XSL_FO_PROCESSORS'),
                                                 'XFC')) then
                        'XFC'
                    else
                        ''
                else
                    ''"/>

  <!-- Output ============================================================ -->

  <xsl:output method="xml" encoding="UTF-8" indent="no"/>

  <!-- Keys ============================================================== -->

  <xsl:key name="footnoteXref"
           match="*[contains(@class,' topic/xref ') and @type = 'fn']" 
           use="substring-after(@href, '#')"/>

  <!-- =======================================================================
    Base, abstract and mixin styles

    * Styles are similar to those found in the default CSS (where 1em=2ex).
    * Verbatim blocks always have a 0.25em padding.
      (margin-left=margin-right=1pt is a trick to compensate 
      for the extra width.)
    * Table cells always have a 0.2em padding.
    * Table borders are always "0.5pt solid #404040".
    * Shaded table headers always have a #E0E0E0 background.
  ======================================================================== -->

  <xsl:attribute-set name="base-style">
    <xsl:attribute name="font-family" select="$body-font-family"/>
    <xsl:attribute name="font-size" select="$base-font-size"/>
    <xsl:attribute name="line-height">1.2</xsl:attribute>
    <xsl:attribute name="text-align"
                  select="if ($justified = 'yes') then 'justify' else 'left'"/>
  </xsl:attribute-set>

  <xsl:attribute-set name="monospace-style">
    <xsl:attribute name="font-family">monospace</xsl:attribute>
    <xsl:attribute name="font-size">90%</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="link-style">
    <xsl:attribute name="color">#404080</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="caption-style">
    <xsl:attribute name="hyphenate">false</xsl:attribute>
    <xsl:attribute name="font-style">italic</xsl:attribute>
    <xsl:attribute name="space-before.optimum">0.5em</xsl:attribute>
    <xsl:attribute name="space-before.minimum">0.4em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">0.6em</xsl:attribute>
    <xsl:attribute name="space-after.optimum">0.5em</xsl:attribute>
    <xsl:attribute name="space-after.minimum">0.4em</xsl:attribute>
    <xsl:attribute name="space-after.maximum">0.6em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="block-style">
    <xsl:attribute name="space-before.optimum">0.75em</xsl:attribute>
    <xsl:attribute name="space-before.minimum">0.6em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">0.9em</xsl:attribute>
    <xsl:attribute name="space-after.optimum">0.75em</xsl:attribute>
    <xsl:attribute name="space-after.minimum">0.6em</xsl:attribute>
    <xsl:attribute name="space-after.maximum">0.9em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="semi-compact-block-style">
    <xsl:attribute name="space-before.optimum">0.25em</xsl:attribute>
    <xsl:attribute name="space-before.minimum">0em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>
    <xsl:attribute name="space-after.optimum">0.25em</xsl:attribute>
    <xsl:attribute name="space-after.minimum">0em</xsl:attribute>
    <xsl:attribute name="space-after.maximum">0.5em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="compact-block-style">
    <xsl:attribute name="space-before.optimum">0em</xsl:attribute>
    <xsl:attribute name="space-before.minimum">0em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">0.2em</xsl:attribute>
    <xsl:attribute name="space-after.optimum">0em</xsl:attribute>
    <xsl:attribute name="space-after.minimum">0em</xsl:attribute>
    <xsl:attribute name="space-after.maximum">0.2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="monospace-block-style"
                     use-attribute-sets="monospace-style block-style">
    <xsl:attribute name="white-space">pre</xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="hyphenate">false</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="display-style">
    <xsl:attribute name="space-before.optimum">1.5em</xsl:attribute>
    <xsl:attribute name="space-before.minimum">1em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">2em</xsl:attribute>
    <xsl:attribute name="space-after.optimum">1.5em</xsl:attribute>
    <xsl:attribute name="space-after.minimum">1em</xsl:attribute>
    <xsl:attribute name="space-after.maximum">2em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="split-border-style">
    <!-- Split, do not repeat, border on page break. -->
    <xsl:attribute
        name="border-before-width.conditionality">discard</xsl:attribute>
    <xsl:attribute
        name="border-after-width.conditionality">discard</xsl:attribute>
  </xsl:attribute-set>

  <!-- / ================================================================= -->

  <xsl:template match="/">
    <fo:root>
      <xsl:call-template name="layoutMasterSet"/>
 
      <xsl:if test="$pdf-outline = 'yes'">
        <xsl:choose>
          <xsl:when test="$foProcessor eq 'XEP'">
            <xsl:call-template name="xepPDFOutline"/>
          </xsl:when>
          <xsl:when test="$foProcessor eq 'FOP' or $foProcessor eq 'AHF'">
            <xsl:call-template name="xsl11PDFOutline"/>
          </xsl:when>
        </xsl:choose>
      </xsl:if>

      <xsl:apply-templates/>
    </fo:root>
  </xsl:template>

</xsl:stylesheet>
