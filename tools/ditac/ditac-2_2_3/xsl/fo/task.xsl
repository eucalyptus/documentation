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
                xmlns:xfc="http://www.xmlmind.com/foconverter/xsl/extensions"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                exclude-result-prefixes="xs u"
                version="2.0">
  
  <!-- task LIKE topic -->
  <!-- taskbody LIKE body -->

  <!-- prereq ============================================================ -->

  <xsl:attribute-set name="prereq" use-attribute-sets="section">
  </xsl:attribute-set>

  <xsl:attribute-set name="prereq-title" use-attribute-sets="section-title">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/prereq ')]">
    <fo:block xsl:use-attribute-sets="prereq">
      <xsl:call-template name="commonAttributes"/>

      <fo:block xsl:use-attribute-sets="prereq-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'prereq'"/>
        </xsl:call-template>
      </fo:block>

      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- context =========================================================== -->

  <xsl:attribute-set name="context" use-attribute-sets="section">
  </xsl:attribute-set>

  <xsl:attribute-set name="context-title" use-attribute-sets="section-title">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/context ')]">
    <fo:block xsl:use-attribute-sets="context">
      <xsl:call-template name="commonAttributes"/>

      <fo:block xsl:use-attribute-sets="context-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'context'"/>
        </xsl:call-template>
      </fo:block>

      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- steps-informal ==================================================== -->

  <xsl:attribute-set name="steps-informal" use-attribute-sets="section">
  </xsl:attribute-set>

  <xsl:attribute-set name="steps-informal-title" 
                     use-attribute-sets="section-title">
  </xsl:attribute-set>

  <xsl:attribute-set name="step-informal-content" 
                     use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/steps-informal ')]">
    <fo:block xsl:use-attribute-sets="steps-informal">
      <xsl:call-template name="commonAttributes"/>

      <fo:block xsl:use-attribute-sets="steps-informal-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'steps'"/>
        </xsl:call-template>
      </fo:block>

      <fo:block xsl:use-attribute-sets="step-informal-content">
        <xsl:apply-templates/>
      </fo:block>
    </fo:block>
  </xsl:template>

  <!-- steps ============================================================= -->

  <xsl:attribute-set name="steps" use-attribute-sets="section">
  </xsl:attribute-set>

  <xsl:attribute-set name="steps-title" use-attribute-sets="section-title">
  </xsl:attribute-set>

  <xsl:attribute-set name="step-list" use-attribute-sets="ol">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/steps ')]">
    <fo:block xsl:use-attribute-sets="steps">
      <xsl:call-template name="commonAttributes"/>

      <fo:block xsl:use-attribute-sets="steps-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'steps'"/>
        </xsl:call-template>
      </fo:block>

      <fo:list-block xsl:use-attribute-sets="step-list">
        <xsl:call-template name="xfcOLLabelFormat"/>

        <xsl:apply-templates/>
      </fo:list-block>
    </fo:block>
  </xsl:template>

  <!-- steps-unordered =================================================== -->

  <xsl:attribute-set name="steps-unordered" use-attribute-sets="section">
  </xsl:attribute-set>

  <xsl:attribute-set name="unordered-step-list" use-attribute-sets="ul">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/steps-unordered ')]">
    <fo:block xsl:use-attribute-sets="steps-unordered">
      <xsl:call-template name="commonAttributes"/>

      <fo:block xsl:use-attribute-sets="steps-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'steps'"/>
        </xsl:call-template>
      </fo:block>

      <fo:list-block xsl:use-attribute-sets="unordered-step-list">
        <xsl:call-template name="xfcULLabelFormat">
          <xsl:with-param name="class" select="' task/steps-unordered '"/>
          <xsl:with-param name="bullets" select="$unorderedStepBullets"/>
        </xsl:call-template>

        <xsl:apply-templates/>
      </fo:list-block>
    </fo:block>
  </xsl:template>

  <!-- stepsection ======================================================= -->

  <xsl:attribute-set name="stepsection" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/stepsection ')]">
    <fo:list-item xsl:use-attribute-sets="stepsection">
      <xsl:call-template name="commonAttributes"/>

      <fo:list-item-label end-indent="label-end()">
        <fo:block text-align="end">&#xA0;</fo:block>
      </fo:list-item-label>

      <fo:list-item-body start-indent="body-start()">
        <fo:block>
          <xsl:apply-templates/>
        </fo:block>
      </fo:list-item-body>
    </fo:list-item>
  </xsl:template>

  <!-- step ============================================================== -->

  <xsl:attribute-set name="step" use-attribute-sets="ol-li">
  </xsl:attribute-set>

  <xsl:attribute-set name="compact-step" use-attribute-sets="compact-ol-li">
  </xsl:attribute-set>

  <xsl:attribute-set name="step-label" use-attribute-sets="ol-li-label">
  </xsl:attribute-set>

  <xsl:attribute-set name="unordered-step" use-attribute-sets="ul-li">
  </xsl:attribute-set>

  <xsl:attribute-set name="compact-unordered-step"
                     use-attribute-sets="compact-ul-li">
  </xsl:attribute-set>

  <xsl:attribute-set name="unordered-step-label"
                     use-attribute-sets="ul-li-label">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/steps ')]/*[contains(@class,' task/step ')]">
    <xsl:choose>
      <xsl:when test="u:isCompactSteps(parent::*)">
        <fo:list-item xsl:use-attribute-sets="compact-step">
          <xsl:call-template name="orderedListItem"/>
        </fo:list-item>
      </xsl:when>
      <xsl:otherwise>
        <fo:list-item xsl:use-attribute-sets="step">
          <xsl:call-template name="orderedListItem"/>
        </fo:list-item>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[contains(@class,' task/steps-unordered ')]/*[contains(@class,' task/step ')]">
    <xsl:choose>
      <xsl:when test="u:isCompactSteps(parent::*)">
        <fo:list-item xsl:use-attribute-sets="compact-unordered-step">
          <xsl:call-template name="listItem">
            <xsl:with-param name="class" select="' task/steps-unordered '"/>
            <xsl:with-param name="bullets" select="$unorderedStepBullets"/>
          </xsl:call-template>
        </fo:list-item>
      </xsl:when>
      <xsl:otherwise>
        <fo:list-item xsl:use-attribute-sets="unordered-step">
          <xsl:call-template name="listItem">
            <xsl:with-param name="class" select="' task/steps-unordered '"/>
            <xsl:with-param name="bullets" select="$unorderedStepBullets"/>
          </xsl:call-template>
        </fo:list-item>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="u:isCompactSteps" as="xs:boolean">
    <xsl:param name="parent" as="element()"/>

    <xsl:choose>
      <xsl:when
          test="exists($parent/*[contains(@class,' task/stepsection ')] |
                       $parent/*/*[contains(@class,' task/info ') or 
                                   contains(@class,' task/substeps ') or 
                                   contains(@class,' task/tutorialinfo ') or 
                                   contains(@class,' task/stepxmp ') or 
                                   contains(@class,' task/choicetable ') or 
                                   contains(@class,' task/choices ') or 
                                   contains(@class,' task/stepresult ')
                                  ])"
          ><xsl:sequence select="false()"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="true()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- cmd =============================================================== -->

  <xsl:attribute-set name="cmd">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/cmd ')]">
    <fo:inline xsl:use-attribute-sets="cmd">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:inline>
  </xsl:template>

  <!-- info ============================================================== -->

  <xsl:attribute-set name="info" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/info ')]">
    <fo:block xsl:use-attribute-sets="info">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- substeps ========================================================== -->

  <xsl:attribute-set name="substeps" use-attribute-sets="step-list">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/substeps ')]">
    <fo:list-block xsl:use-attribute-sets="substeps">
      <xsl:call-template name="xfcOLLabelFormat">
        <xsl:with-param name="format" select="'a.'"/>
      </xsl:call-template>

      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:list-block>
  </xsl:template>

  <!-- substep =========================================================== -->

  <xsl:attribute-set name="substep" use-attribute-sets="step">
  </xsl:attribute-set>

  <xsl:attribute-set name="compact-substep" use-attribute-sets="compact-step">
  </xsl:attribute-set>

  <xsl:attribute-set name="substep-label" use-attribute-sets="step-label">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/substep ')]">
    <xsl:choose>
      <xsl:when test="u:isCompactSteps(parent::*)">
        <fo:list-item xsl:use-attribute-sets="compact-substep">
          <xsl:call-template name="orderedListItem">
            <xsl:with-param name="format">a.</xsl:with-param>
          </xsl:call-template>
        </fo:list-item>
      </xsl:when>
      <xsl:otherwise>
        <fo:list-item xsl:use-attribute-sets="substep">
          <xsl:call-template name="orderedListItem">
            <xsl:with-param name="format">a.</xsl:with-param>
          </xsl:call-template>
        </fo:list-item>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- choicetable LIKE simpletable -->

  <!-- chhead ========================================================== -->

  <xsl:attribute-set name="chhead" use-attribute-sets="sthead">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/chhead ')]">
    <fo:table-row xsl:use-attribute-sets="chhead">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:table-row>
  </xsl:template>

  <!-- choptionhd ======================================================= -->

  <xsl:attribute-set name="choptionhd" use-attribute-sets="header-stentry">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/choptionhd ')]">
    <fo:table-cell start-indent="0" xsl:use-attribute-sets="choptionhd">
      <xsl:call-template name="commonAttributes"/>
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <!-- chdeschd ======================================================== -->

  <xsl:attribute-set name="chdeschd" use-attribute-sets="header-stentry">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/chdeschd ')]">
    <fo:table-cell start-indent="0" xsl:use-attribute-sets="chdeschd">
      <xsl:call-template name="commonAttributes"/>
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <!-- chrow ========================================================== -->

  <xsl:attribute-set name="chrow" use-attribute-sets="strow">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/chrow ')]">
    <fo:table-row xsl:use-attribute-sets="chrow">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:table-row>
  </xsl:template>

  <!-- choption ========================================================= -->

  <xsl:attribute-set name="choption" use-attribute-sets="stentry">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/choption ')]">
    <fo:table-cell start-indent="0" xsl:use-attribute-sets="choption">
      <xsl:call-template name="commonAttributes"/>
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <!-- chdesc ========================================================== -->

  <xsl:attribute-set name="chdesc" use-attribute-sets="stentry">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/chdesc ')]">
    <fo:table-cell start-indent="0" xsl:use-attribute-sets="chdesc">
      <xsl:call-template name="commonAttributes"/>
      <fo:block>
        <xsl:apply-templates/>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <!-- choices ========================================================== -->

  <xsl:attribute-set name="choices" use-attribute-sets="ul">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/choices ')]">
    <fo:list-block xsl:use-attribute-sets="choices">
      <xsl:call-template name="xfcULLabelFormat">
        <xsl:with-param name="class" select="' task/choices '"/>
        <xsl:with-param name="bullets" select="$choiceBullets"/>
      </xsl:call-template>

      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:list-block>
  </xsl:template>

  <!-- choice =========================================================== -->

  <xsl:attribute-set name="choice" use-attribute-sets="ul-li">
  </xsl:attribute-set>

  <xsl:attribute-set name="choice-label" use-attribute-sets="ul-li-label">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/choice ')]">
    <fo:list-item xsl:use-attribute-sets="choice">
      <xsl:call-template name="listItem">
        <xsl:with-param name="class" select="' task/choices '"/>
        <xsl:with-param name="bullets" select="$choiceBullets"/>
      </xsl:call-template>
    </fo:list-item>
  </xsl:template>

  <!-- tutorialinfo ====================================================== -->

  <xsl:attribute-set name="tutorialinfo" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/tutorialinfo ')]">
    <fo:block xsl:use-attribute-sets="tutorialinfo">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- stepxmp =========================================================== -->

  <xsl:attribute-set name="stepxmp" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/stepxmp ')]">
    <fo:block xsl:use-attribute-sets="stepxmp">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- stepresult ======================================================== -->

  <xsl:attribute-set name="stepresult" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/stepresult ')]">
    <fo:block xsl:use-attribute-sets="stepresult">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- result ============================================================ -->

  <xsl:attribute-set name="result" use-attribute-sets="section">
  </xsl:attribute-set>

  <xsl:attribute-set name="result-title" use-attribute-sets="section-title">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/result ')]">
    <fo:block xsl:use-attribute-sets="result">
      <xsl:call-template name="commonAttributes"/>

      <fo:block xsl:use-attribute-sets="result-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'result'"/>
        </xsl:call-template>
      </fo:block>

      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- postreq =========================================================== -->

  <xsl:attribute-set name="postreq" use-attribute-sets="section">
  </xsl:attribute-set>

  <xsl:attribute-set name="postreq-title" use-attribute-sets="section-title">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' task/postreq ')]">
    <fo:block xsl:use-attribute-sets="postreq">
      <xsl:call-template name="commonAttributes"/>

      <fo:block xsl:use-attribute-sets="postreq-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'postreq'"/>
        </xsl:call-template>
      </fo:block>

      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>
