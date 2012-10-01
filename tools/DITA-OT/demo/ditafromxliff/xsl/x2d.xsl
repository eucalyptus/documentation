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
               version="2.0"
               xmlns:xlf="urn:oasis:names:tc:xliff:document:1.2"
               xmlns:xmrk="urn:xmarker">

<xsl:output method="xml" indent="yes" encoding="utf-8" />


<xsl:strip-space elements="*" />

<xsl:template match="comment()" priority="5" />

<xsl:template match="node()|@*">
 <xsl:copy>
  <xsl:apply-templates select="@*|node()"/>
 </xsl:copy>
</xsl:template>

<xsl:template match="xlf:xliff|xlf:header|xlf:body|xlf:target|xmrk:nest" priority="3">
 <xsl:param name="target-lang" />
  <xsl:apply-templates>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="xlf:file" priority="3">

 <xsl:variable name="target-lang">
  <xsl:choose>
   <xsl:when test="@target-language">
    <xsl:value-of select="@target-language" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>not-set</xsl:text>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <xsl:variable name="type" select="xlf:header/xmrk:nest/xmrk:type" />
 <xsl:variable name="filename">
  <xsl:call-template name="filename">
   <xsl:with-param name="path">
    <xsl:value-of select="xlf:header/xmrk:nest/xmrk:outputURI" />
   </xsl:with-param>
  </xsl:call-template>
 </xsl:variable>
 <xsl:variable name="just-path">
  <xsl:call-template name="just-path">
   <xsl:with-param name="path">
    <xsl:value-of select="xlf:header/xmrk:nest/xmrk:outputURI" />
   </xsl:with-param>
  </xsl:call-template>
 </xsl:variable>
 <xsl:variable name="path-plus-file" select="concat('/root_directory',$just-path,'/',$filename)" />


 <xsl:variable name="href-path">
  <xsl:choose>
   <xsl:when test="contains(xlf:header/xmrk:nest/xmrk:outputURI,'..')">
<!--
    <xsl:value-of select="concat('translated/mv-',generate-id())" />
-->
    <xsl:value-of select="concat('translated--/',$filename)" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="concat('translated',xlf:header/xmrk:nest/xmrk:outputURI)" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <xsl:variable name="original" select="@original" />
 <xsl:if test="count(preceding-sibling::*[@original=$original])=0">
 <xsl:choose>
  <xsl:when test="$type='task'">
<b just-path="{$path-plus-file}" debug="y" target-lang="{$target-lang}"/>
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Task//EN" doctype-system="../dtd/task.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='concept'">
<b just-path="{$path-plus-file}" debug="y" target-lang="{$target-lang}"/>
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Concept//EN" doctype-system="../dtd/concept.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='reference'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Reference//EN" doctype-system="../dtd/reference.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='map'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Map//EN" doctype-system="../dtd/map.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='topicref'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Map//EN" doctype-system="../dtd/map.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='mapref'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Map//EN" doctype-system="../dtd/map.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='bookmap'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA BookMap//EN" doctype-system="../dtd/bookmap.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='ditabase'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA DitaBase//EN" doctype-system="../dtd/ditabase.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='glossentry'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Glossary Entry//EN" doctype-system="../dtd/glossentry.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='glossgroup'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Glossary Entry//EN" doctype-system="../dtd/glossgroup.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='learningAssessment'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Learning Assessment//EN" doctype-system="../dtd/learningAssessment.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='learningContent'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Learning Content//EN" doctype-system="../dtd/learningContent.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='learningOverview'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Learning Overview//EN" doctype-system="../dtd/learningOverview.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='learningPlan'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Learning Plan//EN" doctype-system="../dtd/learningPlan.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='learningSummary'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Learning Summary//EN" doctype-system="../dtd/learningSummary.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='subjectScheme'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Subject Scheme Map//EN" doctype-system="../dtd/subjectScheme.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:when test="$type='topic'">
   <xsl:result-document
    href="{concat('translated',$path-plus-file)}" doctype-public="-//OASIS//DTD DITA Topic//EN" doctype-system="../dtd/topic.dtd">
    <xsl:apply-templates>
     <xsl:with-param name="file_id">
      <xsl:value-of select="@build-num" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:result-document>
  </xsl:when>
  <xsl:otherwise>
   <xsl:text>punt</xsl:text>
  </xsl:otherwise>
 </xsl:choose>
 </xsl:if>
</xsl:template>

<xsl:template name="filename">
 <xsl:param name="path" />
  <xsl:choose>
   <xsl:when test="contains($path,'/')">
    <xsl:call-template name="filename">
     <xsl:with-param name="path">
      <xsl:value-of select="substring-after($path,'/')" />
     </xsl:with-param>
    </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$path" />
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="just-path">
 <xsl:param name="path" />
 <xsl:param name="cat-path" />
  <xsl:choose>
   <xsl:when test="contains($path,'/')">
    <xsl:call-template name="just-path">
     <xsl:with-param name="path">
      <xsl:value-of select="substring-after($path,'/')" />
     </xsl:with-param>
     <xsl:with-param name="cat-path">
      <xsl:value-of select="concat($cat-path,'/',substring-before($path,'/'))" />
     </xsl:with-param>
    </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$cat-path" />
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xlf:group">
 <xsl:param name="file_id" />
 <xsl:param name="target-lang" />
 <xsl:variable name="id" select="substring-after(@id,'xmark')" />
 <xsl:variable name="el_name" select="local-name(ancestor::xlf:file//xmrk:*[@xmarker_idref=$id])" />
 <xsl:element name="{local-name(ancestor::xlf:file//xmrk:*[@xmarker_idref=$id])}">
  <xsl:for-each select="ancestor::xlf:file//xmrk:*[@xmarker_idref=$id]/@*[local-name()!='xmarker_idref']">
   <xsl:copy />
  </xsl:for-each>
  <xsl:choose>
   <xsl:when test="$target-lang='not-set'">
    <!-- nothing for now -->
   </xsl:when>
   <xsl:otherwise>
    <xsl:if test="$el_name='concept' or
                  $el_name='reference' or
                  $el_name='map' or
                  $el_name='bookmap' or
                  $el_name='ditabase' or
                  $el_name='glossentry' or
                  $el_name='glossgroup' or
                  $el_name='learningAssessment' or
                  $el_name='learningContent' or
                  $el_name='learningOverview' or
                  $el_name='learningPlan' or
                  $el_name='learningSummary' or
                  $el_name='subjectScheme' or
                  $el_name='topic'">
     <xsl:attribute name="xml:lang">
      <xsl:value-of select="$target-lang" />
     </xsl:attribute>
    </xsl:if>
   </xsl:otherwise>
  </xsl:choose>
<!--
  <xsl:comment>
   <xsl:value-of select="$target-lang" />
   <xsl:value-of select="name(parent::*)" />
  </xsl:comment>
-->
  <xsl:apply-templates select="xlf:group|xlf:g|xlf:trans-unit">
   <xsl:with-param name="file_id">
    <xsl:value-of select="$file_id" />
   </xsl:with-param>
   <xsl:with-param name="target-lang">
    <xsl:value-of select="$target-lang" />
   </xsl:with-param>
  </xsl:apply-templates>
 </xsl:element>
</xsl:template>

<xsl:template match="xlf:g|xlf:x">
 <xsl:param name="file_id" />
 <xsl:param name="target-lang" />
 <xsl:variable name="id" select="@id" />
 <xsl:element name="{local-name(ancestor::xlf:file//xmrk:*[@xmarker_idref=$id])}">
  <xsl:for-each select="ancestor::xlf:file//xmrk:*[@xmarker_idref=$id]/@*[local-name()!='xmarker_idref']">
   <xsl:copy />
  </xsl:for-each>
  <xsl:apply-templates>
   <xsl:with-param name="file_id">
    <xsl:value-of select="$file_id" />
   </xsl:with-param>
   <xsl:with-param name="target-lang">
    <xsl:value-of select="$target-lang" />
   </xsl:with-param>
  </xsl:apply-templates>
 </xsl:element>
</xsl:template>

<xsl:template match="xlf:trans-unit">
 <xsl:param name="file_id" />
 <xsl:param name="target-lang" />
 <xsl:variable name="id" select="@id" />
 <xsl:variable name="parent-id">
  <xsl:for-each select="parent::*">
   <xsl:value-of select="substring-after(@id,'xmark')" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:choose>
  <xsl:when test="$id=$parent-id">
    <xsl:apply-templates select="xlf:target">
     <xsl:with-param name="file_id">
      <xsl:value-of select="$file_id" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
  </xsl:when>
  <xsl:otherwise>
   <xsl:element name="{local-name(ancestor::xlf:file//xmrk:*[@xmarker_idref=$id])}">
    <xsl:for-each select="ancestor::xlf:file//xmrk:*[@xmarker_idref=$id]/@*[local-name()!='xmarker_idref']">
     <xsl:copy />
    </xsl:for-each>
    <xsl:apply-templates select="xlf:target">
     <xsl:with-param name="file_id">
      <xsl:value-of select="$file_id" />
     </xsl:with-param>
     <xsl:with-param name="target-lang">
      <xsl:value-of select="$target-lang" />
     </xsl:with-param>
    </xsl:apply-templates>
   </xsl:element>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="xmrk:*">
<!--
 <xsl:variable name="idref" select="@xmarker_idref" />
 <xsl:variable name="tu_idref" select="count(//xlf:trans-unit[@id=$idref])" />
 <xsl:variable name="tg_idref" select="count(//xlf:target/xlf:g[@id=$idref])" />
 <xsl:variable name="gg_idref" select="count(//xlf:target//xlf:g/xlf:g[@id=$idref])" />-->
<!--
 <xsl:variable name="my_nest">
  <xsl:for-each select="//xlf:trans-unit[@id=$idref]/xlf:target">
    select="count(//xlf:target//xlf:g/xlf:g[@id=$idref])" />
  </xsl:for-each>
 </xsl:variable>
-->
<!--
 <xsl:element name="{local-name()}">
  <xsl:for-each select="@*[local-name()!='xmarker_idref']">
   <xsl:attribute name="{local-name()}">
    <xsl:value-of select="." />
   </xsl:attribute>
  </xsl:for-each>
  <xsl:if test="$tu_idref&gt;0">
   <xsl:attribute name="tu_idref">
    <xsl:value-of select="$tu_idref" />
   </xsl:attribute>
  </xsl:if>
  <xsl:if test="$tg_idref&gt;0">
   <xsl:attribute name="tg_idref">
    <xsl:value-of select="$tg_idref" />
   </xsl:attribute>
  </xsl:if>
  <xsl:if test="$gg_idref&gt;0">
   <xsl:attribute name="gg_idref">
    <xsl:value-of select="$gg_idref" />
   </xsl:attribute>
  </xsl:if>
  <xsl:apply-templates />
 </xsl:element>-->
</xsl:template>

</xsl:transform>
