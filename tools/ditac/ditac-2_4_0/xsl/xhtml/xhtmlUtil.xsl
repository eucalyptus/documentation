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
                exclude-result-prefixes="xs u"
                version="2.0">

  <!-- commonAttributes ================================================== -->

  <xsl:template name="commonAttributes">
    <xsl:param name="class" select="''"/>
    <xsl:param name="classPrefix" select="''"/>
    
    <xsl:call-template name="idAttribute"/>
    <xsl:call-template name="localizationAttributes"/>
    <xsl:call-template name="otherAttributes">
      <xsl:with-param name="class" select="$class"/>
      <xsl:with-param name="classPrefix" select="$classPrefix"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="commonAttributes2">
    <xsl:param name="class" select="''"/>
    <xsl:param name="classPrefix" select="''"/>
    
    <xsl:call-template name="idAttribute2"/>
    <xsl:call-template name="localizationAttributes"/>
    <xsl:call-template name="otherAttributes">
      <xsl:with-param name="class" select="$class"/>
      <xsl:with-param name="classPrefix" select="$classPrefix"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="idAttribute">
    <xsl:copy-of select="@id"/>
  </xsl:template>

  <xsl:template name="idAttribute2">
    <xsl:attribute name="id">
      <xsl:choose>
        <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('I_', generate-id(), '_')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="localizationAttributes">
    <xsl:copy-of select="@xml:lang"/>
    <xsl:if test="$xhtmlVersion ne '1.1' and exists(@xml:lang)">
      <xsl:attribute name="lang" select="string(@xml:lang)"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="otherAttributes">
    <xsl:param name="class" select="''"/>
    <xsl:param name="classPrefix" select="''"/>

    <xsl:call-template name="otherAttributesImpl">
      <xsl:with-param name="class" select="$class"/>
      <xsl:with-param name="classPrefix" select="$classPrefix"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="otherAttributesImpl">
    <xsl:param name="class" select="''"/>
    <xsl:param name="classPrefix" select="''"/>

    <xsl:variable name="baseClass">
      <xsl:choose>
        <xsl:when test="$class">
          <xsl:value-of select="$class"/>
        </xsl:when>
        <xsl:when test="@class">
          <xsl:value-of 
              select="concat($classPrefix, u:classToElementName(@class))"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
 
    <xsl:choose>
      <xsl:when test="@outputclass">
        <xsl:attribute name="class" 
                       select="concat($baseClass, ' ', @outputclass)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="class" select="$baseClass"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="namedAnchor">
    <!-- This is a hack created uniquely to support JavaHelp which cannot
         scroll to id="XXX" and instead insists on having a name="XXX". 
         Note that the HTML 3.2 created by these XSLT stylesheets 
         cannot be valid in all cases. -->
    <xsl:if test="exists(@id) and $xhtmlVersion eq '-3.2'">
      <a name="{string(@id)}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="namedAnchor2">
    <xsl:if test="$xhtmlVersion eq '-3.2'">
      <xsl:variable name="id">
        <xsl:choose>
          <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('I_', generate-id(), '_')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <a name="{$id}"/>
    </xsl:if>
  </xsl:template>

  <!-- displayAttributes ================================================= -->

  <xsl:template name="displayAttributes">
    <!-- @expanse not implemented here -->
    <xsl:variable name="style">
      <xsl:if test="@scale">
        font-size: <xsl:value-of select="@scale"/>%;
      </xsl:if>

      <xsl:if test="@frame">
        <!-- Do not use shorthand properties and do no specify border
             color. This allows the user to specify a custom border color in
             her/his CSS. -->
        <xsl:choose>
          <xsl:when test="@frame eq 'top'">
            border-top-width: 1px;
            border-top-style: solid;
            padding-top: 0.5ex;
          </xsl:when>
          <xsl:when test="@frame eq 'bottom'">
            border-bottom-width: 1px;
            border-bottom-style: solid;
            padding-bottom: 0.5ex;
          </xsl:when>
          <xsl:when test="@frame eq 'topbot'">
            border-top-width: 1px;
            border-top-style: solid;
            border-bottom-width: 1px;
            border-bottom-style: solid;
            padding-top: 0.5ex;
            padding-bottom: 0.5ex;
          </xsl:when>
          <xsl:when test="@frame eq 'all'">
            border-width: 1px;
            border-style: solid;
            padding: 0.5ex;
          </xsl:when>
          <xsl:when test="@frame eq 'sides'">
            border-left-width: 1px; 
            border-left-style: solid; 
            border-right-width: 1px;
            border-right-style: solid;
            padding-left: 0.5ex;
            padding-right: 0.5ex;
          </xsl:when>
        </xsl:choose>
      </xsl:if>

      <xsl:if test="contains(@class,' topic/fig ') and 
                (index-of($centerList, u:classToElementName(@class)) ge 1) and
                exists(./*[contains(@class,' topic/image ')])">
        text-align: center;
      </xsl:if>
    </xsl:variable>

    <xsl:if test="$style ne ''">
      <xsl:attribute name="style" select="normalize-space($style)"/>
    </xsl:if>
  </xsl:template>

  <!-- External links ==================================================== -->

  <xsl:template name="scopeAttribute">
    <!-- No need to lookup for @scope: the preprocessor has cascaded 
         this attribute in the related-links section. -->
    <xsl:if test="@scope eq 'external' and $xhtmlVersion ne '1.1'">
      <xsl:attribute name="target">_blank</xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="externalLinkIcon">
    <!-- No need to lookup for @scope: the preprocessor has cascaded 
         this attribute in the related-links section. -->
    <xsl:if test="@scope eq 'external'">
      <xsl:call-template name="addExternalLinkIcon"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="addExternalLinkIcon">
    <xsl:if test="$mark-external-links eq 'yes' and $xhtmlVersion ne '1.1'">
      <xsl:text> </xsl:text>
      <img>
        <xsl:call-template name="noImageBorder"/>

        <xsl:attribute name="src"
                       select="concat($xslResourcesDir,
                                      $external-link-icon-name)"/>
        <xsl:attribute name="alt">
          <xsl:call-template name="localize">
            <xsl:with-param name="message" select="'newWindow'"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:if test="$external-link-icon-width ne ''">
          <xsl:attribute name="width" select="$external-link-icon-width"/>
        </xsl:if>
        <xsl:if test="$external-link-icon-height ne ''">
          <xsl:attribute name="height" select="$external-link-icon-height"/>
        </xsl:if>
      </img>
    </xsl:if>
  </xsl:template>

  <xsl:template name="noImageBorder">
    <xsl:choose>
      <xsl:when test="$xhtmlVersion eq '5.0' or $xhtmlVersion eq '1.1'">
        <xsl:attribute name="style" select="'border-style: none;'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="border" select="'0'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- tableLayoutAttributes ============================================= -->

  <xsl:template name="tableLayoutAttributes">
    <xsl:param name="width" select="''"/>
    <xsl:param name="cellspacing" select="''"/>
    <xsl:param name="align" select="''"/>
    <xsl:param name="valign" select="''"/>
    <xsl:param name="extraStyles" select="''"/>

    <xsl:choose>
      <xsl:when test="$xhtmlVersion eq '5.0'">
        <xsl:variable name="style">
          <xsl:if test="$width ne ''">
            <xsl:variable name="width2" 
                          select="if (number($width) gt 0) 
                                  then concat($width, 'px')
                                  else $width"/>
            <xsl:value-of select="concat('width: ', $width2, ';')"/>
          </xsl:if>

          <xsl:if test="$cellspacing ne ''">
            <xsl:value-of
              select="concat('border-spacing: ', $cellspacing, ';')"/>
          </xsl:if>

          <!-- align="char" does not seem to be supported by Web browsers. -->
          <xsl:if test="$align ne '' and $align ne 'char'">
            <xsl:value-of select="concat('text-align: ', $align, ';')"/>
          </xsl:if>

          <xsl:if test="$valign ne ''">
            <xsl:value-of select=" concat('vertical-align: ', $valign, ';')"/>
          </xsl:if>

          <xsl:value-of select="$extraStyles"/>
        </xsl:variable>
          
        <xsl:variable name="style2" select="normalize-space($style)"/>
        <xsl:if test="$style2 ne ''">
          <xsl:attribute name="style" select="$style2"/>
        </xsl:if>
      </xsl:when>

      <xsl:otherwise>
        <xsl:if test="$width ne ''">
          <xsl:attribute name="width" select="$width"/>
        </xsl:if>

        <xsl:if test="$cellspacing ne ''">
          <xsl:attribute name="cellspacing" select="$cellspacing"/>
        </xsl:if>

        <!-- align="char" does not seem to be supported by Web browsers. -->
        <xsl:if test="$align ne '' and $align ne 'char'">
          <xsl:attribute name="align" select="$align"/>
        </xsl:if>

        <xsl:if test="$valign ne ''">
          <xsl:choose>
            <xsl:when test="$xhtmlVersion eq '-3.2' and $valign eq 'baseline'">
              <xsl:attribute name="valign" select="'top'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="valign" select="$valign"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>

        <xsl:variable name="extraStyles2" 
                      select="normalize-space($extraStyles)"/>
        <xsl:if test="$extraStyles2 ne ''">
          <xsl:attribute name="style" select="$extraStyles2"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- onclickPIToTriggers =============================================== -->

  <xsl:template name="onclickPIToTriggers">
    <xsl:variable name="observer" select="string(../@id)"/>
    <xsl:if test="$observer eq ''">
      <xsl:message terminate="yes">Error: the parent element of onclick must have an id attribute.</xsl:message>
    </xsl:if>

    <xsl:variable name="defaultRef" 
                  select="substring-after(string(../@href), '#')"/>
    <xsl:variable name="defaultRef2"
                  select="if ($defaultRef eq '???' or 
                              string(../@scope) eq 'external')
                          then ''
                          else $defaultRef"/>

    <xsl:variable name="doc" select="/"/>
    <xsl:variable name="pi" select="."/>

    <xsl:variable name="actions" select="tokenize(string(.), '\s+')"/>
    <xsl:for-each select="$actions">
      <xsl:variable name="action" select="substring-before(., '(')"/>
      <xsl:if test="$action ne 'play' and
                    $action ne 'pause' and
                    $action ne 'resume' and
                    $action ne 'mute' and
                    $action ne 'unmute' and
                    $action ne 'show' and
                    $action ne 'hide'">
        <xsl:message terminate="yes">Error: the actions allowed in onclick are: show, hide, play, pause, resume, mute and unmute.</xsl:message>
      </xsl:if>
      
      <xsl:variable name="ref" 
        select="normalize-space(substring-before(substring-after(., '('), ')'))"/>
      <xsl:variable name="ref2" 
                    select="if ($ref eq '') 
                            then $defaultRef2
                            else u:checkTriggerRef($ref, $action, $pi)"/>
      <xsl:if test="$ref2 eq ''">
        <xsl:message terminate="yes">Error: cannot determine the target of action <xsl:value-of select="$action"/>() in onclick.</xsl:message>
      </xsl:if>
      <xsl:if test="($action eq 'play' or
                     $action eq 'pause' or
                     $action eq 'resume' or
                     $action eq 'mute' or
                     $action eq 'unmute') and
                     empty($doc//*[@id eq $ref2 and 
                                   contains(@class,' topic/object ')])">
        <xsl:message terminate="yes">Error: the target of onclick <xsl:value-of select="$action"/>() must be an object element.</xsl:message>
      </xsl:if>

      <epub:trigger xmlns:epub="http://www.idpf.org/2007/ops"
        ev:observer="{$observer}" xmlns:ev="http://www.w3.org/2001/xml-events"
        ev:event="click" action="{$action}" ref="{$ref2}"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="u:checkTriggerRef" as="xs:string">
    <xsl:param name="ref" as="xs:string"/>
    <xsl:param name="action" as="xs:string"/>
    <xsl:param name="context" as="node()"/>

    <xsl:choose>
      <xsl:when test="contains($ref, '/')">
        <xsl:sequence select="replace($ref, '/', '__')"/>
      </xsl:when>

      <xsl:otherwise>
        <!-- Allow for this little mistake: 
             play(foo) instead of play(topic_id/foo). -->

        <xsl:variable name="topic" 
          select="$context/ancestor::*[contains(@class,' topic/topic ')]"/>

        <xsl:variable name="topicId" 
                      select="if (exists($topic)) 
                              then string($topic[last()]/@id)
                              else ''"/>

        <xsl:message>Warning: do you mean <xsl:value-of 
          select="concat($action, '(', 
                         if ($topicId ne '') 
                         then concat($topicId, '/', $ref) 
                         else concat('topic_id/', $ref), 
                         ')')"/>?</xsl:message>

        <xsl:sequence select="if ($topicId ne '')
                              then concat($topicId, '__', $ref)
                              else $ref"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:template name="onclickPIScript">
    <script>
function onclickPI_play(id) {
    var target = document.getElementById(id);
    if (target !== null) {
        target.currentTime = 0;
        target.play();
    }
}

function onclickPI_pause(id) {
    var target = document.getElementById(id);
    if (target !== null) {
        target.pause();
    }
}

function onclickPI_resume(id) {
    var target = document.getElementById(id);
    if (target !== null) {
        target.play();
    }
}

function onclickPI_mute(id) {
    var target = document.getElementById(id);
    if (target !== null) {
        target.muted = true;
    }
}

function onclickPI_unmute(id) {
    var target = document.getElementById(id);
    if (target !== null) {
        target.muted = false;
    }
}

function onclickPI_show(id) {
    var target = document.getElementById(id);
    if (target !== null) {
        target.style.visibility = 'visible';
    }
}

function onclickPI_hide(id) {
    var target = document.getElementById(id);
    if (target !== null) {
        target.style.visibility = 'hidden';
    }
}
    </script>
  </xsl:template>

</xsl:stylesheet>
