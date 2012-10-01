<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="2.0">

  <xsl:import href="ditac-xsl:fo/fo.xsl"/>

  <xsl:attribute-set name="tag" use-attribute-sets="monospace-style">
  </xsl:attribute-set>

  <xsl:template match="*[contains(@class,' tech-d/tag ')]">
    <fo:inline xsl:use-attribute-sets="tag">
      <xsl:call-template name="commonAttributes"/>

      <xsl:choose>
        <xsl:when test="@kind = 'attvalue'">
          <xsl:text>&quot;</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'emptytag'">
          <xsl:text>&lt;</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'endtag'">
          <xsl:text>&lt;/</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'genentity'">
          <xsl:text>&amp;</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'numcharref'">
          <xsl:text>&amp;#</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'paramentity'">
          <xsl:text>%</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'pi'">
          <xsl:text>&lt;?</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'comment'">
          <xsl:text>&lt;!--</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'starttag'">
          <xsl:text>&lt;</xsl:text>
        </xsl:when>
      </xsl:choose>

      <xsl:apply-templates/>

      <xsl:choose>
        <xsl:when test="@kind = 'attvalue'">
          <xsl:text>&quot;</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'emptytag'">
          <xsl:text>/&gt;</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'endtag'">
          <xsl:text>&gt;</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'genentity'">
          <xsl:text>;</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'numcharref'">
          <xsl:text>;</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'paramentity'">
          <xsl:text>;</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'pi'">
          <xsl:text>?&gt;</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'comment'">
          <xsl:text>--&gt;</xsl:text>
        </xsl:when>
        <xsl:when test="@kind = 'starttag'">
          <xsl:text>&gt;</xsl:text>
        </xsl:when>
      </xsl:choose>
    </fo:inline>
  </xsl:template>

</xsl:stylesheet>
