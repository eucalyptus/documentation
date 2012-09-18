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
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="xs"
                version="2.0">

  <!-- Something like '100%' or '90%' -->
  <xsl:param name="default-table-width" select="''"/>

  <!-- 'none', 'top', 'bottom' 'both' -->
  <xsl:param name="chain-pages" select="'none'"/>

  <xsl:param name="chain-topics" select="'no'"/>

  <!-- 'yes', 'no', 
       'auto' (means: 'yes' if chain-topics=yes, otherwise 'no') -->
  <xsl:param name="ignore-navigation-links" select="'auto'"/>

  <xsl:param name="defaultXSLResourcesDir" 
             select="resolve-uri('resources/', document-uri(doc('')))"/>
  <xsl:param name="xsl-resources-directory" select="$defaultXSLResourcesDir"/>
  <xsl:variable name="xslResourcesDir" 
                select="if (ends-with($xsl-resources-directory, '/')) then
                            $xsl-resources-directory
                        else
                            concat($xsl-resources-directory, '/')"/>
    
  <xsl:param name="css-name" select="'basic.css'"/>
  <xsl:param name="css" select="''"/>

  <!-- By default, serve XHTML as HTML.
       Specify 'application/xhtml+xml' if you prefer to serve XHTML as XML.
       Specify an empty string if you want to suppress the 
       meta http-equiv="Content-Type". -->
  <xsl:param name="xhtml-mime-type" select="'text/html'"/>

  <xsl:param name="generator-info" select="'XMLmind DITA Converter 2.2.3'"/>

  <!-- Do not redefine unless you change the files found in
       $xsl-resources-directory. -->
  <xsl:param name="note-icon-suffix" select="'.png'"/>
  <!-- A dimension may have a unit. Default is px. -->
  <xsl:param name="note-icon-width" select="'32'"/>
  <xsl:param name="note-icon-height" select="'32'"/>

  <xsl:param name="navigation-icon-suffix" select="'.png'"/>
  <xsl:param name="navigation-icon-width" select="'16'"/>
  <xsl:param name="navigation-icon-height" select="'16'"/>

  <xsl:param name="mark-external-links" select="'no'"/>
  <xsl:param name="external-link-icon-name" select="'new_window.png'"/>
  <xsl:param name="external-link-icon-width" select="'11'"/>
  <xsl:param name="external-link-icon-height" select="'10'"/>

  <!-- Unit: DPI -->
  <xsl:param name="screen-resolution" select="96"/>
  <!-- Unit: points (like a font size) -->
  <xsl:param name="em-size" select="10"/>

</xsl:stylesheet>
