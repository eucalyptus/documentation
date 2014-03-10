<?xml version="1.0" encoding="UTF-8" ?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:d="http://docbook.org/ns/docbook"
        xmlns:xhtml="http://www.w3.org/1999/xhtml"
        xmlns:saxon="http://icl.com/saxon"
        xmlns="http://www.w3.org/1999/xhtml" 
        exclude-result-prefixes="d saxon"
        version="1.0">
    
    <xsl:import href="../../../xhtml/profile-docbook.xsl"/>
    <xsl:import href="../../../xhtml/highlight.xsl"/>
    <xsl:import href="../../../oxygen_custom_html.xsl"/>
    <xsl:import href="../../../xhtml/chunk-common.xsl"/>
    <xsl:include href="../../../xhtml/manifest.xsl"/>
    <xsl:include href="../../../xhtml/profile-chunk-code.xsl"/>
    <xsl:include href="../dita/dita-utilities.xsl"/>

    <xsl:param name="PATH2PROJ" select="''"/>
    <xsl:param name="CSSPATH" select="''"/>
    
    <xsl:param name="DEFAULTLANG">en-us</xsl:param>
    <xsl:param name="output.dir" select="$base.dir"/>
    <xsl:param name="WEBHELP_PRODUCT_ID" select="''"/>
    <xsl:param name="WEBHELP_PRODUCT_VERSION" select="''"/>
    <xsl:param name="WEBHELP_FOOTER_INCLUDE" select="'yes'"/>
    <xsl:param name="WEBHELP_FOOTER_FILE" select="''"/>
    <xsl:param name="WEBHELP_TRIAL_LICENSE" select="'no'"/>
    <xsl:param name="CUSTOM_RATE_PAGE_URL" select="''"/>
    <!-- Custom CSS set in param html.stylesheet -->
    <xsl:param name="CSS" select="''"/>
  
    <!-- Set some default values for Docbook params - EXM-26685 -->
    <!-- output method -->
    <xsl:param name="chunker.output.method">
        <xsl:choose>
            <xsl:when test="contains(system-property('xsl:vendor'), 'SAXON 6')">saxon:xhtml</xsl:when>
            <xsl:otherwise>html</xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    <xsl:param name="chunker.output.indent" select="'no'"/>
    <!-- TOC -->
    <xsl:param name="chunk.first.sections" select="1"/>
    <xsl:param name="chunk.section.depth" select="3"/>
    <xsl:param name="generate.section.toc.level" select="5"/>
    <!-- header and footer navigation: Prev, Next -->
    <xsl:param name="navig.showtitles" select="0"/>
    <xsl:param name="suppress.navigation" select="0"/>
    <!-- chunk file name -->
    <xsl:param name="use.id.as.filename" select="1"/>
    <!-- Index section at the end -->
    <xsl:param name="generate.index" select="1"/>
    <xsl:param name="manifest.in.base.dir" select="0"/>
    <xsl:param name="inherit.keywords" select="0"/>
    <xsl:param name="para.propagates.style" select="1"/>
    <xsl:param name="phrase.propagates.style" select="1"/>
    <xsl:param name="section.autolabel" select="0"/>
    <xsl:param name="chapter.autolabel" select="0"/>
    <xsl:param name="appendix.autolabel" select="0"/>
    <xsl:param name="qandadiv.autolabel" select="0"/>
    <xsl:param name="reference.autolabel" select="0"/>
    <xsl:param name="part.autolabel" select="0"/>    
    <xsl:param name="section.label.includes.component.label" select="1"/>
    <xsl:param name="component.label.includes.part.label" select="1"/>
    <xsl:param name="suppress.footer.navigation" select="0"/>
    
    <xsl:output 
        method="html" 
        encoding="UTF-8"
        omit-xml-declaration="yes"
        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
 
    <!-- 
      Adds oxygen indexterm elements to the HTML content. They are processed later in the 
      ANT pipeline. 
    -->
    <xsl:template match="d:indexterm">
        <oxygen:indexterm xmlns:oxygen="http://www.oxygenxml.com/ns/webhelp/index">
            <xsl:if test="d:primary">
                <xsl:attribute name="primary"><xsl:value-of select="d:primary"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="d:secondary">
                <xsl:attribute name="secondary"><xsl:value-of select="d:secondary"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="d:tertiary">
                <xsl:attribute name="tertiary"><xsl:value-of select="d:tertiary"/></xsl:attribute>
            </xsl:if>
        </oxygen:indexterm>
    </xsl:template>
    
    <!-- 
      Creates the in-page table of contents. At the same time, it outputs 
      an XML document, toc.xml containing a neutral representation of the TOC.
      This is used further by the ANT pipeline and the createMainFiles.xsl stylesheet
      to create the webhelp system navigation.
    -->
    
    <xsl:template name="make.toc">
        <xsl:param name="toc-context" select="."/>
        <xsl:param name="toc.title.p" select="true()"/>
        <xsl:param name="nodes" select="/NOT-AN-ELEMENT"/>
        
        <xsl:variable name="nodes.plus" select="$nodes | d:qandaset"/>
        
        <xsl:variable name="toc.title">
            <xsl:if test="$toc.title.p">
                <xsl:choose>
                    <xsl:when test="$make.clean.html != 0">
                        <div class="toc-title" xmlns="http://www.w3.org/1999/xhtml">
                            <xsl:call-template name="gentext">
                                <xsl:with-param name="key">TableofContents</xsl:with-param>
                            </xsl:call-template>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <p xmlns="http://www.w3.org/1999/xhtml">
                            <strong xmlns:xslo="http://www.w3.org/1999/XSL/Transform">
                                <xsl:call-template name="gentext">
                                    <xsl:with-param name="key">TableofContents</xsl:with-param>
                                </xsl:call-template>
                            </strong>
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$manual.toc != ''">
                <xsl:variable name="id">
                    <xsl:call-template name="object.id"/>
                </xsl:variable>
                <xsl:variable name="toc" select="document($manual.toc, .)"/>
                <xsl:variable name="tocentry" select="$toc//d:tocentry[@linkend=$id]"/>
                <xsl:if test="$tocentry and $tocentry/*">
                    <div class="toc" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:copy-of select="$toc.title"/>
                        <xsl:element name="{$toc.list.type}" namespace="http://www.w3.org/1999/xhtml">
                            <xsl:call-template name="manual-toc">
                                <xsl:with-param name="tocentry" select="$tocentry/*[1]"/>
                            </xsl:call-template>
                        </xsl:element>
                    </div>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$qanda.in.toc != 0">
                        <xsl:if test="$nodes.plus">
                            <div class="toc" xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:copy-of select="$toc.title"/>
                                <xsl:element name="{$toc.list.type}" namespace="http://www.w3.org/1999/xhtml">
                                    <xsl:apply-templates select="$nodes.plus" mode="toc">
                                        <xsl:with-param name="toc-context" select="$toc-context"/>
                                    </xsl:apply-templates>
                                </xsl:element>
                            </div>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="$nodes">
                            <div class="toc" xmlns="http://www.w3.org/1999/xhtml">
                                <xsl:copy-of select="$toc.title"/>
                                <!-- EXM-23634  OXYGEN PATCH START -->
                                <xsl:variable name="toc">
                                    <xsl:element name="{$toc.list.type}" namespace="http://www.w3.org/1999/xhtml">
                                        <xsl:apply-templates select="$nodes" mode="toc">
                                            <xsl:with-param name="toc-context" select="$toc-context"/>
                                        </xsl:apply-templates>
                                    </xsl:element>
                                </xsl:variable>
                                <xsl:variable name="document.title">
                                    <xsl:apply-templates select="(//d:title)[1]" mode="titlepage.mode"/>
                                </xsl:variable>
                                <xsl:copy-of select="$toc"/>
                                <xsl:if test=". = /">
                                    <xsl:call-template name="write.chunk">
                                        <xsl:with-param name="filename" select="concat($output.dir, '/toc.xml')"/>
                                        <xsl:with-param name="method" select="'xml'"/>
                                        <xsl:with-param name="encoding" select="'UTF-8'"/>
                                        <xsl:with-param name="indent" select="'yes'"/>
                                        <xsl:with-param name="omit-xml-declaration" select="'no'"/>
                                        <xsl:with-param name="standalone" select="'yes'"/>
                                        <xsl:with-param name="doctype-public"/>
                                        <xsl:with-param name="doctype-system"/>
                                        <xsl:with-param name="cdata-section-elements"/>
                                        <xsl:with-param name="content">
                                            <toc xmlns="http://www.oxygenxml.com/ns/webhelp/toc" title="{$document.title}">
                                                <xsl:apply-templates select="saxon:node-set($toc)/xhtml:dl/xhtml:dt" mode="create-toc"/>
                                                <xsl:variable name="copyright">
                                                    <xsl:apply-templates
                                                        select="//d:info/d:copyright | //d:bookinfo/d:copyright" mode="titlepage.mode"/>
                                                </xsl:variable>
                                                <copyright>
                                                    <xsl:copy-of select="$copyright"/>
                                                </copyright>
                                                <xsl:variable name="legalnotice">
                                                    <xsl:apply-templates
                                                        select="//d:info/d:legalnotice | //d:bookinfo/d:legalnotice" mode="titlepage.mode"/>
                                                </xsl:variable>
                                                <legalnotice>
                                                    <xsl:copy-of select="$legalnotice"/>
                                                </legalnotice>
                                            </toc>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:if>
                                <!-- EXM-23634  OXYGEN PATCH END -->
                            </div>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
 
    <!-- Ignore all text when composing the TOC. -->
    <xsl:template match="text()" mode="create-toc"/>
    <xsl:template match="xhtml:dt" mode="create-toc">
        <topic xmlns="http://www.oxygenxml.com/ns/webhelp/toc" 
                    title="{normalize-space(xhtml:span[1]/xhtml:a[1])}" 
                    href="{xhtml:span[1]/xhtml:a[1]/@href}"
                    collection-type="sequence">
            <xsl:apply-templates select="following-sibling::*[1]/xhtml:dl/xhtml:dt" mode="create-toc"/>
        </topic>
    </xsl:template>

    <!-- 
      Adds topic rating and navigation to the footer.  
    --> 
    <xsl:template name="user.footer.navigation">
        <xsl:param name="node" select="."/>
        <xsl:if test="'yes' = $WEBHELP_FOOTER_INCLUDE 
                    or ('yes' = $WEBHELP_TRIAL_LICENSE)">
            <xsl:choose>
                <xsl:when test="(string-length($WEBHELP_FOOTER_FILE) = 0) 
                             or ('yes' = $WEBHELP_TRIAL_LICENSE)">
                    <!-- The standard oXygen footer. -->
                    <div class="footer" xmlns="http://www.w3.org/1999/xhtml">
                        <xsl:call-template name="getWebhelpString">
                            <xsl:with-param name="stringName" select="'Output generated by'"/>
                        </xsl:call-template>
                        <a href="http://www.oxygenxml.com" target="_blank">
                            <span class="oXygenLogo"><img src="oxygen-webhelp/resources/img/LogoOxygen100x22.png" alt="Oxygen" /></span>
                            <span class="xmlauthor">XML Author</span>
                        </a>
                        <xsl:if test="'yes' = $WEBHELP_TRIAL_LICENSE">
                            <xsl:text> - Trial Edition</xsl:text>
                        </xsl:if>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Include custom footer file. -->                    
                    <xsl:variable name="correctedPath" select="translate($WEBHELP_FOOTER_FILE, '\\', '/')"/>
                    <xsl:variable name="url">
                        <xsl:choose>
                            <!-- Mac / Linux paths start with / -->
                            <xsl:when test="starts-with($correctedPath, '/')">
                                <xsl:value-of select="concat('file://', $correctedPath)"/>
                            </xsl:when>
                            <!-- Windows paths not start with / -->
                            <xsl:otherwise>
                                <xsl:value-of select="concat('file:///', $correctedPath)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:copy-of select="document($url)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="anchor"/>

  <!--
    Gets all the HTML page content.
  -->
  <xsl:template name="getAllPageContent">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="nav.context"/>
    <xsl:param name="content"/>
    <xsl:call-template name="user.preroot"/>
    <html>
      <xsl:call-template name="root.attributes"/>
      <xsl:call-template name="html.head">
        <xsl:with-param name="prev" select="$prev"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>
      <body>
        <xsl:call-template name="body.attributes"/>
        <xsl:call-template name="user.header.navigation">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="nav.context" select="$nav.context"/>
        </xsl:call-template>
        <xsl:call-template name="header.navigation">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="nav.context" select="$nav.context"/>
        </xsl:call-template>
        <xsl:call-template name="user.header.content"/>
        <xsl:copy-of select="$content"/>
        <xsl:call-template name="user.footer.content"/>
        <xsl:call-template name="footer.navigation">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="nav.context" select="$nav.context"/>
        </xsl:call-template>
        <xsl:call-template name="user.footer.navigation">
          <xsl:with-param name="prev" select="$prev"/>
          <xsl:with-param name="next" select="$next"/>
          <xsl:with-param name="nav.context" select="$nav.context"/>
        </xsl:call-template>
      </body>
    </html>
    <xsl:value-of select="$chunk.append"/>
  </xsl:template>        


  <!-- EXM-27944 Remove  background-repeat: no-repeat; -->
  <xsl:template name="head.content.style">
    <xsl:param name="node" select="."/>
    <style type="text/css"><xsl:text>
body { background-image: url('</xsl:text>
        <xsl:value-of select="$draft.watermark.image"/><xsl:text>');
   background-position: top left;
   /* The following properties make the watermark "fixed" on the page. */
   /* I think that's just a bit too distracting for the reader... */
   /* background-attachment: fixed; */
   /* background-position: center center; */
}</xsl:text>
    </style>
  </xsl:template>
</xsl:stylesheet>
