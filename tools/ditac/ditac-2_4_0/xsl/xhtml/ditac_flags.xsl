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
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                exclude-result-prefixes="xs u ditac"
                version="2.0">

  <xsl:template match="ditac:flags">
    <xsl:variable name="canFlag" select="u:canFlag(child::*)"/>
    <xsl:choose>
      <xsl:when test="$canFlag eq 1">
        <div class="ditac-flags-div-container">
          <xsl:if test="@startImage or @startText">
            <p class="ditac-flags-div-start-p">
              <xsl:if test="@startImage">
                <img src="{@startImage}" 
                     alt="{tokenize(string(@startImage), '/')[last()]}"
                     class="ditac-flags-div-start-image"/>
              </xsl:if>

              <xsl:if test="@startText">
                <span class="ditac-flags-div-start-text">
                  <xsl:value-of select="@startText"/>
                </span>
              </xsl:if>
            </p>
          </xsl:if>

          <xsl:choose>
            <xsl:when test="$xhtmlVersion eq '-3.2' and @changebar">
              <!-- Use 2 nested divs and a colored margin to simulate a
                   border. -->
              <div class="ditac-flags-div1">
                <div class="ditac-flags-div2">
                  <xsl:call-template name="flagsStyle">
                    <xsl:with-param name="setChangebar" select="false()"/>
                  </xsl:call-template>

                  <xsl:apply-templates/>
                </div>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <div class="ditac-flags-div">
                <xsl:call-template name="flagsStyle">
                  <xsl:with-param name="setChangebar" select="true()"/>
                </xsl:call-template>

                <xsl:apply-templates/>
              </div>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:if test="@endImage or @endText">
            <p class="ditac-flags-div-end-p">
              <xsl:if test="@endImage">
                <img src="{@endImage}" 
                     alt="{tokenize(string(@endImage), '/')[last()]}"
                     class="ditac-flags-div-end-image"/>
              </xsl:if>

              <xsl:if test="@endText">
                <span class="ditac-flags-div-end-text">
                  <xsl:value-of select="@endText"/>
                </span>
              </xsl:if>
            </p>
          </xsl:if>
        </div>
      </xsl:when>

      <xsl:when test="$canFlag eq 2">
        <span class="ditac-flags-span-container">
          <xsl:if test="@startImage">
            <img src="{@startImage}" 
                 alt="{tokenize(string(@startImage), '/')[last()]}"
                 class="ditac-flags-span-start-image"/>
          </xsl:if>

          <xsl:if test="@startText">
            <span class="ditac-flags-span-start-text">
              <xsl:value-of select="@startText"/>
            </span>
          </xsl:if>

          <span class="ditac-flags-span">
            <xsl:call-template name="flagsStyle">
              <xsl:with-param name="setChangebar" select="false()"/>
            </xsl:call-template>

            <xsl:apply-templates/>
          </span>

          <xsl:if test="@endImage">
            <img src="{@endImage}" 
                 alt="{tokenize(string(@endImage), '/')[last()]}"
                 class="ditac-flags-span-end-image" />
          </xsl:if>

          <xsl:if test="@endText">
            <span class="ditac-flags-span-end-text">
              <xsl:value-of select="@endText"/>
            </span>
          </xsl:if>
        </span>
      </xsl:when>

      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="flagsStyle">
    <xsl:param name="setChangebar" select="false()"/>

    <xsl:variable name="style">
      <xsl:if test="@color">
        color: <xsl:value-of select="@color"/>;
      </xsl:if>

      <xsl:if test="@background-color">
        background-color: <xsl:value-of select="@background-color"/>;
      </xsl:if>

      <xsl:if test="@font-weight">
        font-weight: <xsl:value-of select="@font-weight"/>;
      </xsl:if>

      <xsl:if test="@font-style">
        font-style: <xsl:value-of select="@font-style"/>;
      </xsl:if>

      <xsl:if test="@text-decoration">
        text-decoration: <xsl:value-of select="@text-decoration"/>;
      </xsl:if>

      <xsl:if test="@changebar and $setChangebar">
        border-right-width: 2px;
        border-right-style: solid;
        padding-right: 0.5ex;
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="style2" select="normalize-space($style)"/>
    <xsl:if test="$style2 ne ''">
      <xsl:attribute name="style" select="$style2"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
