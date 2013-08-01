<!ENTITY % tag "tag" >

<!ELEMENT tag (#PCDATA)*>

<!ATTLIST tag %univ-atts;                                  
              outputclass CDATA #IMPLIED>

<!ATTLIST tag %global-atts;
              class CDATA "+ topic/keyword tech-d/tag ">

<!ATTLIST tag %univ-atts;                                  
              kind (attribute|attvalue|element|emptytag|endtag|
                    genentity|localname|namespace|numcharref|
                    paramentity|pi|prefix|comment|starttag) #REQUIRED>

