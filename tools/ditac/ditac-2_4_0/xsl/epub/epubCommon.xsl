<?xml version="1.0" encoding="UTF-8"?>
<!--
| Copyright (c) 2013 Pixware SARL. All rights reserved.
|
| Author: Hussein Shafie
|
| This file is part of the XMLmind DITA Converter project.
| For conditions of distribution and use, see the accompanying LEGAL.txt file.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:opf="http://www.idpf.org/2007/opf"
                xmlns:htm="http://www.w3.org/1999/xhtml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ditac="http://www.xmlmind.com/ditac/schema/ditac"
                xmlns:u="http://www.xmlmind.com/namespace/ditac"
                xmlns:URI="java:com.xmlmind.ditac.xslt.URI"
                exclude-result-prefixes="xs htm ditac u URI"
                version="2.0">

  <!-- Overrides ========================================================= -->

  <xsl:param name="external-resource-base" select="'#REMOVE'"/>

  <!-- ditac:toc suppressed. -->
  <xsl:template match="ditac:toc"/>

  <!-- Output formats ==================================================== -->

  <xsl:output name="outputFormatXHTML1_1"
              method="xhtml" encoding="UTF-8" indent="no"
              doctype-public="-//W3C//DTD XHTML 1.1//EN"
              doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>

  <!-- Note that doctype-public="" doctype-system="" will not generate
       the HTML5 DOCTYPE. -->
  <xsl:output name="outputFormatXHTML5"
              method="xhtml" encoding="UTF-8" indent="no"
              omit-xml-declaration="yes" include-content-type="no"/>

  <!-- epubIdentifier ==================================================== -->

  <xsl:variable name="epub-uuid" select="URI:uuidURI()"/>

  <xsl:template name="epubIdentifier">
    <xsl:choose>
      <xsl:when test="$epub-identifier ne ''">
        <xsl:value-of select="$epub-identifier"/>
      </xsl:when>

      <xsl:otherwise>
        <xsl:variable name="ISBN" 
          select="$ditacLists/ditac:titlePage//*[contains(@class,' bookmap/isbn ')]"/>
        <xsl:choose>
          <xsl:when test="exists($ISBN)">
            <xsl:variable name="ISBN2" 
                          select="normalize-space($ISBN[1])"/>
            <xsl:value-of select="if (starts-with($ISBN2, 'urn:')) 
                                  then $ISBN2
                                  else concat('urn:isbn:', $ISBN2)"/>
          </xsl:when>

          <xsl:otherwise>
            <xsl:value-of select="$epub-uuid"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- mediaTypeAttribute ================================================ -->

  <xsl:template name="mediaTypeAttribute">
    <xsl:param name="path" select="''"/>

    <xsl:attribute name="media-type" select="u:mediaType($path)"/>
  </xsl:template>

  <xsl:function name="u:mediaType">
    <xsl:param name="path"/>

    <xsl:variable name="path2" select="lower-case($path)"/>
    <xsl:sequence
      select="if (ends-with($path2, '.gif')) then 'image/gif'
              else if (ends-with($path2, '.jpg') or
                       ends-with($path2, '.jpeg')) then 'image/jpeg'
              else if (ends-with($path2, '.png')) then 'image/png'
              else if (ends-with($path2, '.svg') or 
                       ends-with($path2, '.svgz')) then 'image/svg+xml'

              else if (ends-with($path2, '.css')) then 'text/css'
              else if (ends-with($path2, '.js')) then 'text/javascript'

              else if (ends-with($path2, '.mp3')) then 'audio/mpeg'
              else if (ends-with($path2, '.m4a')) then 'audio/mp4'

              else if (ends-with($path2, '.oga')) then 'audio/ogg'
              else if (ends-with($path2, '.wav')) then 'audio/wav'

              else if (ends-with($path2, '.mp4')) then 'video/mp4'
              else if (ends-with($path2, '.ogg') or
                       ends-with($path2, '.ogv')) then 'video/ogg'
              else if (ends-with($path2, '.webm')) then 'video/webm'

              else if (ends-with($path2, '.swf')) then 'application/x-shockwave-flash'
              else 'application/octet-stream'"/>
  </xsl:function>

  <!-- generateResourceItems ============================================= -->

  <xsl:template name="generateResourceItems">
    <!-- Resource (e.g. images) files -->

    <xsl:variable name="resourceHrefs">
      <xsl:for-each select="$ditacLists/ditac:chunkList/ditac:chunk">
        <xsl:variable name="file" select="string(@file)"/>
        <xsl:variable name="chunkPath" 
          select="concat(substring-before($file, u:suffix($file)), '.ditac')"/>

        <xsl:variable name="chunk"
                      select="doc(resolve-uri($chunkPath, $ditacListsURI))"/>

        <xsl:for-each select="$chunk//*[contains(@class,' topic/image ')]">
          <xsl:call-template name="appendImage"/>
        </xsl:for-each>

        <xsl:for-each select="$chunk//*[contains(@class,' topic/object ')]">
          <xsl:call-template name="appendObject"/>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="resourceHrefs2" 
                  select="distinct-values(tokenize($resourceHrefs, '\n'))"/>

    <xsl:for-each select="$resourceHrefs2">
      <xsl:variable name="index" select="index-of($resourceHrefs2, .)"/>
      <xsl:variable name="path" select="substring-before(., '&#xE000;')"/>
      <xsl:variable name="mediaType" select="substring-after(., '&#xE000;')"/>

      <xsl:if test="$path ne '' and $mediaType ne ''">
        <opf:item id="{concat('__IMG', $index)}" 
                  href="{$path}" media-type="{$mediaType}"/>
      </xsl:if>
    </xsl:for-each>

    <!-- XSL resource files. -->
    <!-- (Custom XSL resources, custom CSS file not supported.) -->

    <xsl:variable name="resourceList"
      select="tokenize(unparsed-text(resolve-uri('resources.list', 
                                                 document-uri(doc('')))), 
                       '\n')"/>

    <xsl:for-each select="$resourceList">
      <xsl:variable name="index" select="index-of($resourceList, .)"/>
      <xsl:variable name="path" select="normalize-space(.)"/>

      <xsl:if test="$path ne '' and not(starts-with($path, '#'))">
        <xsl:variable name="baseName" 
                      select="substring-after($path, 'resources/')"/>

        <opf:item id="{concat('__RES', $index)}" 
                  href="{concat($xslResourcesDir, $baseName)}">
          <xsl:call-template name="mediaTypeAttribute">
            <xsl:with-param name="path" select="$baseName"/>
          </xsl:call-template>
        </opf:item>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="appendImage">
    <xsl:call-template name="appendResource">
      <xsl:with-param name="href" select="string(@href)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="appendResource">
    <xsl:param name="href" select="''"/>
    <xsl:param name="mediaType" select="''"/>

    <xsl:variable name="href2" select="normalize-space($href)"/>
    <xsl:variable name="mediaType2" select="normalize-space($mediaType)"/>

    <xsl:if test="$href2 ne '' and 
                  $href2 ne '???' and
                  not(matches($href2, '^[a-zA-Z][a-zA-Z0-9.+-]*:/'))">
      <xsl:variable name="type" 
                    select="if ($mediaType2 ne '') 
                            then $mediaType2
                            else u:mediaType($href2)"/>

      <xsl:value-of select="concat($href2, '&#xE000;', $type)"/>
      <xsl:text>&#xA;</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- Keep epubcheck quiet. -->
  <xsl:param name="downloadObjectAsFallback" select="false()"/>

  <xsl:template name="appendObject">
    <xsl:if test="exists(@classid)">
      <xsl:call-template name="appendResource">
        <xsl:with-param name="href" select="string(@classid)"/>
        <xsl:with-param name="mediaType" select="string(@codetype)"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:if test="exists(@data)">
      <xsl:call-template name="appendResource">
        <xsl:with-param name="href" select="string(@data)"/>
        <xsl:with-param name="mediaType" select="string(@type)"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:if test="exists(@archive)">
      <xsl:for-each select="tokenize(@archive, '\s+')">
        <xsl:call-template name="appendResource">
          <xsl:with-param name="href" select="."/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>

    <!-- param poster -->

    <xsl:variable name="posterParam" 
                  select="./*[contains(@class,' topic/param ') and
                              @name eq 'poster' and
                              string-length(@value) gt 0]"/>
    <xsl:if test="exists($posterParam)">
      <xsl:variable name="posterPath" 
                    select="normalize-space($posterParam[1]/@value)"/>

      <xsl:call-template name="appendResource">
        <xsl:with-param name="href" select="$posterPath"/>
      </xsl:call-template>
    </xsl:if>

    <!-- source.src/source.type params -->

    <xsl:for-each-group select="./*[contains(@class,' topic/param ')]" 
                        group-starting-with="*[@name eq 'source.src']">
      <xsl:variable name="typeParam" 
                    select="current-group()[@name eq 'source.type']"/>
      <xsl:if test="exists($typeParam)">
        <xsl:variable name="src" select="string(current-group()[1]/@value)"/>
        <xsl:variable name="type" select="string($typeParam[1]/@value)"/>

        <xsl:if test="string-length($src) gt 0 and string-length($type) gt 0">
          <xsl:call-template name="appendResource">
            <xsl:with-param name="href" select="$src"/>
            <xsl:with-param name="mediaType" select="$type"/>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
    </xsl:for-each-group>

    <!-- param movie -->

    <xsl:variable name="movieParam" 
                  select="./*[contains(@class,' topic/param ') and
                              @name eq 'movie' and
                              string-length(@value) gt 0]"/>
    <xsl:if test="exists($movieParam)">
      <xsl:variable name="moviePath" 
                    select="normalize-space($movieParam[1]/@value)"/>

      <xsl:if test="$moviePath ne '' and
                    (ends-with(lower-case($moviePath), '.swf') or
                     lower-case(normalize-space(@type)) eq 
                         'application/x-shockwave-flash')">
        <xsl:call-template name="appendResource">
          <xsl:with-param name="href" select="$moviePath"/>
          <xsl:with-param name="mediaType" 
                          select="'application/x-shockwave-flash'"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>