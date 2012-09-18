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
                exclude-result-prefixes="xs"
                version="2.0">
  
  <!-- abbreviated-form ================================================== -->

  <xsl:attribute-set name="abbreviated-form">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' abbrev-d/abbreviated-form ')]">
    <fo:inline xsl:use-attribute-sets="abbreviated-form">
      <xsl:call-template name="commonAttributes"/>
      <!-- The preprocessor may have generated content for 
           abbreviated-form which is normally empty. -->
      <xsl:call-template name="basicLink">
        <xsl:with-param name="href" select="string(@href)"/>
      </xsl:call-template>
    </fo:inline>
  </xsl:template>

  <!-- glossgroup LIKE topic -->

  <!-- glossentry ======================================================== -->

  <xsl:attribute-set name="glossentry" use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossentry ')]">
    <fo:block xsl:use-attribute-sets="glossentry">
      <xsl:call-template name="commonAttributes2"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- glossterm ========================================================= -->

  <xsl:attribute-set name="glossterm">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossterm ')]">
    <fo:block xsl:use-attribute-sets="glossterm">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- glossdef ========================================================== -->

  <xsl:attribute-set name="glossdef">
    <xsl:attribute name="margin-left">4em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossdef ')]">
    <fo:block xsl:use-attribute-sets="glossdef">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- glossBody ========================================================= -->

  <xsl:attribute-set name="glossBody" use-attribute-sets="block-style">
    <xsl:attribute name="margin-left">4em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="glossBody-properties" 
                     use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossBody ')]">
    <fo:block xsl:use-attribute-sets="glossBody">
      <xsl:call-template name="commonAttributes"/>

      <xsl:variable name="partOfSpeech" 
        select="./*[contains(@class,' glossentry/glossPartOfSpeech ')]"/>
      <xsl:variable name="status" 
        select="./*[contains(@class,' glossentry/glossStatus ')]"/>
      <xsl:variable name="property" 
        select="./*[contains(@class,' glossentry/glossProperty ')]"/>

      <xsl:if test="exists($partOfSpeech|$status|$property)">
        <fo:block xsl:use-attribute-sets="glossBody-properties">
          <xsl:for-each select="($partOfSpeech|$status|$property)">
            <xsl:apply-templates select="."/>
            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'periodSeparator'"/>
            </xsl:call-template>
          </xsl:for-each>
        </fo:block>
      </xsl:if>

      <xsl:apply-templates
        select="./* except ($partOfSpeech|$status|$property)"/>
    </fo:block>
  </xsl:template>

  <!-- glossPartOfSpeech ================================================= -->

  <xsl:attribute-set name="glossPartOfSpeech">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossPartOfSpeech ')]">
    <fo:inline xsl:use-attribute-sets="glossPartOfSpeech">
      <xsl:call-template name="commonAttributes"/>
      <xsl:value-of select="normalize-space(string(@value))" />
    </fo:inline>
  </xsl:template>

  <!-- glossStatus ======================================================= -->

  <xsl:attribute-set name="glossStatus">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossStatus ')]">
    <fo:inline xsl:use-attribute-sets="glossStatus">
      <xsl:call-template name="commonAttributes"/>
      <xsl:value-of select="normalize-space(string(@value))" />
    </fo:inline>
  </xsl:template>

  <!-- glossProperty ===================================================== -->

  <xsl:attribute-set name="glossProperty">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossProperty ')]">
    <fo:inline xsl:use-attribute-sets="glossProperty">
      <xsl:call-template name="commonAttributes"/>
      <xsl:value-of select="normalize-space(string(@name))" />
      <xsl:call-template name="localize">
        <xsl:with-param name="message" select="'colonSeparator'"/>
      </xsl:call-template>
      <xsl:value-of select="normalize-space(string(@value))" />
    </fo:inline>
  </xsl:template>

  <!-- glossSurfaceForm ================================================== -->

  <xsl:attribute-set name="glossSurfaceForm" 
                     use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossSurfaceForm ')]">
    <fo:block xsl:use-attribute-sets="glossSurfaceForm">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- glossUsage ======================================================== -->

  <xsl:attribute-set name="glossUsage" 
                     use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossUsage ')]">
    <fo:block xsl:use-attribute-sets="glossUsage">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- glossScopeNote ==================================================== -->

  <xsl:attribute-set name="glossScopeNote" 
                     use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossScopeNote ')]">
    <fo:block xsl:use-attribute-sets="glossScopeNote">
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

  <!-- glossSymbol ======================================================= -->

  <xsl:attribute-set name="glossSymbol" 
                     use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossSymbol ')]">
    <fo:block xsl:use-attribute-sets="glossSymbol">
      <xsl:call-template name="commonAttributes"/>
      <xsl:if test="@align = 'left' or
                    @align = 'right' or
                    @align = 'center'">
        <xsl:attribute name="text-align" select="string(@align)"/>
      </xsl:if>
          
      <xsl:call-template name="imageToExternalGraphic"/>
    </fo:block>
  </xsl:template>

  <!-- glossAlt ========================================================== -->

  <xsl:attribute-set name="glossAlt" 
                     use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="glossAlt-properties" 
                     use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="glossAlt-variants" 
                     use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossAlt ')]">
    <fo:block xsl:use-attribute-sets="glossAlt">
      <xsl:call-template name="commonAttributes"/>

      <xsl:variable name="abbreviation" 
        select="./*[contains(@class,' glossentry/glossAbbreviation ')]"/>
      <xsl:variable name="acronym" 
        select="./*[contains(@class,' glossentry/glossAcronym ')]"/>
      <xsl:variable name="shortForm" 
        select="./*[contains(@class,' glossentry/glossShortForm ')]"/>
      <xsl:variable name="synonym" 
        select="./*[contains(@class,' glossentry/glossSynonym ')]"/>

      <xsl:variable name="status" 
        select="./*[contains(@class,' glossentry/glossStatus ')]"/>
      <xsl:variable name="property" 
        select="./*[contains(@class,' glossentry/glossProperty ')]"/>

      <xsl:variable name="alternateFor" 
        select="./*[contains(@class,' glossentry/glossAlternateFor ')]"/>

      <xsl:apply-templates
        select="($abbreviation|$acronym|$shortForm|$synonym)"/>

      <xsl:if test="exists($status|$property)">
        <fo:block xsl:use-attribute-sets="glossAlt-properties">
          <xsl:for-each select="($status|$property)">
            <xsl:apply-templates select="."/>
            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'periodSeparator'"/>
            </xsl:call-template>
          </xsl:for-each>
        </fo:block>
      </xsl:if>

      <xsl:apply-templates
        select="./* except ($abbreviation|$acronym|$shortForm|$synonym|$status|$property|$alternateFor)"/>

      <xsl:if test="exists($alternateFor)">
        <fo:block xsl:use-attribute-sets="glossAlt-variants">
          <fo:inline>
            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'alternateFor'"/>
            </xsl:call-template>
            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'colonSeparator'"/>
            </xsl:call-template>
          </fo:inline>

          <xsl:for-each select="$alternateFor">
            <xsl:apply-templates select="."/>
            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'periodSeparator'"/>
            </xsl:call-template>
          </xsl:for-each>
        </fo:block>
      </xsl:if>
    </fo:block>
  </xsl:template>

  <!-- glossAbbreviation ================================================= -->

  <xsl:attribute-set name="glossAbbreviation-container" 
                     use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="glossAbbreviation-label">
  </xsl:attribute-set>

  <xsl:attribute-set name="glossAlt-variant">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="glossAbbreviation"
                     use-attribute-sets="glossAlt-variant">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossAbbreviation ')]">
    <fo:block xsl:use-attribute-sets="glossAbbreviation-container">
      <fo:inline xsl:use-attribute-sets="glossAbbreviation-label">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'abbreviation'"/>
        </xsl:call-template>
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'colonSeparator'"/>
        </xsl:call-template>
      </fo:inline>

      <fo:inline xsl:use-attribute-sets="glossAbbreviation">
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </fo:inline>
    </fo:block>
  </xsl:template>

  <!-- glossAcronym ====================================================== -->

  <xsl:attribute-set name="glossAcronym-container" 
                     use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="glossAcronym-label">
  </xsl:attribute-set>

  <xsl:attribute-set name="glossAcronym"
                     use-attribute-sets="glossAlt-variant">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossAcronym ')]">
    <fo:block xsl:use-attribute-sets="glossAcronym-container">
      <fo:inline xsl:use-attribute-sets="glossAcronym-label">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'acronym'"/>
        </xsl:call-template>
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'colonSeparator'"/>
        </xsl:call-template>
      </fo:inline>

      <fo:inline xsl:use-attribute-sets="glossAcronym">
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </fo:inline>
    </fo:block>
  </xsl:template>

  <!-- glossShortForm ==================================================== -->

  <xsl:attribute-set name="glossShortForm-container" 
                     use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="glossShortForm-label">
  </xsl:attribute-set>

  <xsl:attribute-set name="glossShortForm"
                     use-attribute-sets="glossAlt-variant">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossShortForm ')]">
    <fo:block xsl:use-attribute-sets="glossShortForm-container">
      <fo:inline xsl:use-attribute-sets="glossShortForm-label">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'shortForm'"/>
        </xsl:call-template>
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'colonSeparator'"/>
        </xsl:call-template>
      </fo:inline>

      <fo:inline xsl:use-attribute-sets="glossShortForm">
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </fo:inline>
    </fo:block>
  </xsl:template>

  <!-- glossSynonym ====================================================== -->

  <xsl:attribute-set name="glossSynonym-container" 
                     use-attribute-sets="block-style">
  </xsl:attribute-set>

  <xsl:attribute-set name="glossSynonym-label">
  </xsl:attribute-set>

  <xsl:attribute-set name="glossSynonym"
                     use-attribute-sets="glossAlt-variant">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossSynonym ')]">
    <fo:block xsl:use-attribute-sets="glossSynonym-container">
      <fo:inline xsl:use-attribute-sets="glossSynonym-label">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'synonym'"/>
        </xsl:call-template>
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'colonSeparator'"/>
        </xsl:call-template>
      </fo:inline>

      <fo:inline xsl:use-attribute-sets="glossSynonym">
        <xsl:call-template name="commonAttributes"/>
        <xsl:apply-templates/>
      </fo:inline>
    </fo:block>
  </xsl:template>

  <!-- glossAlternateFor ================================================= -->

  <xsl:attribute-set name="glossAlternateFor">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' glossentry/glossAlternateFor ')]">
    <fo:inline xsl:use-attribute-sets="glossAlternateFor">
      <xsl:call-template name="commonAttributes"/>
      <!-- The preprocessor may have generated content for 
           glossAlternateFor which is normally empty. -->
      <xsl:call-template name="basicLink">
        <xsl:with-param name="href" select="string(@href)"/>
      </xsl:call-template>
    </fo:inline>
  </xsl:template>

  <!-- glossentry/related-links ========================================== -->

  <xsl:attribute-set name="glossentry-related-links">
    <xsl:attribute name="margin-left">4em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="glossentry-related-links-title"
                     use-attribute-sets="title">
  </xsl:attribute-set>

</xsl:stylesheet>
