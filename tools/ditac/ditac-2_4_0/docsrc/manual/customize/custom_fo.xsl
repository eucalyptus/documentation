<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="2.0">

  <xsl:import href="ditac-xsl:fo/fo.xsl"/>

  <xsl:attribute-set name="topic-title" use-attribute-sets="title">
    <xsl:attribute name="color">#403480</xsl:attribute>
    <xsl:attribute name="font-size">160%</xsl:attribute>
    <xsl:attribute name="padding-bottom">0.05em</xsl:attribute>
    <xsl:attribute name="border-bottom">0.5pt solid #403480</xsl:attribute>
    <xsl:attribute name="space-before.optimum">1.5em</xsl:attribute>
    <xsl:attribute name="space-before.minimum">1.2em</xsl:attribute>
    <xsl:attribute name="space-before.maximum">1.8em</xsl:attribute>
  </xsl:attribute-set>

</xsl:stylesheet>
