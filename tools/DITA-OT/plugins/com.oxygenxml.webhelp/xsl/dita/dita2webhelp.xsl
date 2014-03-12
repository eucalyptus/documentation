<?xml version="1.0" encoding="UTF-8" ?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:File="java:java.io.File" 
  xmlns:oxygen="http://www.oxygenxml.com/functions"
  exclude-result-prefixes="File oxygen">

  <xsl:import href="../../../../xsl/dita2xhtml.xsl"/>
  <xsl:import href="rel-links.xsl"/>
  <xsl:import href="../functions.xsl"/>
  <xsl:import href="../localization.xsl"/>
  
  <xsl:param name="CUSTOM_RATE_PAGE_URL" select="''"/>
  <xsl:param name="WEBHELP_FOOTER_INCLUDE" select="'yes'"/>
  <xsl:param name="WEBHELP_FOOTER_FILE" select="''"/>
  <xsl:param name="WEBHELP_TRIAL_LICENSE" select="'no'"/>
  <xsl:param name="WEBHELP_PRODUCT_ID" select="''"/>
  <xsl:param name="WEBHELP_PRODUCT_VERSION" select="''"/>
  
  <xsl:param name="BASEDIR"/>
  <xsl:param name="OUTPUTDIR"/>
  <xsl:param name="LANGUAGE" select="'en-us'"/>
  
  <xsl:output 
    method="xml" 
    encoding="UTF-8"
    indent="no"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
    omit-xml-declaration="yes"/>
  
  <!-- 
  
  Header navigation.
  
  -->
  <xsl:template match="/|node()|@*" mode="gen-user-header">
  	<!-- Google Tag Manager -->
  	<noscript><iframe src="//www.googletagmanager.com/ns.html?id=GTM-WJKD4K"
  		height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
  	<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
  		new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
  		j=d.createElement(s),dl=l!='dataLayer'?'&amp;l='+l:'';j.async=true;j.src=
  		'//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
  		})(window,document,'script','dataLayer','GTM-WJKD4K');</script>
  	<!-- End Google Tag Manager -->
    <table class="nav">
      <tbody>
        <tr>
          <td colspan="2">
            <!-- Permanent link. -->            
            <xsl:variable name="permaLinkText">
              <xsl:call-template name="getString">
                <xsl:with-param name="stringName" select="'linkToThis'"/>
              </xsl:call-template>
            </xsl:variable>
            <div id="permalink"><a href="#" title="{$permaLinkText}"></a>              
            </div>
            <!-- Print link. -->            
            <xsl:variable name="printLinkText">
              <xsl:call-template name="getString">
                <xsl:with-param name="stringName" select="'printThisPage'"/>
              </xsl:call-template>
            </xsl:variable>
            <div id="printlink">
              <a href="javascript:window.print();" title="{$printLinkText}"></a>
            </div>
          </td>
        </tr>
        <tr>
          <td width="75%">
            <xsl:if test="count(descendant::*[contains(@class, ' topic/link ')][@role='parent']) = 1">
              <!-- Bread-crumb -->
              <xsl:variable name="parentRelativePath" 
                select="descendant::*[contains(@class, ' topic/link ')][@role='parent'][1]/@href"/>
              <xsl:variable name="parentTopic" 
                select="document($parentRelativePath)"/>
              
              <xsl:if test="count($parentTopic//*[contains(@class, ' topic/link ')][@role='parent']) = 1">            
                <!-- Link to parent of parent. -->
                <xsl:variable name="parentOfParentTopic" select="$parentTopic//*[contains(@class, ' topic/link ')][@role='parent'][1]"/>
                <xsl:for-each select="$parentOfParentTopic">
                  <xsl:call-template name="makelink">
                    <xsl:with-param name="final-path"
                      tunnel="yes"
                      select="oxygen:combineRelativePaths($parentRelativePath, @href)"
                      />
                  </xsl:call-template>
                </xsl:for-each>
                <xsl:text> / </xsl:text>
              </xsl:if>
                <!-- Link to parent. -->
              <xsl:for-each select="descendant::*[contains(@class, ' topic/link ')][@role='parent']">
                <xsl:call-template name="makelink"/>
              </xsl:for-each>
            </xsl:if>
          </td>
          <td>
            <!-- Navigation to the next, previous siblings and to the parent. -->
            <div class="navheader">              
              <xsl:call-template name="oxygenCustomHeaderAndFooter"/>
            </div>
          </td>        
        </tr>
      </tbody>
    </table>
  </xsl:template>


  
  <!-- 
    Adds topic rating and navigation to the footer.  
  -->  
  <xsl:template match="/|node()|@*" mode="gen-user-footer">
    <div class="navfooter">
      <xsl:comment/>
      <xsl:call-template name="oxygenCustomHeaderAndFooter"/>
    </div>
    <xsl:if test="string-length($CUSTOM_RATE_PAGE_URL) > 0">
      <noscript>.rate_page{display:none}</noscript>
      <div class="rate_page">
        <div id="rate_stars">
          <span><b>Rate this page</b>:</span> 
          <ul class="stars">
            <li><a href="#rate_stars" id="star1" onclick='setRate(this.id, this.title);' title="Not helpful">&#160;</a></li>
            <li><a href="#rate_stars" id="star2" onclick='setRate(this.id, this.title);' title="Somewhat helpful" class="">&#160;</a></li>
            <li><a href="#rate_stars" id="star3" onclick='setRate(this.id, this.title);' title="Helpful" class="">&#160;</a></li>
            <li><a href="#rate_stars" id="star4" onclick='setRate(this.id, this.title);' title="Very helpful" class="">&#160;</a></li>
            <li><a href="#rate_stars" id="star5" onclick='setRate(this.id, this.title);' title="Solved my problem" class="">&#160;</a></li>
          </ul>
        </div>
        <div id="rate_comment" class="hide">
          <span class="small">Optional Comment:</span><br/>
          <form name="contact" method="post" action="" enctype="multipart/form-data">
            <textarea rows='2' cols='20' name="feedback" id="feedback" class="text-input"><xsl:text> </xsl:text></textarea><br/>
            <input type="submit" name="submit" class="button" id="submit_btn" value="Send feedback" />
          </form>
        </div>
      </div>
    </xsl:if>
      
      <xsl:if test="('yes' = $WEBHELP_FOOTER_INCLUDE) 
                 or ('yes' = $WEBHELP_TRIAL_LICENSE)">
          <xsl:choose>
              <xsl:when test="(string-length($WEBHELP_FOOTER_FILE) = 0) 
                           or ('yes' = $WEBHELP_TRIAL_LICENSE)">
                  <div class="footer">
                      <!--<xsl:call-template name="getWebhelpString">
                          <xsl:with-param name="stringName" select="'Output generated by'"/>
                      </xsl:call-template>-->
                  	Copyright: &#169;2014 Eucalyptus Systems, Inc.
                      <!--<a href="http://www.oxygenxml.com" target="_blank">
                          <span class="oXygenLogo"><img src="{$PATH2PROJ}oxygen-webhelp/resources/img/LogoOxygen100x22.png" alt="Oxygen" /></span>
                          <span class="xmlauthor">XML Author</span>
                      </a>-->
                      <xsl:if test="'yes' = $WEBHELP_TRIAL_LICENSE">
                          <xsl:text> - Trial Edition</xsl:text>
                      </xsl:if>
                  </div>
              </xsl:when>
              <xsl:otherwise>
                  <!-- Include custom footer file. -->
                  <xsl:copy-of select="document(oxygen:makeURL($WEBHELP_FOOTER_FILE))"/>
              </xsl:otherwise>
          </xsl:choose>
      </xsl:if>
  </xsl:template>
  
  
  <!-- 
    Template for header and footer common navigation.    
  -->
  <xsl:template name="oxygenCustomHeaderAndFooter">
    <xsl:if test="$NOPARENTLINK = 'no'">
      <xsl:for-each
        select="descendant::*[contains(@class, ' topic/link ')]
        [@role='parent' or @role='previous' or @role='next']">
        <xsl:text>&#10;</xsl:text>
        <xsl:variable name="cls">
          <xsl:choose>
            <xsl:when test="@role = 'parent'">
              <xsl:text>navparent</xsl:text>
            </xsl:when>
            <xsl:when test="@role = 'previous'">
              <xsl:text>navprev</xsl:text>
            </xsl:when>
            <xsl:when test="@role = 'next'">
              <xsl:text>navnext</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>nonav</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <span>
          <xsl:attribute name="class">
            <xsl:value-of select="$cls"/>
          </xsl:attribute>
          <xsl:variable name="textLinkBefore">
            <span class="navheader_label">
              <xsl:choose>
                <xsl:when test="@role = 'parent'">
                  <xsl:call-template name="getString">
                    <xsl:with-param name="stringName" select="'Parent topic'"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:when test="@role = 'previous'">
                  <xsl:call-template name="getString">
                    <xsl:with-param name="stringName" select="'Previous topic'"
                    />
                  </xsl:call-template>
                </xsl:when>
                <xsl:when test="@role = 'next'">
                  <xsl:call-template name="getString">
                    <xsl:with-param name="stringName" select="'Next topic'"/>
                  </xsl:call-template>
                </xsl:when>
              </xsl:choose>
            </span>
            <span class="navheader_separator">
              <xsl:text>: </xsl:text>
            </span>
          </xsl:variable>
          <xsl:call-template name="makelink">
            <xsl:with-param name="label" select="$textLinkBefore"/>
          </xsl:call-template>
        </span>
        <xsl:text>  </xsl:text>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  
  <!-- 
    Finds all index terms and adds them to the meta element 'indexterms'. (EXM-20576) 
  -->
    <xsl:template match="*" mode="gen-keywords-metadata">
      <xsl:variable name="indexterms-content">
          <xsl:for-each select="descendant::*[contains(@class,' topic/keywords ')]//*[contains(@class,' topic/indexterm ')]">
              <xsl:value-of select="normalize-space(text()[1])"/>
              <xsl:if test="position() &lt; last()"><xsl:text>, </xsl:text></xsl:if>
          </xsl:for-each>
      </xsl:variable>
      <xsl:if test="string-length($indexterms-content)>0">
          <meta name="indexterms" content="{$indexterms-content}"/>
          <xsl:value-of select="$newline"/>
      </xsl:if>
      <xsl:apply-imports/>
  </xsl:template>
  
  <xsl:function name="oxygen:combineRelativePaths" as="item()">
    <xsl:param name="relativePath1" as="item()"/>
    <xsl:param name="relativePath2" as="item()"/>
      <xsl:variable name="baseFolder" select="string-join(tokenize($relativePath1, '/')[position() &lt; last()], '/')"/>
    <xsl:variable name="result" 
        select="if (string-length($baseFolder) > 0) then concat($baseFolder, '/', $relativePath2) else $relativePath2"/>
    <xsl:value-of select="$result"/>
  </xsl:function>
  
</xsl:stylesheet>
