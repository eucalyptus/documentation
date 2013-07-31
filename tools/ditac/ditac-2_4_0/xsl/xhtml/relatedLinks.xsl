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
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs ditac"
                version="2.0">
  
  <!-- link ============================================================== -->

  <xsl:template match="*[contains(@class,' topic/link ')]">
    <p>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:call-template name="linkItem"/>

      <xsl:variable name="href">
        <xsl:call-template name="resolveExternalHref"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$href ne ''">
          <a>
            <xsl:attribute name="href" select="$href"/>
            <xsl:call-template name="scopeAttribute"/>
            <xsl:call-template name="descToTitleAttribute"/>

            <xsl:call-template name="linkText">
              <xsl:with-param name="text">
                <xsl:apply-templates
                    select="./*[contains(@class,' topic/linktext ')]"/>
              </xsl:with-param>
              <xsl:with-param name="autoText" select="$linkAutoText"/>
            </xsl:call-template>

            <xsl:call-template name="externalLinkIcon"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <!-- In this case, the desc child is ignored. -->
          <xsl:apply-templates
              select="./*[contains(@class,' topic/linktext ')]"/>
        </xsl:otherwise>
      </xsl:choose>
    </p>
  </xsl:template>

  <xsl:template name="linkItem">
    <xsl:text>&#x2023; </xsl:text>

    <xsl:if test="@role eq 'parent' or 
                  @role eq 'previous' or 
                  @role eq 'next' or 
                  @role eq 'sibling'">
      <span class="{concat(@role, '-topic-link-item')}">
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="concat(@role, 'Topic')"/>
        </xsl:call-template>
        <xsl:call-template name="localize">
          <xsl:with-param name="message" select="'colonSeparator'"/>
        </xsl:call-template>
      </span>
    </xsl:if>
  </xsl:template>

  <!-- linkText is also used to process xref. -->

  <xsl:template name="linkText">
    <xsl:param name="text" select="()"/>
    <xsl:param name="autoText" select="()"/>

    <xsl:variable name="hasText" select="string($text) ne ''"/>
    <xsl:choose>
      <xsl:when test="$hasText and empty(@ditac:filled)">
        <!-- Show the text when it has actually been specified by the
             author and that's it. -->
        <xsl:copy-of select="$text"/>
      </xsl:when>

      <xsl:otherwise>
        <!-- Auto-generated text. -->
        <xsl:variable name="showLabel"
                      select="index-of($autoText, 'number') ge 1"/>

        <xsl:variable name="showText"
                      select="index-of($autoText, 'text') ge 1"/>

        <xsl:variable name="label">
          <xsl:call-template name="linkPrefix"/>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$label ne ''">
            <xsl:choose>
              <xsl:when test="$hasText">
                <xsl:if test="$showLabel">
                  <!-- Discard the '. ' found at the end of the label. -->
                  <xsl:value-of 
                      select="substring-before($label,
                                               $title-prefix-separator1)"/>
                </xsl:if>
                <xsl:if test="$showText">
                  <xsl:if test="$showLabel">
                    <xsl:value-of select="$title-prefix-separator1"/>
                  </xsl:if>
                  <xsl:copy-of select="$text"/>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of 
                    select="substring-before($label,
                                             $title-prefix-separator1)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="$hasText">
                <xsl:copy-of select="$text"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@href"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- linktext ========================================================== -->

  <xsl:template match="*[contains(@class,' topic/linktext ')]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- linkpool ========================================================== -->

  <xsl:template match="*[contains(@class,' topic/linkpool ')]">
    <xsl:variable name="mapkeyref" select="string(@mapkeyref)"/>

    <xsl:choose>
      <xsl:when test="ends-with($mapkeyref, 'type=sequence-parent') or 
                      ends-with($mapkeyref, 'type=sequence-members') or 
                      ends-with($mapkeyref, 'type=family-parent') or 
                      ends-with($mapkeyref, 'type=family-members') or 
                      ends-with($mapkeyref, 'type=unordered-parent') or 
                      ends-with($mapkeyref, 'type=unordered-members') or 
                      ends-with($mapkeyref, 'type=choice-parent') or 
                      ends-with($mapkeyref, 'type=choice-members')">
        <xsl:element name="{$navQName}">
          <xsl:call-template name="commonAttributes">
            <xsl:with-param name="class" 
              select="concat(substring-after($mapkeyref, 'type='), 
                             '-linkpool')" />
          </xsl:call-template>

          <xsl:if test="ends-with($mapkeyref, 'type=sequence-parent') or 
                        ends-with($mapkeyref, 'type=family-parent') or 
                        ends-with($mapkeyref, 'type=unordered-parent') or 
                        ends-with($mapkeyref, 'type=choice-parent')">
            <h4 class="linkpool-title">
              <xsl:call-template name="localize">
                <xsl:with-param name="message" select="'childTopics'"/>
              </xsl:call-template>
              <xsl:call-template name="localize">
                <xsl:with-param name="message" select="'colonSeparator'"/>
              </xsl:call-template>
            </h4>
          </xsl:if>

          <xsl:call-template name="namedAnchor"/>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>

      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- linklist ========================================================== -->

  <xsl:template match="*[contains(@class,' topic/linklist ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- linkinfo ========================================================== -->

  <xsl:template match="*[contains(@class,' topic/linkinfo ')]">
    <div>
      <xsl:call-template name="commonAttributes"/>
      <xsl:call-template name="namedAnchor"/>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

</xsl:stylesheet>
