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
                exclude-result-prefixes="xs"
                version="2.0">

  <!-- 'auto', 'none', 
        URI (if relative, relative to the current working directory) -->
  <xsl:param name="title-page" select="'auto'"/>

  <!-- 'frontmatter', 'backmatter', 'both', 'none'. -->
  <xsl:param name="extended-toc" select="'none'"/>

  <!-- One or more of: 'topic', 'chapter-only', 'table', 'fig', 
       'example', 'all'. -->
  <xsl:param name="number" select="''"/>
  <xsl:variable name="numberList" select="tokenize($number, '\s+')"/>

  <!-- 'I', 'i', 'A', 'a', '1' -->
  <xsl:param name="part-number-format" select="'I'"/>
  <xsl:param name="appendix-number-format" select="'A'"/>

  <xsl:param name="prepend-chapter-to-section-number" select="'no'"/>

  <xsl:param name="number-separator1" select="'.'"/>
  <xsl:param name="number-separator2" select="'-'"/>
  <xsl:param name="title-prefix-separator1" select="'. '"/>

  <xsl:param name="center" select="''"/>
  <xsl:variable name="centerList" select="tokenize($center, '\s+')"/>

  <xsl:param name="title-after" select="''"/>
  <xsl:variable name="titleAfterList" select="tokenize($title-after, '\s+')"/>

  <xsl:param name="use-note-icon" select="'no'"/>
  <xsl:param name="note-icon-list" select="'attention
                                            caution
                                            danger
                                            fastpath
                                            important
                                            note
                                            notice
                                            remember
                                            restriction
                                            tip
                                            warning'"/>
  <xsl:variable name="noteIconList" select="tokenize($note-icon-list, '\s+')"/>

  <!-- One or more of: 'number', 'text'. -->
  <xsl:param name="xref-auto-text" select="'number'"/>
  <xsl:variable name="xrefAutoText" select="tokenize($xref-auto-text, '\s+')"/>

  <!-- One or more of: 'number', 'text'. -->
  <xsl:param name="link-auto-text" select="'number text'"/>
  <xsl:variable name="linkAutoText" select="tokenize($link-auto-text, '\s+')"/>

  <xsl:param name="show-draft-comments" select="'no'"/>

  <xsl:param name="index-range-separator" select="'&#x2013;'"/>

  <!-- Encoding of the text file referenced by coderef/@href. 
       Empty string means: to be determined automatically. -->
  <xsl:param name="text-file-encoding" select="''"/>

</xsl:stylesheet>
