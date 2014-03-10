<?xml version="1.0"?>
<!--
////////////////////////////////////
/// December 2011
/// Bryan Schnabel
/// DITA-XLIFF Roundtrip Tool for DITA OT version 0.01
/// (c) Copyright Bryan Schnabel
/// 
/// Apache License\
/// Version 2.0, January 2004
/// http://www.apache.org/licenses/ 
////////////////////////////////////
-->

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
               xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
               xmlns:opentopic="http://www.idiominc.com/opentopic"
               xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
               xmlns:xmrk="urn:xmarker"
               version="1.0">

<xsl:output method="xml" indent="yes" encoding="utf-8" />

<xsl:strip-space elements="*" />

<!--
strategy: this code gives me every topic and map in play, and their path, regardless of
how deeply nedsted - and it gives me (will give me) all the content that needs to be translated
-->

<!-- note: will need to try to use absolute file paths - I'm leary of this -->

<xsl:template match="node()|@*">
 <xsl:copy>
  <xsl:apply-templates select="@*|node()"/>
 </xsl:copy>
</xsl:template>


<xsl:template match="node()|@*" mode="skel">
 <xsl:copy>
  <xsl:apply-templates select="@*|node()" mode="skel" />
 </xsl:copy>
</xsl:template>

<xsl:template match="node()|@*" mode="body2">
 <xsl:copy>
  <xsl:apply-templates select="@*|node()" mode="body2" />
 </xsl:copy>
</xsl:template>

<xsl:template match="*/text()" mode="skel" />

<!-- Just grabbing the root element here -->
<xsl:template match="/*" priority="5">
  <xsl:variable name="raw_ab_path" select="concat('file:///',translate(@xtrf,'\','/'))" />
  <xsl:variable name="mydir">
   <xsl:for-each select="@xtrf">
    <xsl:variable name="norm_path" select="translate(.,'\','/')" />
     <xsl:choose>
      <xsl:when test="contains($norm_path, '/')">
       <xsl:call-template name="mydir">
        <xsl:with-param name="mydirbefore">
         <xsl:value-of select="substring-before($norm_path,'/')" />
        </xsl:with-param>
        <xsl:with-param name="mydirafter">
         <xsl:value-of select="substring-after($norm_path,'/')" />
        </xsl:with-param>
        <xsl:with-param name="mydirnow">
         <xsl:value-of select="substring-before($norm_path,'/')" />
        </xsl:with-param>
       </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="$norm_path" />
      </xsl:otherwise>
     </xsl:choose>
   </xsl:for-each>
  </xsl:variable>
  <xliff xsi:schemaLocation="urn:oasis:names:tc:xliff:document:1.2                   xliff-core-1.2-strict.xsd
         urn:xmarker           xmarker.xsd" 
         version="1.2" 
         xmlns:xmrk="urn:xmarker" 
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
         xmlns="urn:oasis:names:tc:xliff:document:1.2">

<!--
      <xsl:apply-templates select="opentopic:*[local-name()='bookmap' or local-name()='dita' or local-name()='concept' or local-name()='task' 
              or local-name()='topic' or local-name()='glossentry' or local-name()='glossgroup' or local-name()='learningAssessment' 
              or local-name()='bookmap' or local-name()='learningContent' or local-name()='map' or local-name()='learningOverview' 
              or local-name()='learningPlan' or local-name()='learningSummary' or local-name()='reference' or local-name()='subjectScheme' 
              or local-name()='topicref' or local-name()='mapref']" mode="filefind">
-->
      <xsl:apply-templates select="opentopic:*" mode="filefind">
       <xsl:with-param name="mydir">
        <xsl:value-of select="$mydir" />
       </xsl:with-param>
       <xsl:with-param name="raw_ab_path">
        <xsl:value-of select="$raw_ab_path" />
       </xsl:with-param>
      </xsl:apply-templates>
  </xliff>
</xsl:template>

<xsl:template name="mydir">
 <xsl:param name="mydirbefore" />
 <xsl:param name="mydirafter" />
 <xsl:param name="mydirnow" />
  <xsl:choose>
   <xsl:when test="contains($mydirafter,'/')">
       <xsl:call-template name="mydir">
        <xsl:with-param name="mydirbefore">
         <xsl:value-of select="concat($mydirbefore,'/',(substring-before($mydirafter,'/')))" />
        </xsl:with-param>
        <xsl:with-param name="mydirafter">
         <xsl:value-of select="substring-after($mydirafter,'/')" />
        </xsl:with-param>
        <xsl:with-param name="mydirnow">
         <xsl:value-of select="concat($mydirbefore,'/')" />
        </xsl:with-param>
       </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="concat($mydirbefore,'')" /><!-- not needed -->
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="*" priority="1" mode="filefind">
 <xsl:param name="mydir" />
 <xsl:param name="raw_ab_path" />
  <xsl:for-each select="@class">
   <xsl:copy />
  </xsl:for-each>
  <xsl:for-each select="@xtrf">
   <xsl:attribute name="extradata">
    <xsl:value-of select="." />
   </xsl:attribute>
  </xsl:for-each><!-- here's the key -->
  <xsl:for-each select="//*[@xtrf]">
   <xsl:variable name="xtrf" select="@xtrf" />
   <xsl:if test="local-name()='bookmap' or local-name()='dita' or local-name()='concept' or local-name()='task' 
              or local-name()='topic' or local-name()='glossentry' or local-name()='glossgroup' or local-name()='learningAssessment' 
              or local-name()='bookmap' or local-name()='learningContent' or local-name()='map' or local-name()='learningOverview' 
              or local-name()='learningPlan' or local-name()='learningSummary' or local-name()='reference' or local-name()='subjectScheme' 
              or local-name()='topicref' or local-name()='mapref'">

   <xsl:if test="count(preceding::topicref[@xtrf=$xtrf])=0 and 
                 count(preceding::mapref[@xtrf=$xtrf])=0 and 
                 count(ancestor::mapref[@xtrf=$xtrf])=0 and 
                 count(ancestor::map[@xtrf=$xtrf])=0 and 
                 count(ancestor::topicref[@xtrf=$xtrf])=0">
    <xsl:variable name="local_raw_ab_path" select="concat('file:///',translate(@xtrf,'\','/'))" />
    <xsl:variable name="sameofpath">
     <xsl:call-template name="sameofpath">
      <xsl:with-param name="rootdir">
       <xsl:value-of select="$mydir" />
      </xsl:with-param>
      <xsl:with-param name="thispath">
       <xsl:value-of select="translate(@xtrf,'\','/')" />
      </xsl:with-param>
      <xsl:with-param name="matchpath">
       <xsl:value-of select="''" />
      </xsl:with-param>
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="mydir_slashes">
     <xsl:call-template name="mydir_slashes">
      <xsl:with-param name="thispath">
       <xsl:value-of select="translate($mydir,'\','/')" />
      </xsl:with-param>
      <xsl:with-param name="slash_count">
       <xsl:value-of select="'0'" />
      </xsl:with-param>
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="sameofpath_slashes">
     <xsl:call-template name="sameofpath_slashes">
      <xsl:with-param name="thispath">
       <xsl:value-of select="substring-before($sameofpath,'/AND')" />
      </xsl:with-param>
      <xsl:with-param name="slash_count">
       <xsl:value-of select="'0'" />
      </xsl:with-param>
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="slash_diff" select="$mydir_slashes - $sameofpath_slashes" />
    <xsl:variable name="slash_maker">
     <xsl:call-template name="slash-maker">
      <xsl:with-param name="slash_diff">
       <xsl:value-of select="$slash_diff" />
      </xsl:with-param>
      <xsl:with-param name="slash_concat">
       <xsl:value-of select="''" />
      </xsl:with-param>
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="same_root">
     <xsl:choose>
      <xsl:when test="substring-before($sameofpath,'/AND') = $mydir">
       <xsl:value-of select="'match'" />
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="concat('mis-match: ',$slash_diff)" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>
    <xsl:variable name="document_funct_get">
     <xsl:choose>
      <xsl:when test="$same_root='match'">
       <xsl:value-of select="substring-after($sameofpath,'/AND')" />
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="concat($slash_maker,substring-after($sameofpath,'/AND'))" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>
    <file datatype="plaintext" source-language="en_US" original="{@xtrf}" build-num="{generate-id()}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
     <header>
      <xsl:if test="local-name()='bookmap' or local-name()='dita' or local-name()='concept' or local-name()='task' 
                 or local-name()='topic' or local-name()='glossentry' or local-name()='glossgroup' or local-name()='learningAssessment' 
                 or local-name()='bookmap' or local-name()='learningContent' or local-name()='map' or local-name()='learningOverview' 
                 or local-name()='learningPlan' or local-name()='learningSummary' or local-name()='reference' or local-name()='subjectScheme' 
                 or local-name()='topicref' or local-name()='mapref'
                 ">
       <xmrk:nest>
        <xmrk:type u_id="{@id}">
          <xsl:value-of select="local-name()" />
        </xmrk:type>
        <xmrk:outputURI>
          <xsl:value-of select="$document_funct_get" />
        </xmrk:outputURI>
        <xmrk:file xtrf="{@xtrf}">
          <xsl:for-each select="document($local_raw_ab_path)">
           <xsl:apply-templates mode="skel" />
          </xsl:for-each>
        </xmrk:file>
       </xmrk:nest>
      </xsl:if>
     </header>
     <body>
      <xsl:if test="local-name()='bookmap' or local-name()='dita' or local-name()='concept' or local-name()='task' 
                 or local-name()='topic' or local-name()='glossentry' or local-name()='glossgroup' or local-name()='learningAssessment' 
                 or local-name()='bookmap' or local-name()='learningContent' or local-name()='map' or local-name()='learningOverview' 
                 or local-name()='learningPlan' or local-name()='learningSummary' or local-name()='reference' or local-name()='subjectScheme' 
                 or local-name()='topicref' or local-name()='mapref'
                 ">
          <xsl:for-each select="document($local_raw_ab_path)">
           <xsl:apply-templates mode="body2" />
          </xsl:for-each>
      </xsl:if>
     </body>
    </file>
    </xsl:if>
   </xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template name="sameofpath">
 <xsl:param name="rootdir" />
 <xsl:param name="thispath" />
 <xsl:param name="matchpath" />
<!-- the otherwise in the two following tests are to catch the last layer of
     dir name that will not have a '/' - need to test this pretty rigorisly -->
 <xsl:variable name="root_test">
  <xsl:choose>
   <xsl:when test="contains($rootdir,'/')">
    <xsl:value-of select="concat(substring-before($rootdir,'/'),'/')" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="concat($rootdir,'/')" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <xsl:variable name="thispath_test">
  <xsl:choose>
   <xsl:when test="contains($thispath,'/')">
    <xsl:value-of select="concat(substring-before($thispath,'/'),'/')" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="concat($thispath,'/')" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <xsl:variable name="root_leftover" select="substring-after($rootdir,'/')" />
 <xsl:variable name="thispath_leftover" select="substring-after($thispath,'/')" />
 <xsl:variable name="concat_paths">
  <xsl:choose>
   <xsl:when test="$root_test = $thispath_test">
    <xsl:value-of select="concat($matchpath,$thispath_test)" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$matchpath" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
<!-- NOTE: here I am - getting good results - should be able to find all topics and maps and do a
     document(''), to grab what a need for the D2X leg -->
  <xsl:choose>
   <xsl:when test="$matchpath = $concat_paths">
    <xsl:value-of select="$concat_paths" />
    <xsl:text>AND</xsl:text>
    <xsl:value-of select="$thispath" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:call-template name="sameofpath">
     <xsl:with-param name="rootdir">
      <xsl:choose>
       <xsl:when test="contains($root_leftover,'/')">
        <xsl:value-of select="$root_leftover" />
       </xsl:when>
       <xsl:otherwise>
        <xsl:value-of select="concat($root_leftover,'')" /><!-- tst not needed-->
       </xsl:otherwise>
      </xsl:choose>
     </xsl:with-param>
     <xsl:with-param name="thispath">
      <xsl:value-of select="$thispath_leftover" />
     </xsl:with-param>
     <xsl:with-param name="matchpath">
      <xsl:value-of select="$concat_paths" />
     </xsl:with-param>
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="mydir_slashes">
 <xsl:param name="thispath" />
 <xsl:param name="slash_count" />
 <xsl:choose>
  <xsl:when test="contains($thispath, '/')">
    <xsl:call-template name="mydir_slashes">
     <xsl:with-param name="thispath">
      <xsl:value-of select="substring-after($thispath, '/')" />
     </xsl:with-param>
     <xsl:with-param name="slash_count">
      <xsl:value-of select="$slash_count + 1" />
     </xsl:with-param>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
   <xsl:value-of select="$slash_count" />
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template name="sameofpath_slashes">
 <xsl:param name="thispath" />
 <xsl:param name="slash_count" />
 <xsl:choose>
  <xsl:when test="contains($thispath, '/')">
    <xsl:call-template name="sameofpath_slashes">
     <xsl:with-param name="thispath">
      <xsl:value-of select="substring-after($thispath, '/')" />
     </xsl:with-param>
     <xsl:with-param name="slash_count">
      <xsl:value-of select="$slash_count + 1" />
     </xsl:with-param>
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
   <xsl:value-of select="$slash_count" />
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template name="slash-maker">
 <xsl:param name="slash_diff" />
 <xsl:param name="slash_concat" />
  <xsl:choose>
   <xsl:when test="$slash_diff &gt; 0">
    <xsl:call-template name="slash-maker">
     <xsl:with-param name="slash_diff">
      <xsl:value-of select="$slash_diff - 1" />
     </xsl:with-param>
     <xsl:with-param name="slash_concat">
      <xsl:value-of select="concat($slash_concat,'../')" />
     </xsl:with-param>
    </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$slash_concat" />
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="/*" mode="skel"><!-- this never fires -->
 <xsl:element name="{name()}" namespace="urn:xmarker">
  <xsl:for-each select="@*">
   <xsl:copy />
  </xsl:for-each>
   <xsl:apply-templates mode="skel" />
 </xsl:element>
</xsl:template>

<xsl:template match="*" mode="skel" priority="50">
 <xsl:element name="{concat('xmrk:',local-name())}" namespace="urn:xmarker">
<!--
  <xsl:attribute name="id">
   <xsl:value-of select="@id" />
  </xsl:attribute>-->


  <xsl:attribute name="xmarker_idref">
   <xsl:value-of select="concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))" />
  </xsl:attribute>
  <xsl:for-each select="@*">
   <xsl:attribute name="{name()}">
    <xsl:value-of select="." />
   </xsl:attribute>
  </xsl:for-each>  
  <xsl:apply-templates mode="skel" />
 </xsl:element>
</xsl:template>

<xsl:template match="text()" mode="skel" priority="51" />

<!-- body 

<xsl:template match="/*" mode="body2">
 <ggroup>
 <xsl:element name="{name()}">
  <xsl:for-each select="@*">
   <xsl:copy />
  </xsl:for-each>
   <xsl:apply-templates mode="body2" />
 </xsl:element>
 </ggroup>
</xsl:template>-->

<xsl:template match="*" mode="body2" priority="50">
  <xsl:call-template name="inner" />
</xsl:template>

<!-- from other -->
<xsl:template match="*[count(ancestor::*)>'0'][not(ancestor::*[text()])][child::*]" priority="100" mode="body2">
 <xsl:variable name="ancestors" select="count(ancestor::*)" />
  <xsl:call-template name="inner" />
</xsl:template>

<xsl:template name="inner">
 <xsl:variable name="ancestors" select="count(ancestor::*)" />
 <xsl:choose>
<!-- has text, parent has text-->
  <xsl:when test="text() and parent::*[text()]">
   <g id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
    <xsl:apply-templates mode="body2" />
   </g>
  </xsl:when>
<!-- has text, ancestor has no text -->
  <xsl:when test="text() and not(ancestor::*[text()])">
   <trans-unit id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
    <source>
     <xsl:apply-templates mode="body2" />
    </source>
    <target>
     <xsl:if test="@translate='no' or contains(ancestor::*/@translate,'no')">
      <xsl:attribute name="state">
       <xsl:text>final</xsl:text>
      </xsl:attribute>
     </xsl:if>
     <xsl:apply-templates mode="body2" />
    </target>
   </trans-unit>
  </xsl:when>
<!-- has text, ancestor has text -->
  <xsl:when test="text() and ancestor::*[text()]">
   <g id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
     <xsl:apply-templates mode="body2" />
   </g>
  </xsl:when>
<!-- has no text, ancestor has no text -->
  <xsl:when test="not(text()) and not(ancestor::*[text()]) and child::*">
   <group xmlns="urn:oasis:names:tc:xliff:document:1.2" id="{concat(generate-id(),'bxmark',local-name(),'-',(count(preceding::*)+count(ancestor::*)))}">
     <xsl:apply-templates mode="body2" />
   </group>
  </xsl:when>
<!-- has no text, ancestor has text -->
  <xsl:when test="not(text()) and ancestor::*[text()] and child::*">
    <g id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
     <xsl:apply-templates mode="body2" />
    </g>
  </xsl:when>
<!-- has no text, has child, parent has text -->
  <xsl:when test="not(text()) and parent::*[text()] and child::*">
   <g id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
    <xsl:apply-templates mode="body2" />
   </g>
  </xsl:when>
<!-- has no text, has no child, parent has text -->
  <xsl:when test="not(text()) and parent::*[text()] and not(child::*)">
   <x id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
    <xsl:apply-templates mode="body2" />
   </x>
  </xsl:when>
<!-- has no text, has no child, ancestor has no text -->
<!-- rev 0.7, maybe take this out -->
  <xsl:when test="not(text()) and not(ancestor::*[text()]) and not(child::*)">
   <group xmlns="urn:oasis:names:tc:xliff:document:1.2" id="{concat(generate-id(),'cxmark',local-name(),'-',(count(preceding::*)+count(ancestor::*)))}">
   </group>
  </xsl:when>
<!-- has no text, has no child, ancestor has text -->
  <xsl:when test="not(text()) and ancestor::*[text()] and not(child::*)">
      <x id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
       <xsl:apply-templates mode="body2" />
      </x>
  </xsl:when>
  <xsl:otherwise>
   <blip was="{name()}" id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}">
    <xsl:apply-templates mode="body2" />
   </blip>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="*[count(ancestor::*)>'0']" mode="body2">
 <xsl:variable name="ancestors" select="count(ancestor::*)" />
 <xsl:choose>
<!-- has text, parent has text-->
  <xsl:when test="text() and parent::*[text()]">
   <g id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
    <xsl:apply-templates mode="body2" />
   </g>
  </xsl:when>
<!-- has text, ancestor has no text -->
  <xsl:when test="text() and not(ancestor::*[text()])">
   <trans-unit id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
    <source>
     <xsl:apply-templates mode="body2" />
    </source>
    <target>
          <xsl:if test="@translate='no' or contains(ancestor::*/@translate,'no')">
      <xsl:attribute name="state">
       <xsl:text>final</xsl:text>
      </xsl:attribute>
     </xsl:if>
     <xsl:apply-templates mode="body2" />
    </target>
   </trans-unit>
  </xsl:when>
<!-- has text, ancestor has text -->
  <xsl:when test="text() and ancestor::*[text()]">
   <g id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
     <xsl:apply-templates mode="body2" />
   </g>
  </xsl:when>
<!-- has no text, ancestor has no text -->
  <xsl:when test="not(text()) and not(ancestor::*[text()]) and child::*">
   <group xmlns="urn:oasis:names:tc:xliff:document:1.2" id="{concat(generate-id(),'dxmark',local-name(),'-',(count(preceding::*)+count(ancestor::*)))}">
     <xsl:apply-templates mode="body2" />
   </group>
  </xsl:when>
<!-- has no text, ancestor has text -->
  <xsl:when test="not(text()) and ancestor::*[text()] and child::*">
    <g id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
     <xsl:apply-templates mode="body2" />
    </g>
  </xsl:when>
<!-- has no text, has child, parent has text -->
  <xsl:when test="not(text()) and parent::*[text()] and child::*">
   <g id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
    <xsl:apply-templates mode="body2" />
   </g>
  </xsl:when>
<!-- has no text, has no child, parent has text -->
  <xsl:when test="not(text()) and parent::*[text()] and not(child::*)">
   <x id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
    <xsl:apply-templates mode="body2" />
   </x>
  </xsl:when>
<!-- has no text, has no child, ancestor has no text -->
  <xsl:when test="not(text()) and not(ancestor::*[text()]) and not(child::*)">
   <group xmlns="urn:oasis:names:tc:xliff:document:1.2" id="{concat(generate-id(),'exmark',local-name(),'-',(count(preceding::*)+count(ancestor::*)))}">
   </group>
  </xsl:when>
<!-- has no text, has no child, ancestor has text -->
  <xsl:when test="not(text()) and ancestor::*[text()] and not(child::*)">
      <x id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}" xmlns="urn:oasis:names:tc:xliff:document:1.2">
       <xsl:apply-templates mode="body2" />
      </x>
  </xsl:when>
  <xsl:otherwise>
   <blip was="{name()}" ancs="{$ancestors}" id="{concat(local-name(),'-',(count(preceding::*)+count(ancestor::*)))}">
    <xsl:apply-templates mode="body2" />
   </blip>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>


</xsl:transform>
