<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!-- stylsheet for plugin that uses jquery mobile -->
<!-- import default OT xhtml transform -->
<xsl:import href="../../../xsl/dita2xhtml.xsl"></xsl:import>


<xsl:param name="YEAR" select="'2012'"/>

<!-- ========== STUBS FOR USER PROVIDED OVERRIDE EXTENSIONS ========== -->

<xsl:template name="gen-user-head">
  <xsl:apply-templates select="." mode="gen-user-head"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-head">
  <!-- sets width to pixel-width of device, still allows zooming -->
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
</xsl:template>

<xsl:template name="gen-user-scripts">
  <xsl:apply-templates select="." mode="gen-user-scripts"/>
</xsl:template>
<xsl:template match="/|node()|@*" mode="gen-user-scripts">
 <script type="text/javascript" src="http://code.jquery.com/jquery-1.6.4.min.js"><xsl:text> </xsl:text></script>
 <script type="text/javascript" src="http://code.jquery.com/mobile/1.0rc2/jquery.mobile-1.0rc2.min.js"><xsl:text> </xsl:text></script>
</xsl:template>

<!-- ========== OVERRIDE CREATION OF BODY ELEMENT  ========== -->
<!-- add search field; very little changed here -->

 <xsl:template name="chapterBody">
    <xsl:apply-templates select="." mode="chapterBody"/>
  </xsl:template>
  <xsl:template match="*" mode="chapterBody">
    <xsl:variable name="flagrules">
      <xsl:call-template name="getrules"/>
    </xsl:variable>
    <body>
    <form action="#" method="get">
    <label for="search-basic">Search Input:</label>
	<input type="search" name="search" id="search-basic" value="" /></form>
      <!-- Already put xml:lang on <html>; do not copy to body with commonattributes -->
      <xsl:call-template name="gen-style">
        <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
      </xsl:call-template>
      <!--output parent or first "topic" tag's outputclass as class -->
      <xsl:if test="@outputclass">
       <xsl:attribute name="class"><xsl:value-of select="@outputclass" /></xsl:attribute>
      </xsl:if>
      <xsl:if test="self::dita">
          <xsl:if test="*[contains(@class,' topic/topic ')][1]/@outputclass">
           <xsl:attribute name="class"><xsl:value-of select="*[contains(@class,' topic/topic ')][1]/@outputclass" /></xsl:attribute>
          </xsl:if>
      </xsl:if>
      <xsl:apply-templates select="." mode="addAttributesToBody"/>
      <xsl:call-template name="setidaname"/>
      <xsl:value-of select="$newline"/>
      <xsl:call-template name="start-flagit">
        <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
      </xsl:call-template>
      <xsl:call-template name="start-revflag">
        <xsl:with-param name="flagrules" select="$flagrules"/>
      </xsl:call-template>
      <xsl:call-template name="generateBreadcrumbs"/>
      <xsl:call-template name="gen-user-header"/>  <!-- include user's XSL running header here -->
      <xsl:call-template name="processHDR"/>
      <xsl:if test="$INDEXSHOW='yes'">
        <xsl:apply-templates select="/*/*[contains(@class,' topic/prolog ')]/*[contains(@class,' topic/metadata ')]/*[contains(@class,' topic/keywords ')]/*[contains(@class,' topic/indexterm ')] |
                                     /dita/*[1]/*[contains(@class,' topic/prolog ')]/*[contains(@class,' topic/metadata ')]/*[contains(@class,' topic/keywords ')]/*[contains(@class,' topic/indexterm ')]"/>
      </xsl:if>
      <!-- Include a user's XSL call here to generate a toc based on what's a child of topic -->
      <xsl:call-template name="gen-user-sidetoc"/>
      <xsl:apply-templates/> <!-- this will include all things within topic; therefore, -->
      <!-- title content will appear here by fall-through -->
      <!-- followed by prolog (but no fall-through is permitted for it) -->
      <!-- followed by body content, again by fall-through in document order -->
      <!-- followed by related links -->
      <!-- followed by child topics by fall-through -->
      
      <xsl:call-template name="gen-endnotes"/>    <!-- include footnote-endnotes -->
      <xsl:call-template name="gen-user-footer"/> <!-- include user's XSL running footer here -->
      <xsl:call-template name="processFTR"/>      <!-- Include XHTML footer, if specified -->
      <xsl:call-template name="end-revflag">
        <xsl:with-param name="flagrules" select="$flagrules"/>
      </xsl:call-template>
      <xsl:call-template name="end-flagit">
        <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
      </xsl:call-template>
    </body>
    <xsl:value-of select="$newline"/>
  </xsl:template>


<!-- ========== OVERRIDE CREATION OF DIV FOR EACH TOPIC ========== -->
<!-- child topics get a div wrapper and fall through -->
<xsl:template match="*[contains(@class,' topic/topic ')]" mode="child.topic" name="child.topic">
  <xsl:param name="nestlevel">
      <xsl:choose>
          <!-- Limit depth for historical reasons, could allow any depth. Previously limit was 5. -->
          <xsl:when test="count(ancestor::*[contains(@class,' topic/topic ')]) > 9">9</xsl:when>
          <xsl:otherwise><xsl:value-of select="count(ancestor::*[contains(@class,' topic/topic ')])"/></xsl:otherwise>
      </xsl:choose>
  </xsl:param>
<div class="nested{$nestlevel}" data-role="page">
	 <xsl:call-template name="gen-topic"/>
</div><xsl:value-of select="$newline"/>
</xsl:template>

<!-- ========== OVERRIDE HEADING LEVEL FOR FIRST-LEVEL TOPICS ========== -->
<!-- will these change all headings to h2? keeping headinglevel param so that I can compare the h2 to the actual topic nesting level-->
<!-- NESTED TOPIC TITLES (sensitive to nesting depth, but are still processed for contained markup) -->
<!-- 1st level - topic/title -->
<!-- Condensed topic title into single template without priorities; use $headinglevel to set heading.
     If desired, somebody could pass in the value to manually set the heading level -->
<xsl:template match="*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]">
  <xsl:param name="headinglevel">
      <xsl:choose>
          <xsl:when test="count(ancestor::*[contains(@class,' topic/topic ')]) > 6">6</xsl:when>
          <xsl:otherwise><xsl:value-of select="count(ancestor::*[contains(@class,' topic/topic ')])"/></xsl:otherwise>
      </xsl:choose>
  </xsl:param>
  <div data-role="header"><h1>DITA 2 jQuery Mobile - set in dita2jqmobile.xsl</h1></div>
  <xsl:element name="h2">
      <xsl:attribute name="class">topictitle<xsl:value-of select="$headinglevel"/></xsl:attribute>
      <xsl:call-template name="commonattributes">
        <xsl:with-param name="default-output-class">topictitle<xsl:value-of select="$headinglevel"/></xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates/>
  </xsl:element>
  <xsl:value-of select="$newline"/>
</xsl:template>

<!-- =========== BODY/SECTION (not sensitive to nesting depth) =========== -->

<xsl:template match="*[contains(@class,' topic/body ')]" name="topic.body">
<!-- link id for Home and Next buttons-->
<xsl:param name="homeId" select="//concept[position()=1]/@id"></xsl:param>
<xsl:param name="nextId" select="following::concept[1]/@id"></xsl:param>
<!-- video ID -->
<xsl:param name="videoId" select="//keyword[contains (text(), 'videoON')]/following-sibling::keyword/text()"></xsl:param>
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
<div>
  <xsl:call-template name="commonattributes"/>
  <xsl:call-template name="gen-style">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <xsl:call-template name="setidaname"/>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>  
  </xsl:call-template>
  <!-- here, you can generate a toc based on what's a child of body -->
  <!--xsl:call-template name="gen-sect-ptoc"/--><!-- Works; not always wanted, though; could add a param to enable it.-->

  <!-- Insert prev/next links. since they need to be scoped by who they're 'pooled' with, apply-templates in 'hierarchylink' mode to linkpools (or related-links itself) when they have children that have any of the following characteristics:
       - role=ancestor (used for breadcrumb)
       - role=next or role=previous (used for left-arrow and right-arrow before the breadcrumb)
       - importance=required AND no role, or role=sibling or role=friend or role=previous or role=cousin (to generate prerequisite links)
       - we can't just assume that links with importance=required are prerequisites, since a topic with eg role='next' might be required, while at the same time by definition not a prerequisite -->

  <!-- Added for DITA 1.1 "Shortdesc proposal" -->
  <!-- get the abstract para -->
  <xsl:apply-templates select="preceding-sibling::*[contains(@class,' topic/abstract ')]" mode="outofline"/>
  
  <!-- get the shortdesc para -->
  <xsl:apply-templates select="preceding-sibling::*[contains(@class,' topic/shortdesc ')]" mode="outofline"/>
  
  <!-- Insert pre-req links - after shortdesc - unless there is a prereq section about -->
  <xsl:apply-templates select="following-sibling::*[contains(@class,' topic/related-links ')]" mode="prereqs"/>

  <xsl:apply-templates/>
  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>  
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param> 
  </xsl:call-template>
</div><xsl:value-of select="$newline"/>

	<!-- if there is a video referenced in the prolog, embed it on the page  *** this is specific to CitrixTV videos
	<xsl:if test="preceding-sibling::prolog//keyword[contains (text(), 'videoON')]">
	<object id='CitrixTVEmbed724' class='CitrixTVEmbed'>
		<xsl:element name="param">
			<xsl:attribute name="name">ctvId</xsl:attribute>
			<xsl:attribute name="value"><xsl:value-of select="$videoId"></xsl:value-of></xsl:attribute>
		</xsl:element>
		<param name='width' value='480' /><param name='height' value='270' /><param name='hd' value='false' /><param name='autoStart' value='false' />
	</object>
	<SCRIPT type='text/javascript'>/* <![CDATA[ */var CITRIXWS=CITRIXWS||{};(function(){var playerId='CitrixTVEmbed724',c=window.CITRIXWS;if(!(c.ctvPlayer)){c._ctvq=c._ctvq||[];c._ctvq.push(playerId);var ctv=document.createElement('script');ctv.type='text/javascript';ctv.async=true;ctv.src='https://www.citrix.com/static/ctv/player/js/CitrixTVEmbed.js';var s=document.getElementsByTagName('script')[0];s.parentNode.insertBefore(ctv,s)}else{c.ctvPlayer.Embedder.createPlayer(playerId)}})();/* ]]> */</SCRIPT>	
	</xsl:if>
<xsl:value-of select="$newline"/>
-->

<!-- create footer with navigation and copyright -->
<div data-role="footer">
	<div data-role="navbar">
		<ul>
			<li><xsl:element name="a">
					<xsl:attribute name="href">#<xsl:value-of select="$homeId"></xsl:value-of></xsl:attribute>
					<xsl:attribute name="data-role">button</xsl:attribute>
					<xsl:attribute name="data-transition">flip</xsl:attribute>
					<xsl:attribute name="data-icon">home</xsl:attribute>
					<!--<xsl:attribute name="data-iconpos">notext</xsl:attribute>-->
<!--					<xsl:attribute name="data-theme">b</xsl:attribute>
-->					<xsl:attribute name="data-inline">true</xsl:attribute>Return to First Page
				</xsl:element>
			</li>
	<li><xsl:element name="a">
				<xsl:attribute name="href">#<xsl:value-of select="$nextId"></xsl:value-of></xsl:attribute>
				<xsl:attribute name="data-role">button</xsl:attribute>
				<xsl:attribute name="data-transition">slide</xsl:attribute>
				<xsl:attribute name="data-icon">arrow-r</xsl:attribute>
				<!--<xsl:attribute name="data-iconpos">notext</xsl:attribute>-->
<!--				<xsl:attribute name="data-theme">b</xsl:attribute>
-->				<xsl:attribute name="data-inline">true</xsl:attribute>Go to Next Page
		</xsl:element>
	</li>
		</ul>
	</div>
<p align="center">Copyright 2012 - set in dita2jqmobile.xsl</p>
</div><xsl:value-of select="$newline"/>
</xsl:template>

<!-- =========== REMOVE TITLE PAGE PARAGRAPH =========== -->

<xsl:template match="p[contains(@outputclass,'titlepage')]">
</xsl:template>

<xsl:template match="dd/b">
</xsl:template>

<!-- =========== DEFINITION LIST to COLLAPSIBLE DIV =========== -->
<xsl:template match="*[contains(@class,' topic/dl ')]"  mode="dl-fmt">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <xsl:call-template name="start-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>     
  </xsl:call-template>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
<xsl:call-template name="setaname"/>
<xsl:for-each select="child::dlentry">
<div data-role="collapsible" data-collapsed="true">
<h3><xsl:value-of select="child::dt/text()"></xsl:value-of></h3>
<p><xsl:copy-of select="child::dd"></xsl:copy-of></p>
</div>
</xsl:for-each>
</xsl:template>

<!-- =========== SIMPLE TABLE ENTRY to COLLAPSIBLE DIVs =========== -->
<xsl:template match="*[contains(@class,' topic/simpletable ')]">
<xsl:choose>
	<!--when the table contains an image, use default OT processing. -->
	<xsl:when test="exists(descendant::image)">
		<xsl:call-template name="topic.simpletable"/>
	</xsl:when>
	<!-- when the first stentry of a sthead contains the text "mark", use default OT processing-->
	<xsl:when test="sthead/stentry[1]/text()[contains(., 'Mark')]">
			<xsl:call-template name="topic.simpletable"/>
	</xsl:when>
	<!-- when it doesn't meet those criteria, create collapsible div's -->
	<xsl:otherwise>
	<xsl:for-each select="child::strow">
	<div data-role="collapsible" data-collapsed="true">
	<h3><xsl:value-of select="stentry[1]/text()"></xsl:value-of></h3>	
	<p><xsl:copy-of select="stentry[2]"></xsl:copy-of></p>
	</div>
	</xsl:for-each>
	</xsl:otherwise>
</xsl:choose>
<xsl:value-of select="$newline"/>
</xsl:template>

</xsl:stylesheet>
