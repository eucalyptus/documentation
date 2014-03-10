<?xml version="1.0" encoding="utf-8"?><!-- Convert a DITA map to a Kindle data set. 

     The main style sheet, map2kindleImpl.xsl, includes separate modules that
     handle generating the content.opf file, the toc.ncx file, and all the
     HTML content files, each in distinct modes.
          
     Extensions to this transform can override or extend any of those modes.

Notes:

If map/topicmeta element has author, publisher, and copyright elements,
they will be added to the epub file as Dublin Core metadata.

--><xsl:stylesheet version="2.0" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:import href="map2kindleImpl.xsl"></xsl:import>

  

  
</xsl:stylesheet>