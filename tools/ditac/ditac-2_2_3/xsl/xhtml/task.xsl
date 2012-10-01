<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2009-2011 Pixware SARL. All rights reserved.
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
  
  <!-- task LIKE topic -->
  <!-- taskbody LIKE body -->

  <!-- prereq ============================================================ -->

  <xsl:template match="*[contains(@class,' task/prereq ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>

      <h3 class="prereq-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'prereq'"/>
        </xsl:call-template>
      </h3>

      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- context =========================================================== -->

  <xsl:template match="*[contains(@class,' task/context ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>

      <h3 class="context-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'context'"/>
        </xsl:call-template>
      </h3>

      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- steps-informal ==================================================== -->

  <xsl:template match="*[contains(@class,' task/steps-informal ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>

      <h3 class="steps-informal-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'steps'"/>
        </xsl:call-template>
      </h3>

      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- steps ============================================================= -->

  <xsl:template match="*[contains(@class,' task/steps ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>

      <h3 class="steps-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'steps'"/>
        </xsl:call-template>
      </h3>

      <xsl:variable name="class">
        <xsl:call-template name="stepListClass">
          <xsl:with-param name="suffix" select="'step-list'"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:call-template name="namedAnchor"/>
      <ol class="{$class}">
        <xsl:apply-templates/>
      </ol>
    </div>
  </xsl:template>

  <xsl:template name="stepListClass">
    <xsl:param name="suffix" select="'step-list'"/>

    <xsl:variable name="compact">
      <xsl:call-template name="compactStepListPrefix"/>
    </xsl:variable>

    <xsl:value-of select="concat($compact, $suffix)"/>
  </xsl:template>

  <xsl:template name="compactStepListPrefix">
    <xsl:choose>
      <xsl:when test="exists(./*[contains(@class,' task/stepsection ')] |
                             ./*/*[contains(@class,' task/info ') or 
                                   contains(@class,' task/substeps ') or 
                                   contains(@class,' task/tutorialinfo ') or 
                                   contains(@class,' task/stepxmp ') or 
                                   contains(@class,' task/choicetable ') or 
                                   contains(@class,' task/choices ') or 
                                   contains(@class,' task/stepresult ')
                                  ])"></xsl:when>
      <xsl:otherwise>compact-</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- steps-unordered =================================================== -->

  <xsl:template match="*[contains(@class,' task/steps-unordered ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>

      <h3 class="steps-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'steps'"/>
        </xsl:call-template>
      </h3>

      <xsl:variable name="class">
        <xsl:call-template name="stepListClass">
          <xsl:with-param name="suffix" select="'unordered-step-list'"/>
        </xsl:call-template>
      </xsl:variable>

      <xsl:call-template name="namedAnchor"/>
      <ul class="{$class}">
        <xsl:apply-templates/>
      </ul>
    </div>
  </xsl:template>

  <!-- stepsection ======================================================= -->

  <xsl:template match="*[contains(@class,' task/stepsection ')]">
    <li>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <!-- step ============================================================== -->

  <xsl:template match="*[contains(@class,' task/step ')]">
    <li>
      <xsl:call-template name="commonAttributes">
        <xsl:with-param name="classPrefix" 
          select="if (@importance) then concat(@importance, '-') else ''"/>
      </xsl:call-template>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <!-- cmd =============================================================== -->

  <xsl:template match="*[contains(@class,' task/cmd ')]">
    <span>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <!-- info ============================================================== -->

  <xsl:template match="*[contains(@class,' task/info ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- substeps ========================================================== -->

  <xsl:template match="*[contains(@class,' task/substeps ')]">
    <xsl:variable name="compact">
      <xsl:call-template name="compactStepListPrefix"/>
    </xsl:variable>

    <xsl:call-template name="namedAnchor"/>
    <ol>
      <xsl:call-template name="commonAttributes">
        <xsl:with-param name="classPrefix" select="$compact"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </ol>
  </xsl:template>

  <!-- substep =========================================================== -->

  <xsl:template match="*[contains(@class,' task/substep ')]">
    <li>
      <xsl:call-template name="commonAttributes">
        <xsl:with-param name="classPrefix" 
          select="if (@importance) then concat(@importance, '-') else ''"/>
      </xsl:call-template>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <!-- choicetable LIKE simpletable -->

  <!-- chhead ========================================================== -->

  <xsl:template match="*[contains(@class,' task/chhead ')]">
    <tr>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>

  <!-- choptionhd ======================================================= -->

  <xsl:template match="*[contains(@class,' task/choptionhd ')]">
    <td>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <!-- chdeschd ======================================================== -->

  <xsl:template match="*[contains(@class,' task/chdeschd ')]">
    <td>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <!-- chrow ========================================================== -->

  <xsl:template match="*[contains(@class,' task/chrow ')]">
    <tr>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>

  <!-- choption ========================================================= -->

  <xsl:template match="*[contains(@class,' task/choption ')]">
    <td>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <!-- chdesc ========================================================== -->

  <xsl:template match="*[contains(@class,' task/chdesc ')]">
    <td>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </td>
  </xsl:template>

  <!-- choices ========================================================== -->

  <xsl:template match="*[contains(@class,' task/choices ')]">
    <xsl:call-template name="namedAnchor"/>
    <ul>
      <xsl:call-template name="commonAttributes"/>
      <xsl:apply-templates/>
    </ul>
  </xsl:template>

  <!-- choice =========================================================== -->

  <xsl:template match="*[contains(@class,' task/choice ')]">
    <li>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <!-- tutorialinfo ====================================================== -->

  <xsl:template match="*[contains(@class,' task/tutorialinfo ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- stepxmp =========================================================== -->

  <xsl:template match="*[contains(@class,' task/stepxmp ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- stepresult ======================================================== -->

  <xsl:template match="*[contains(@class,' task/stepresult ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- result ============================================================ -->

  <xsl:template match="*[contains(@class,' task/result ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>

      <h3 class="result-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'result'"/>
        </xsl:call-template>
      </h3>

      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- postreq =========================================================== -->

  <xsl:template match="*[contains(@class,' task/postreq ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>

      <h3 class="postreq-title">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'postreq'"/>
        </xsl:call-template>
      </h3>

      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

</xsl:stylesheet>
