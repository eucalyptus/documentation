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
  
  <!-- abbreviated-form ================================================== -->

  <xsl:template match="*[contains(@class,' abbrev-d/abbreviated-form ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <!-- The preprocessor may have generated content for 
           abbreviated-form which is normally empty. -->
      <xsl:call-template name="basicLink"/>
    </span>
  </xsl:template>

  <!-- glossgroup LIKE topic -->

  <!-- glossentry ======================================================== -->

  <xsl:template match="*[contains(@class,' glossentry/glossentry ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- glossterm ========================================================= -->

  <xsl:template match="*[contains(@class,' glossentry/glossterm ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- glossdef ========================================================== -->

  <xsl:template match="*[contains(@class,' glossentry/glossdef ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- glossBody ========================================================= -->

  <xsl:template match="*[contains(@class,' glossentry/glossBody ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>

      <xsl:variable name="partOfSpeech" 
        select="./*[contains(@class,' glossentry/glossPartOfSpeech ')]"/>
      <xsl:variable name="status" 
        select="./*[contains(@class,' glossentry/glossStatus ')]"/>
      <xsl:variable name="property" 
        select="./*[contains(@class,' glossentry/glossProperty ')]"/>

      <xsl:if test="exists($partOfSpeech|$status|$property)">
        <div class="glossBody-properties">
          <xsl:for-each select="($partOfSpeech|$status|$property)">
            <xsl:apply-templates select="."/>
            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'periodSeparator'"/>
            </xsl:call-template>
          </xsl:for-each>
        </div>
      </xsl:if>

      <xsl:apply-templates
        select="./* except ($partOfSpeech|$status|$property)"/>
    </div>
  </xsl:template>

  <!-- glossPartOfSpeech ================================================= -->

  <xsl:template match="*[contains(@class,' glossentry/glossPartOfSpeech ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:value-of select="normalize-space(string(@value))" />
    </span>
  </xsl:template>

  <!-- glossStatus ======================================================= -->

  <xsl:template match="*[contains(@class,' glossentry/glossStatus ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:value-of select="normalize-space(string(@value))" />
    </span>
  </xsl:template>

  <!-- glossProperty ===================================================== -->

  <xsl:template match="*[contains(@class,' glossentry/glossProperty ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:value-of select="normalize-space(string(@name))" />
      <xsl:call-template name="localize">
        <xsl:with-param name="message" select="'colonSeparator'"/>
      </xsl:call-template>
      <xsl:value-of select="normalize-space(string(@value))" />
    </span>
  </xsl:template>

  <!-- glossSurfaceForm ================================================== -->

  <xsl:template match="*[contains(@class,' glossentry/glossSurfaceForm ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- glossUsage ======================================================== -->

  <xsl:template match="*[contains(@class,' glossentry/glossUsage ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- glossScopeNote ==================================================== -->

  <xsl:template match="*[contains(@class,' glossentry/glossScopeNote ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- glossSymbol ======================================================= -->

  <xsl:template match="*[contains(@class,' glossentry/glossSymbol ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:if test="@align eq 'left' or
                    @align eq 'right' or
                    @align eq 'center'">
        <xsl:attribute name="style"
          select="concat('text-align: ', string(@align), ';')"/>
      </xsl:if>

      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="imageToImg"/>
    </div>
  </xsl:template>

  <!-- glossAlt ========================================================== -->

  <xsl:template match="*[contains(@class,' glossentry/glossAlt ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>

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
        <div class="glossAlt-properties">
          <xsl:for-each select="($status|$property)">
            <xsl:apply-templates select="."/>
            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'periodSeparator'"/>
            </xsl:call-template>
          </xsl:for-each>
        </div>
      </xsl:if>

      <xsl:apply-templates
        select="./* except ($abbreviation|$acronym|$shortForm|$synonym|$status|$property|$alternateFor)"/>

      <xsl:if test="exists($alternateFor)">
        <div class="glossAlt-variants">
          <span class="glossAlt-variants-label">
            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'alternateFor'"/>
            </xsl:call-template>
            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'colonSeparator'"/>
            </xsl:call-template>
          </span>

          <xsl:for-each select="$alternateFor">
            <xsl:apply-templates select="."/>
            <xsl:call-template name="localize">
              <xsl:with-param name="message" select="'periodSeparator'"/>
            </xsl:call-template>
          </xsl:for-each>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- glossAbbreviation ================================================= -->

  <xsl:template match="*[contains(@class,' glossentry/glossAbbreviation ')]">
    <div class="glossAbbreviation-container">
      <span class="glossAbbreviation-label">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'abbreviation'"/>
        </xsl:call-template>
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'colonSeparator'"/>
        </xsl:call-template>
      </span>

      <span>
        <xsl:call-template name="commonAttributes"/>
        <xsl:call-template name="namedAnchor"/>
        <xsl:apply-templates/>
      </span>
    </div>
  </xsl:template>

  <!-- glossAcronym ====================================================== -->

  <xsl:template match="*[contains(@class,' glossentry/glossAcronym ')]">
    <div class="glossAcronym-container">
      <span class="glossAcronym-label">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'acronym'"/>
        </xsl:call-template>
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'colonSeparator'"/>
        </xsl:call-template>
      </span>

      <span>
        <xsl:call-template name="commonAttributes"/>
        <xsl:call-template name="namedAnchor"/>
        <xsl:apply-templates/>
      </span>
    </div>
  </xsl:template>

  <!-- glossShortForm ==================================================== -->

  <xsl:template match="*[contains(@class,' glossentry/glossShortForm ')]">
    <div class="glossShortForm-container">
      <span class="glossShortForm-label">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'shortForm'"/>
        </xsl:call-template>
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'colonSeparator'"/>
        </xsl:call-template>
      </span>

      <span>
        <xsl:call-template name="commonAttributes"/>
        <xsl:call-template name="namedAnchor"/>
        <xsl:apply-templates/>
      </span>
    </div>
  </xsl:template>

  <!-- glossSynonym ====================================================== -->

  <xsl:template match="*[contains(@class,' glossentry/glossSynonym ')]">
    <div class="glossSynonym-container">
      <span class="glossSynonym-label">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'synonym'"/>
        </xsl:call-template>
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'colonSeparator'"/>
        </xsl:call-template>
      </span>

      <span>
        <xsl:call-template name="commonAttributes"/>
        <xsl:call-template name="namedAnchor"/>
        <xsl:apply-templates/>
      </span>
    </div>
  </xsl:template>

  <!-- glossAlternateFor ================================================= -->

  <xsl:template match="*[contains(@class,' glossentry/glossAlternateFor ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <!-- The preprocessor may have generated content for 
           glossAlternateFor which is normally empty. -->
      <xsl:call-template name="basicLink"/>
    </span>
  </xsl:template>

</xsl:stylesheet>
