<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="*[@collection-type='sequence']/*[contains(@class, ' map/topicref ')]
    [not(ancestor::*[contains(concat(' ', @chunk, ' '), ' to-content ')])]" mode="link-to-next-prev" name="link-to-next-prev">
    <xsl:param name="pathBackToMapDirectory"/>
    <xsl:variable name="previous" select="(preceding::*|ancestor::*)[contains(@class, ' map/topicref ')]
      [@href][not(@href='')][not(@linking='none')][not(@linking='sourceonly')]
      [not(@processing-role='resource-only')][last()]"/>
    <xsl:choose>
      <xsl:when test="ancestor::*[contains(@class, ' map/relcell ')]">
        <xsl:if test="$previous/ancestor::*[contains(@class, ' map/relcell ')] 
                    and generate-id(ancestor::*[contains(@class, ' map/relcell ')]) = 
                           generate-id($previous/ancestor::*[contains(@class, ' map/relcell ')])">
          <xsl:apply-templates mode="link" select="$previous">
            <xsl:with-param name="role">previous</xsl:with-param>
            <xsl:with-param name="pathBackToMapDirectory" select="$pathBackToMapDirectory"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="link" select="$previous">
          <xsl:with-param name="role">previous</xsl:with-param>
          <xsl:with-param name="pathBackToMapDirectory" select="$pathBackToMapDirectory"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:variable name="next" select="(*|following::*)[contains(@class, ' map/topicref ')][@href][not(@href='')]
      [not(@linking='none')][not(@linking='sourceonly')]
      [not(@processing-role='resource-only')][1]"/>
    <xsl:choose>
      <xsl:when test="ancestor::*[contains(@class, ' map/relcell ')]">
          <xsl:if test="$next/ancestor::*[contains(@class, ' map/relcell ')] 
                    and generate-id(ancestor::*[contains(@class, ' map/relcell ')]) 
                        = generate-id($next/ancestor::*[contains(@class, ' map/relcell ')])">
          <xsl:apply-templates mode="link" select="$next">
            <xsl:with-param name="role">next</xsl:with-param>
            <xsl:with-param name="pathBackToMapDirectory" select="$pathBackToMapDirectory"/>
          </xsl:apply-templates>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="link" select="$next">
          <xsl:with-param name="role">next</xsl:with-param>
          <xsl:with-param name="pathBackToMapDirectory" select="$pathBackToMapDirectory"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>