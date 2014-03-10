<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<!-- 
  In DITA output, it is common to have links pointing to a topic page that also specify the topic ID as a fragment.
  In case the fragment and the file name are the same, we remove the fragment and keep ajax='true' 
  (the default behavior), considering the fragment redundant. 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">
  
  <!-- 
    Removes the fragment if it is the same as the file name without extension.
  -->
  <xsl:template name="removeFragmentIfRedundant">
    <xsl:param name="href"/>
    
    <xsl:variable name="fqf">
      <xsl:call-template name="getFileNameQueryAndFragment">
        <xsl:with-param name="text" select="$href"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="fileNameWithNoExtension">
      <xsl:call-template name="getFileNameWithNoExtension">
        <xsl:with-param name="fileNameQueryAndFragment" select="$fqf"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="fragment">
      <xsl:call-template name="getFragment">
        <xsl:with-param name="fileNameQueryAndFragment" select="$fqf"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="normalize-space($fileNameWithNoExtension) = normalize-space($fragment)">
        <!-- The fragment is redundant. Remove it -->
        <xsl:value-of select="substring-before($href, '#')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$href"/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  
  <!-- 
      Extracts the file name, query and fragment part from an url. For instance:
      
      http://some.site.com/dir/file.html?q=t#anchor
      
      Results in:
      
      file.html?q=t#anchor  
    -->
  <xsl:template name="getFileNameQueryAndFragment">
    <xsl:param name="text"/>
    <xsl:param name="delim" select="'/'"/>
    
    <xsl:choose>
      <xsl:when test="contains($text, $delim)">        
        <xsl:call-template name="getFileNameQueryAndFragment">
          <xsl:with-param name="text" select="substring-after($text, $delim)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- There is no delimiter in the text. -->
        <xsl:value-of select="$text"/>        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- 
      Extracts the file name from a string containg 
      the file name, query and anchor part of an URL. 
    -->
  <xsl:template name="getFileNameWithNoExtension">
    <xsl:param name="fileNameQueryAndFragment"/>
    <xsl:variable name="fileName">
      <xsl:choose>
        <xsl:when test="contains($fileNameQueryAndFragment, '?' )">
          <xsl:value-of select="substring-before($fileNameQueryAndFragment, '?')"/>
        </xsl:when>
        <xsl:when test="contains($fileNameQueryAndFragment, '#' )">
          <xsl:value-of select="substring-before($fileNameQueryAndFragment, '#')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$fileNameQueryAndFragment"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($fileName, '.htm')">
        <xsl:value-of select="substring-before($fileName, '.htm')"/>          
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$fileName"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- 
        Extracts the fragment from a string containg 
        the file name, query and fragment part of an URL. 
      -->
  <xsl:template name="getFragment">
    <xsl:param name="fileNameQueryAndFragment"/>
    <xsl:if test="contains($fileNameQueryAndFragment, '#' )">
      <xsl:value-of select="substring-after($fileNameQueryAndFragment, '#')"/>
    </xsl:if>     
  </xsl:template>
  
  
</xsl:stylesheet>