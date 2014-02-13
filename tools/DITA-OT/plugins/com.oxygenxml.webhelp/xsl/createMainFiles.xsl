<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2014 Syncro Soft SRL, Romania.  All rights reserved.
Licensed under the terms stated in the license file EULA_Webhelp.txt 
available in the base directory of this Oxygen Webhelp plugin.

-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
  xmlns:index="http://www.oxygenxml.com/ns/webhelp/index" xmlns:File="java:java.io.File"
  xmlns:oxygen="http://www.oxygenxml.com/functions" xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="toc index File oxygen d xs"
  version="2.0">

  <!-- Localization of text strings displayed in Webhelp output. -->
  <xsl:import href="localization.xsl"/>
  <xsl:import href="functions.xsl"/>


  <!-- The folder with the XHTML files -->
  <xsl:param name="XHTML_FOLDER"/>

  <!-- Folder with output files. -->
  <xsl:param name="OUTPUTDIR"/>

  <!-- Base folder of Webhelp module. -->
  <xsl:param name="BASEDIR"/>

  <!-- Language for localization of strings in output page. -->
  <xsl:param name="DEFAULTLANG">en-us</xsl:param>

  <!-- Copyright notice inserted by user that runs transform. -->
  <xsl:param name="WEBHELP_COPYRIGHT"/>

  <!-- Name of product displayed in title of email notification sent to users. -->
  <xsl:param name="WEBHELP_PRODUCT_NAME"/>
  
  <!-- Parameter used for computing the relative path of the topic. 
  	  In case of docbook, this should be empty. -->
  <xsl:param name="PATH2PROJ" select="''"/>

  <!-- The path of index.xml -->
  <xsl:param name="INDEX_XML_FILEPATH" select="'in/index.xml'"/>

  <!-- The path of toc.xml -->
  <xsl:param name="TOC_XML_FILEPATH" select="'in/toc.xml'"/>
  
    <!-- Custom CSS set in DITA-OT params for custom CSS. -->
  <xsl:param name="CSS" select="''"/>
  <xsl:param name="CSSPATH" select="''"/>
    
  <!-- Custom JavaScript code set by param webhelp.head.script -->
  <xsl:param name="WEBHELP_HEAD_SCRIPT" select="''"/>
    
  <!-- Custom JavaScript code set by param webhelp.body.script -->
  <xsl:param name="WEBHELP_BODY_SCRIPT" select="''"/>
    
    
  <!-- Loads the additional XML documents. -->
  <xsl:variable name="index" select="document(oxygen:makeURL($INDEX_XML_FILEPATH))/index:index"/>
  <xsl:variable name="toc" select="document(oxygen:makeURL($TOC_XML_FILEPATH))/toc:toc"/>

  <xsl:template match="/">
      <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="$toc/toc:title">
          <xsl:apply-templates select="$toc/toc:title"/>
        </xsl:when>
        <xsl:when test="$toc/@title">
          <xsl:value-of select="$toc/@title"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="create-main-files">
      <xsl:with-param name="toc" select="$toc"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:call-template name="create-localization-files"/>
  </xsl:template>
  
  <!-- Creates the set of main files: the TOC (for the version with 
    and without frames) and the index.html. Extracted to template 
    so it can be overriden from other stylesheets. -->
  <xsl:template name="create-main-files">
    <xsl:param name="toc"/>
    <xsl:param name="title"/>
    <xsl:call-template name="create-toc-frames-file">
      <xsl:with-param name="toc" select="$toc"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:call-template name="create-toc-noframes-file">
      <xsl:with-param name="toc" select="$toc"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
    <xsl:call-template name="create-index-file">
      <xsl:with-param name="toc" select="$toc"/>
      <xsl:with-param name="title" select="$title"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Creates the localization files. -->
  <xsl:template name="create-localization-files">
    <xsl:variable name="jsFileName" select="'oxygen-webhelp/resources/localization/strings.js'"/>
    <xsl:variable name="jsURL"
      select="concat(File:toURI(File:new(string($OUTPUTDIR))), $jsFileName)"/>
    <xsl:variable name="phpFileName" select="'oxygen-webhelp/resources/localization/strings.php'"/>
    <xsl:variable name="phpURL"
      select="concat(File:toURI(File:new(string($OUTPUTDIR))), $phpFileName)"/>
    <xsl:for-each select="/*">
      <xsl:call-template name="generateLocalizationFiles">
        <xsl:with-param name="jsURL" select="$jsURL"/>
        <xsl:with-param name="phpURL" select="$phpURL"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!--
    Generates the content/search/index tabs.
  -->
  <xsl:template name="create-tabs-divs">
    <div id="tocMenu" xmlns="http://www.w3.org/1999/xhtml">
      <div class="tab" id="content" style="display:inline">
        <span onclick="showMenu('content')" id="content.label">
          <xsl:call-template name="getWebhelpString">
            <xsl:with-param name="stringName" select="'Content'"/>
          </xsl:call-template>
        </span>
      </div>
      <div class="tab" id="search" style="display:inline">
        <span onclick="showMenu('search')" id="search.label">
          <xsl:call-template name="getWebhelpString">
            <xsl:with-param name="stringName" select="'Search'"/>
          </xsl:call-template>          
        </span>
      </div>
      <xsl:if test="count($index/*) > 0">
        <div class="tab" id="index" style="display:inline">
          <span onclick="showMenu('index')" id="index.label">
            <xsl:call-template name="getWebhelpString">
              <xsl:with-param name="stringName" select="'Index'"/>
            </xsl:call-template>            
          </span>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <!--
    Creates the TOC file for the version with frames.
  -->
  <xsl:template name="create-toc-frames-file">
    <xsl:param name="title"/>
    <xsl:param name="toc"/>
    <xsl:call-template name="create-toc-common-file">
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="toc" select="$toc"/>
      <xsl:with-param name="withFrames" select="true()"/>
      <xsl:with-param name="fileName" select="'toc.html'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- 
    Creates the TOC file for the version with no frames. In fact this page will contain the entire content.
  -->
  <xsl:template name="create-toc-noframes-file">
    <xsl:param name="title"/>
    <xsl:param name="toc"/>
    <xsl:call-template name="create-toc-common-file">
      <xsl:with-param name="title" select="$title"/>
      <xsl:with-param name="toc" select="$toc"/>
      <xsl:with-param name="withFrames" select="false()"/>
      <xsl:with-param name="fileName" select="'index.html'"/>
    </xsl:call-template>    
  </xsl:template>
  
  <!-- Gets the name of the skin for the main file. -->
  <xsl:function name="oxygen:getSkinName" as="xs:string">
    <xsl:param name="withFrames"/>
    
    <xsl:variable name="skinName">    
      <xsl:call-template name="get-skin-name">
        <xsl:with-param name="withFrames" select="$withFrames"/>
      </xsl:call-template>    
    </xsl:variable>
    <xsl:value-of select="normalize-space($skinName)"/>
    
  </xsl:function>
  
  <!-- Extracted to a template so it can be overriden from other stylesheets. -->
  <xsl:template name="get-skin-name">
    <xsl:param name="withFrames"/>
    <xsl:choose>
      <xsl:when test="$withFrames"> desktop-frames </xsl:when>
      <xsl:otherwise> desktop </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- 
    Common part for TOC creation.
  -->
  <xsl:template name="create-toc-common-file">
    <xsl:param name="toc"/>
    <xsl:param name="title" as="node()"/>
    <xsl:param name="fileName"/>
    <!-- toc.xml pt frame-uri, index.html pentru no frames.-->
    <xsl:param name="withFrames" as="xs:boolean"/>
    <!--true pentru frame-uri, false pentru no frames. -->
    
    <xsl:variable name="skinName" select="oxygen:getSkinName($withFrames)"/>
    
    <xsl:result-document href="{$fileName}" method="xhtml" indent="no" encoding="UTF-8"
      doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
      doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
      omit-xml-declaration="yes">
      <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
          <xsl:if test="$withFrames">
            <base target="contentwin"/>
          </xsl:if>
          <title>
            <xsl:value-of select="$title"/>
          </title>
                    
            <link rel="stylesheet" type="text/css"
                    href="oxygen-webhelp/resources/css/commonltr.css">
                <xsl:comment/>
            </link>
            <!-- Imposes a skin. -->
            <link rel="stylesheet" type="text/css"
              href="oxygen-webhelp/resources/css/toc.css">
              <xsl:comment/>
            </link>
            <link rel="stylesheet" type="text/css" 
                    href="oxygen-webhelp/resources/skins/{$skinName}/toc_custom.css">
                <xsl:comment/>
            </link>
            <link rel="stylesheet" type="text/css"
                    href="oxygen-webhelp/resources/css/webhelp_topic.css">
                <xsl:comment/>
            </link>
            <!-- custom CSS -->
            <xsl:if test="string-length($CSS)>0">
                <xsl:variable name="urltest"> <!-- test for URL -->
                    <xsl:call-template name="url-string">
                        <xsl:with-param name="urltext">
                            <xsl:value-of select="concat($CSSPATH,$CSS)"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$urltest='url'">
                        <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$CSS}" >
                            <xsl:comment/>
                        </link>
                    </xsl:when>
                    <xsl:otherwise>
                        <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$CSS}" >
                            <xsl:comment/>
                        </link>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            
          <xsl:call-template name="create-js-scripts">
            <xsl:with-param name="withFrames" select="$withFrames"/>
          </xsl:call-template>
          
          <!-- Imposes a skin. -->
          <script type="text/javascript" src="oxygen-webhelp/resources/skins/{$skinName}/toc_driver.js"><xsl:comment/></script>
          
        </head>
        <body onload="javascript:showMenu('content');">
          <xsl:if test="$withFrames">
            <div id="productTitle">
            <h1>
              <xsl:copy-of select="$title"/>
            </h1>
            </div>
          </xsl:if>
          <noscript>
            <style type="text/css">
              #searchBlock,
              #preload,
              #indexBlock,
              #tocMenu{
                  display:none
              }
              
              #tab_nav_tree,
              #contentBlock ul li ul{
                  display:block;
              }
              #contentBlock ul li span{
                  padding:0px 5px 0px 5px;
              }
              #contentMenuItem:before{
                  content:"Content";
              }</style>
            <xsl:if test="not($withFrames)">
              <div style="width: 100%; vertical-align: middle; text-align: center; height: 100%;">
                <div style="position: absolute; top:45%; left:25%;width: 50%; "> You must enable
                  javascript in order to view this page or you can go <a href="index_frames.html"
                    >here</a> to view the webhelp. </div>
              </div>
            </xsl:if>
          </noscript>
          <xsl:if test="not($withFrames)">
            <!-- Custom JavaScript code set by param webhelp.body.script -->
            <xsl:if test="string-length($WEBHELP_BODY_SCRIPT) > 0">
              <xsl:value-of select="unparsed-text($WEBHELP_BODY_SCRIPT)" disable-output-escaping="yes"/>
            </xsl:if>
          </xsl:if>
          <div id="header">
            <div id="lHeader">
              <xsl:if test="not($withFrames)">
                <div id="productTitle">
                  <h1>
                    <xsl:copy-of select="$title"/>
                  </h1>
                  <div class="framesLink">
                    <a href="index_frames.html" id="oldFrames">
                      <img src="oxygen-webhelp/resources/img/frames.png" alt="With Frames"
                        border="0"/>
                    </a>
                  </div>
                </div>
              </xsl:if>
              <table class="tool" cellpadding="0" cellspacing="0">
                <tr>
                  <td>
                    <xsl:call-template name="create-tabs-divs"/>                    
                  </td>
                  <td>
                    <div id="productToolbar">
                      <div id="breadcrumbLinks">
                        <xsl:comment> </xsl:comment>
                      </div>
                      <div id="navigationLinks">
                        <xsl:comment> </xsl:comment>
                      </div>
                    </div>
                  </td>
                </tr>
              </table>
            </div>
            <div id="space">
              <xsl:comment/>
            </div>
          </div>

          <div id="splitterContainer">
            <div id="leftPane">
              <div id="bck_toc">
                <div id="searchBlock" style="display:none;">
                  <form name="searchForm" id="searchForm" action="javascript:void(0)"
                    onsubmit="SearchToc('searchForm');">
                    <xsl:comment/>
                    <input type="text" id="textToSearch" name="textToSearch" class="textToSearch"
                      size="30" placeholder="Keywords"/>
                    <xsl:comment/>
                    <xsl:variable name="searchLabel">
                      <xsl:for-each select="/*">
                        <xsl:call-template name="getWebhelpString">
                          <xsl:with-param name="stringName" select="'Search'"/>
                        </xsl:call-template>
                      </xsl:for-each>
                    </xsl:variable>
                    <input type="submit" value="{$searchLabel}" name="Search" class="searchButton"/>
                  </form>
                  <div id="searchResults">
                    <xsl:comment/>
                  </div>
                </div>

                <div id="preload">
                  <xsl:if test="not($withFrames)">
                    <xsl:attribute name="style">display: none;</xsl:attribute>
                  </xsl:if>

                  <xsl:for-each select="/*">
                    <xsl:call-template name="getWebhelpString">
                      <xsl:with-param name="stringName" select="'Loading, please wait ...'"/>
                    </xsl:call-template>
                  </xsl:for-each>
                  <p>
                    <img src="oxygen-webhelp/resources/img/spinner.gif" alt="Loading"/>
                  </p>
                </div>

                <div id="contentBlock">
                  <div id="tab_nav_tree_placeholder">
                    <div id="expnd">
                      <a href="javascript:void(0);" onclick="collapseAll();" id="collapseAllLink"
                        title="CollapseAll">
                        <img src="oxygen-webhelp/resources/img/CollapseAll16.png" alt="Collapse All"
                          border="0"/>
                      </a>
                      <a href="javascript:void(0);" onclick="expandAll();" id="expandAllLink"
                        title="ExpandAll">
                        <img src="oxygen-webhelp/resources/img/ExpandAll16.png" alt="Expand All"
                          border="0"/>
                      </a>                      
                    </div>
                    <div id="tab_nav_tree" class="visible_tab">
                      <div id="tree">
                        <ul>
                          <xsl:apply-templates select="$toc" mode="create-toc"/>
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
                <xsl:if test="count($index/*) > 0">
                  <div id="indexBlock" style="display:none;">
                    <form action="javascript:void(0)" id="indexForm">
                      <fieldset>
                        <input type="text" name="search" value="" id="id_search" placeholder="Type To Filter"/>
                      </fieldset>
                    </form>
                    <div id="iList">
                      <ul id="indexList">
                        <xsl:apply-templates select="$index" mode="create-index"/>
                      </ul>
                    </div>
                  </div>
                </xsl:if>
              </div>
              <div class="footer">
                <xsl:call-template name="create-legal-section"/>
              </div>
            </div>
            <xsl:if test="not($withFrames)">
              <div id="rightPane">
                <iframe id="frm" src="./oxygen-webhelp/noScript.html" frameborder="0">
                  <p>Your browser does not support iframes.</p>
                </iframe>
              </div>
            </xsl:if>
            
          </div>
          <script type="text/javascript">
            <xsl:comment>                              
             $(function () {
                  $('input#id_search').keyup(function(){
                    $("ul#indexList li").hide();
                    if ($("input#id_search").val() != '' ) {
                      var sk=$("input#id_search").val();
                      $('ul#indexList').removeHighlight();
                      $('ul#indexList').highlight(sk,"highlight");

                      $("div:contains('"+sk+"')").each(function(){
                        if ($(this).parents("#indexList").size()>0){                          
                          $(this).show();
                          $(this).parentsUntil('#indexList').show();
                          $(this).parent().find('ul').show();
                          if ($(this).find('a').size()==0){
                            $(this).parent().find('ul li').show();                            
                          }                                                    
                        }
                      });
                    }else{
                      $("ul#indexList li").show();
                      $('ul#indexList').removeHighlight();
                    }
                  });
                });
            </xsl:comment>
          </script>
        </body>
      </html>
    </xsl:result-document>
  </xsl:template>
  
  <!-- Adds the legal stuff, the copyright and the legal notice. -->
  <xsl:template name="create-legal-section">
    <xsl:if test="
      $WEBHELP_COPYRIGHT != '' or 
      string-length($toc/toc:copyright) > 0 or 
      string-length($toc/toc:legalnotice) > 0
      ">
      <div class="legal" xmlns="http://www.w3.org/1999/xhtml">
        <div class="legalCopyright">
          <xsl:value-of select="$WEBHELP_COPYRIGHT"/>
          <xsl:if test="string-length($toc/toc:copyright) > 0">
            <br/>
            <xsl:copy-of select="$toc/toc:copyright/*"/>
          </xsl:if>
        </div>
        <xsl:if test="string-length($toc/toc:legalnotice) > 0">
          <div class="legalNotice">
            <xsl:copy-of select="$toc/toc:legalnotice/*"/>
          </div>
        </xsl:if>
      </div>
    </xsl:if>    
  </xsl:template>
  
  <!-- Generates the JS scripts. Extracted to template so it can be overriden 
    from other stylesheet. -->
  <xsl:template name="create-js-scripts">
    <xsl:param name="withFrames"/>
      <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" src="oxygen-webhelp/resources/js/jquery-1.8.2.min.js"><xsl:comment/></script>
      <script type="text/javascript" src="{$PATH2PROJ}oxygen-webhelp/resources/js/jquery.cookie.js"><xsl:comment/></script>
      <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" src="oxygen-webhelp/resources/js/jquery-ui.custom.min.js"><xsl:comment/></script>
      <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" charset="utf-8" src="oxygen-webhelp/resources/js/jquery.highlight-3.js"><!----></script>
    <xsl:call-template name="create-search-js-scripts"/>

      <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" charset="utf-8" src="oxygen-webhelp/resources/localization/strings.js"><xsl:comment/></script>
      <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" charset="utf-8" src="oxygen-webhelp/resources/js/localization.js"><xsl:comment/></script>
      <script xmlns="http://www.w3.org/1999/xhtml" src="./oxygen-webhelp/resources/js/browserDetect.js" type="text/javascript"><xsl:comment/></script>

      <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" charset="utf-8" src="oxygen-webhelp/resources/js/parseuri.js"><xsl:comment/></script>
    <xsl:if test="not($withFrames)">
        <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" charset="utf-8" src="oxygen-webhelp/resources/js/jquery.ba-hashchange.min.js"><xsl:comment/></script>
        <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" src="oxygen-webhelp/resources/js/splitter.js"><xsl:comment/></script>
    </xsl:if>

    <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" src="oxygen-webhelp/resources/js/log.js"><xsl:comment/></script>
    <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" src="oxygen-webhelp/resources/js/toc.js"><xsl:comment/></script>
      
    <xsl:if test="not($withFrames)">
      <!-- Custom JavaScript code set by param webhelp.head.script -->
      <xsl:if test="string-length($WEBHELP_HEAD_SCRIPT) > 0">
        <xsl:value-of select="unparsed-text($WEBHELP_HEAD_SCRIPT)" disable-output-escaping="yes"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="create-search-js-scripts">
      <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" src="oxygen-webhelp/search/htmlFileList.js"><xsl:comment/></script>
      <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" src="oxygen-webhelp/search/htmlFileInfoList.js"><xsl:comment/></script>
      <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" src="oxygen-webhelp/search/nwSearchFnt.js"><xsl:comment/></script>
    <xsl:variable name="LANG" select="lower-case(substring($DEFAULTLANG, 1, 2))"/>
    <xsl:if test="$LANG = 'en' or $LANG = 'fr' or $LANG = 'de'">
        <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" src="oxygen-webhelp/search/stemmers/{$LANG}_stemmer.js"><xsl:comment/></script>
    </xsl:if>
      <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" src="oxygen-webhelp/search/index-1.js"><xsl:comment/></script>
      <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" src="oxygen-webhelp/search/index-2.js"><xsl:comment/></script>
      <script xmlns="http://www.w3.org/1999/xhtml" type="text/javascript" src="oxygen-webhelp/search/index-3.js"><xsl:comment/></script>
  </xsl:template>


  <xsl:template match="toc:topic" mode="create-toc">
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="@title">
          <xsl:value-of select="@title"/>
        </xsl:when>
        <xsl:when test="@navtitle">
          <xsl:value-of select="@navtitle"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <li xmlns="http://www.w3.org/1999/xhtml">
      <span>
        <xsl:choose>
          <xsl:when test="@href">
            <a href="{@href}">
              <xsl:value-of select="$title"/>
            </a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$title"/>
          </xsl:otherwise>
        </xsl:choose>
      </span>
      <xsl:if test="toc:topic">
        <ul>
          <xsl:apply-templates select="toc:topic" mode="create-toc"/>
        </ul>
      </xsl:if>
    </li>
  </xsl:template>
  
  <!-- Inghibit output of text in the navigation tree. -->
  <xsl:template match="text()" mode="create-toc"/>
    
  
  <xsl:template match="index:term" mode="create-index">
    <li xmlns="http://www.w3.org/1999/xhtml">
      <div>
          <xsl:choose>
              <xsl:when test="count(index:target) = 1">
                  <a href="{index:target}" target="contentwin"><xsl:value-of select="@name"/></a>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@name"/>
              </xsl:otherwise>
          </xsl:choose>
            <xsl:for-each select="index:target">
              <xsl:text>  </xsl:text>
              <a href="{.}" target="contentwin">[<xsl:value-of select="position()"/>]</a>
              <xsl:text>  </xsl:text>
            </xsl:for-each>
      </div>
      <xsl:if test="index:term">
        <ul>
          <xsl:apply-templates select="index:term" mode="create-index"/>
        </ul>
      </xsl:if>
    </li>
  </xsl:template>


  <xsl:template match="*[contains(@class, ' topic/tm ')]">
    <xsl:choose>
      <xsl:when test="@tmtype='service'"> SM </xsl:when>
      <xsl:when test="@tmtype='tm'"> &#8482; </xsl:when>
      <xsl:when test="@tmtype='reg'"> &#174; </xsl:when>
      <xsl:otherwise>
        <xsl:text>[Error in tm type]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="b|strong|i|em|u|sub|sup">
    <xsl:element name="{name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>


    <xsl:template name="create-index-file">
    <xsl:param name="toc"/>
    <xsl:param name="title" as="node()"/>
    <xsl:variable name="firstTopic"
      select="($toc//toc:topic[@href and not(contains(@href, 'javascript'))])[1]/@href"/>
    <xsl:result-document href="index_frames.html" method="xhtml" indent="no" encoding="UTF-8"
        doctype-public="-//W3C//DTD XHTML 1.0 Frameset//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd"
        omit-xml-declaration="yes">
      <html xmlns="http://www.w3.org/1999/xhtml">
        <head>
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
          <title>
            <xsl:value-of select="$title"/>
          </title>
          <link rel="stylesheet" type="text/css" href="oxygen-webhelp/resources/css/commonltr.css">
            <xsl:comment/>
          </link>
          <link rel="stylesheet" type="text/css" href="oxygen-webhelp/resources/css/webhelp_topic.css">
            <xsl:comment/>
          </link>
            <!-- custom CSS -->
            <xsl:if test="string-length($CSS)>0">
                <xsl:variable name="urltest"> <!-- test for URL -->
                    <xsl:call-template name="url-string">
                        <xsl:with-param name="urltext">
                            <xsl:value-of select="concat($CSSPATH,$CSS)"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$urltest='url'">
                        <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$CSS}" >
                            <xsl:comment/>
                        </link>
                    </xsl:when>
                    <xsl:otherwise>
                        <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$CSS}" >
                            <xsl:comment/>
                        </link>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            
          <script type="text/javascript"><xsl:comment>
                        function getHTMLPage(){
                           var currentPage = "<xsl:value-of select="$firstTopic"/>";
                           var page = window.location.search.substr(1);
                  
                           if (page != ""){
                            page = page.split("=");
                            if (page[0] == 'q') currentPage = page[1];
                           }
                           
                           return currentPage;
                        }
                        </xsl:comment></script>
        </head>
        <frameset cols="25%,*" onload="frames.contentwin.location = getHTMLPage()">
          <frame name="tocwin" id="tocwin" src="toc.html"/>
          <frame name="contentwin" id="contentwin" src="./oxygen-webhelp/noScript.html"/>
        </frameset>
      </html>
    </xsl:result-document>
  </xsl:template>
    
    <xsl:template name="url-string">
        <xsl:param name="urltext"/>
        <xsl:choose>
            <xsl:when test="contains($urltext,'http://')">url</xsl:when>
            <xsl:when test="contains($urltext,'https://')">url</xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
