/*
 * Copyright (c) 2010-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.net.URL;
import java.util.Map;
import java.util.IdentityHashMap;
import static javax.xml.XMLConstants.XML_NS_URI;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.util.StringUtil;
import com.xmlmind.util.StringList;
import com.xmlmind.util.XMLText;
import com.xmlmind.ditac.util.DITAUtil;

/*package*/ final class CopyMeta implements Constants {
    private CopyMeta() {}

    public static void processMap(Element map, LoadedDocuments loadedDocs) {
        String[] filterAttributes = DITAUtil.getFilterAttributes(map);
        String[] otherMetaAttributes = DITAUtil.getOtherMetaAttributes(map);

        String[] metaAttributes = 
            new String[filterAttributes.length + otherMetaAttributes.length];
        boolean[] metaAttributeIsSingle = new boolean[metaAttributes.length];
        
        int i = 0;
        for (int j = 0; j < filterAttributes.length; ++j) {
            String attrName  = filterAttributes[j];

            metaAttributes[i] = attrName;
            metaAttributeIsSingle[i] = DITAUtil.filterAttributeIsSingle(j);
            ++i;
        }
        for (int j = 0; j < otherMetaAttributes.length; ++j) {
            String attrName = otherMetaAttributes[j];

            metaAttributes[i] = attrName;
            metaAttributeIsSingle[i] = DITAUtil.otherMetaAttributeIsSingle(j);
            ++i;
        }

        IdentityHashMap<Element, Element> processed = 
            new IdentityHashMap<Element, Element>();

        processMap(map, metaAttributes, metaAttributeIsSingle, 
                   loadedDocs, processed);
    }

    public static void processMap(Element element,
                                  String[] metaAttributes,
                                  boolean[] metaAttributeIsSingle, 
                                  LoadedDocuments loadedDocs,
                                  Map<Element, Element> processed) {
        Node child = element.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                URL url;
                if (DITAUtil.hasClass(childElement, "map/topicref") &&
                    (url = DITAUtil.getLocalTopicURL(childElement)) != null) {
                    // LoadedDocuments.get() is sufficient in production.
                    // We use load() here just to be able to run the test
                    // drive below.
                    LoadedDocument loadedDoc = null;
                    try {
                        loadedDoc = loadedDocs.load(url);
                    } catch (Exception shouldNotHappen) {}

                    if (loadedDoc != null) {
                        LoadedTopic loadedTopic;

                        String topicId = DITAUtil.getTopicId(url);
                        if (topicId != null) {
                            loadedTopic = loadedDoc.findTopicById(topicId);
                        } else {
                            // SPECIFICITY: in this case <topicref
                            // href="foo.dita"/> the topicref metadata is
                            // copied only to the first topic found in
                            // foo.dita.  An alternative would be to copy
                            // metadata to all topics found in foo.dita.
                            loadedTopic = loadedDoc.getFirstTopic();
                        }

                        if (loadedTopic != null) {
                            Element topic = loadedTopic.element;
                            if (!processed.containsKey(topic)) {
                                // A topic is processed once, even if it
                                // is referenced in several topicrefs.
                                processed.put(topic, topic);

                                copyMeta(childElement, 
                                         metaAttributes, metaAttributeIsSingle, 
                                         topic);
                            }
                        }
                    }

                    processMap(childElement,
                               metaAttributes, metaAttributeIsSingle, 
                               loadedDocs, processed);
                }
            }

            child = child.getNextSibling();
        }
    }

    // -----------------------------------------------------------------------

    private static void copyMeta(Element topicref,
                                 String[] metaAttributes,
                                 boolean[] metaAttributeIsSingle,
                                 Element topic) {
        if ("no".equals(DITAUtil.getNonEmptyAttribute(topicref,
                                                      null, "search"))) {
            topic.setAttributeNS(DITAC_NS_URI, SEARCH_QNAME, "false");
        }

        // ---

        Element topicmeta = 
            DITAUtil.findChildByClass(topicref, "map/topicmeta");

        boolean lockmeta = true;
        if (topicmeta != null &&
            "no".equals(DITAUtil.getNonEmptyAttribute(topicmeta, 
                                                      null, "lockmeta"))) {
            lockmeta = false;
        }

        copyAttributes(topicref, metaAttributes, metaAttributeIsSingle,
                       lockmeta, topic);

        copySearchTitle(topicref, topicmeta, lockmeta, topic);

        if (topicmeta != null) {
            copyElements(topicmeta, lockmeta, topic);
        }
    }

    // ---------------------------------
    // copyAttributes
    // ---------------------------------

    private static void copyAttributes(Element topicref,
                                       String[] metaAttributes,
                                       boolean[] metaAttributeIsSingle,
                                       boolean lockmeta,
                                       Element topic) {
        for (int i = 0; i < metaAttributes.length; ++i) {
            String attrName = metaAttributes[i];

            String mapValue = getNonEmptyAttribute(topicref, attrName);
            if (mapValue != null) {
                String topicValue = getNonEmptyAttribute(topic, attrName);

                if (topicValue == null) {
                    setAttribute(topic, attrName, mapValue);
                } else {
                    if (metaAttributeIsSingle[i]) {
                        if (lockmeta) {
                            setAttribute(topic, attrName, mapValue);
                        }
                    } else {
                        setAttribute(topic, attrName, 
                                     mergeAttributeValues(topicValue,
                                                          mapValue));
                    }
                }
            }
        }
    }

    private static String getNonEmptyAttribute(Element element, String qName) {
        if (qName.startsWith("xml:")) {
            return DITAUtil.getNonEmptyAttribute(element, XML_NS_URI, 
                                                 qName.substring(4));
        } else {
            return DITAUtil.getNonEmptyAttribute(element, null, qName);
        }
    }

    private static void setAttribute(Element element, String qName, 
                                     String value) {
        if (qName.startsWith("xml:")) {
            element.setAttributeNS(XML_NS_URI, qName.substring(4), value);
        } else {
            element.setAttributeNS(null, qName, value);
        }
    }

    private static String mergeAttributeValues(String value1,
                                               String value2) {
        String[] values1 = XMLText.splitList(value1);
        String[] values2 = XMLText.splitList(value2);

        for (String item : values2) {
            if (!StringList.contains(values1, item)) {
                values1 = StringList.append(values1, item);
            }
        }

        return StringUtil.join(' ', values1);
    }

    // ---------------------------------
    // copySearchTitle
    // ---------------------------------

    private static final String[] TOPIC_ELEMENTS = {
        "topic/title",
        "topic/titlealts",
        "topic/shortdesc",
        "topic/abstract",
        "topic/prolog",
        "topic/body",
        "topic/related-links", 
        "topic/topic"
    };

    private static void copySearchTitle(Element topicref, 
                                        Element topicmeta, boolean lockmeta,
                                        Element topic) {
        Document doc = topic.getOwnerDocument();
        Element titlealts = null;

        Element mapSearchtitle = null;
        if (topicmeta != null) {
            // Inside a topicmeta, a searchtitle has a "- map/searchtitle "
            // class and not a "- topic/searchtitle " class.

            mapSearchtitle = DITAUtil.findChildByClass(topicmeta, 
                                                       "map/searchtitle");
        }

        if (mapSearchtitle != null) {
            // Replace class "map/searchtitle" by "topic/searchtitle".
            mapSearchtitle = (Element) mapSearchtitle.cloneNode(/*deep*/ true);
            mapSearchtitle.setAttributeNS(null, "class", 
                                          "- topic/searchtitle ");

            titlealts = ensureHasTitlealts(topic, titlealts, doc);

            Element topicSearchtitle = 
                DITAUtil.findChildByClass(titlealts, "topic/searchtitle");

            if (topicSearchtitle == null) {
                insertBefore(titlealts, mapSearchtitle, /*before*/ null, doc);
            } else {
                if (lockmeta) {
                    replaceChild(titlealts, mapSearchtitle, topicSearchtitle, 
                                 doc);
                }
            }
        }
    }

    private static Element ensureHasTitlealts(Element topic, Element titlealts, 
                                              Document doc) {
        if (titlealts == null) {
            titlealts = DITAUtil.findChildByClass(topic, "topic/titlealts");

            if (titlealts == null) {
                titlealts = doc.createElementNS(null, "titlealts");
                titlealts.setAttributeNS(null, "class", "- topic/titlealts ");

                Element before = DITAUtil.findChildByClass(
                    topic, 
                    StringList.indexOf(TOPIC_ELEMENTS, "topic/shortdesc"),
                    TOPIC_ELEMENTS);
                topic.insertBefore(titlealts, before);
            }
        }

        return titlealts;
    }

    private static void replaceChild(Element parent, Element newChild, 
                                     Element oldChild, Document doc) {
        Node copy = doc.importNode(newChild, /*deep*/ true);
        parent.replaceChild(copy, oldChild);
    }

    private static void insertBefore(Element parent, Element newChild, 
                                     Element before, Document doc) {
        Node copy = doc.importNode(newChild, /*deep*/ true);
        parent.insertBefore(copy, before);
    }

    // ---------------------------------
    // copyElements
    // ---------------------------------

    private static final String[] PROLOG_ELEMENTS = {
        "topic/author",
        "topic/source",
        "topic/publisher",
        "topic/copyright",
        "topic/critdates",
        "topic/permissions",
        "topic/metadata", 
        "topic/resourceid", 
        "topic/data", 
        "topic/data-about", 
        "topic/foreign", 
        "topic/unknown"
    };

    private static final boolean[] PROLOG_ELEMENT_SINGLE = {
        /*topic/author*/ false,
        /*topic/source*/ true,
        /*topic/publisher*/ true,
        /*topic/copyright*/ false,
        /*topic/critdates*/ true,
        /*topic/permissions*/ true,
        /*topic/metadata*/ false, 
        /*topic/resourceid*/ false, 
        /*topic/data*/ false, 
        /*topic/data-about*/ false, 
        /*topic/foreign*/ false, 
        /*topic/unknown*/ false,
    };

    // metadata child elements are all allowed in any number.
    private static final String[] METADATA_ELEMENTS = {
        "topic/audience",
        "topic/category",
        "topic/keywords",
        "topic/prodinfo",
        "topic/othermeta",
        "topic/data", 
        "topic/data-about", 
        "topic/foreign", 
        "topic/unknown"
    };

    // data, data-about, foreign, unknown found in topicmeta
    // will be added to the prolog and to to the prolog/metadata.
    private static final int METADATA_ELEMENT_COUNT = 
        METADATA_ELEMENTS.length - 4;

    private static void copyElements(Element topicmeta, boolean lockmeta,
                                     Element topic) {
        Document doc = topic.getOwnerDocument();

        // prolog ---

        Element prolog = null;

        for (int i = 0; i < PROLOG_ELEMENTS.length; ++i) {
            String c = PROLOG_ELEMENTS[i];
            boolean single = PROLOG_ELEMENT_SINGLE[i];

            if (single) {
                Element mapMeta = DITAUtil.findChildByClass(topicmeta, c);
                if (mapMeta != null) {
                    prolog = ensureHasProlog(topic, prolog, doc);

                    Element topicMeta = DITAUtil.findChildByClass(prolog, c);
                    if (topicMeta == null) {
                        Element before = DITAUtil.findChildByClass(
                            prolog,
                            StringList.indexOf(PROLOG_ELEMENTS, c), 
                            PROLOG_ELEMENTS);
                        insertBefore(prolog, mapMeta, before, doc);
                    } else {
                        if (lockmeta) {
                            replaceChild(prolog, mapMeta, topicMeta, doc);
                        }
                    }
                }
            } else {
                Element[] mapMeta = DITAUtil.findChildrenByClass(topicmeta, c);
                if (mapMeta.length > 0) {
                    prolog = ensureHasProlog(topic, prolog, doc);

                    Element before = DITAUtil.findChildByClass(
                        prolog,
                        StringList.indexOf(PROLOG_ELEMENTS, c), 
                        PROLOG_ELEMENTS);
                    insertBefore(prolog, mapMeta, before, doc);
                }
            }
        }

        // prolog/metadata ---
        // metadata child elements are all allowed in any number.

        Element[] prolog1 = new Element[] { prolog };
        Element metadata = null;

        for (int i = 0; i < METADATA_ELEMENT_COUNT; ++i) {
            String c = METADATA_ELEMENTS[i];

            Element[] mapMeta = DITAUtil.findChildrenByClass(topicmeta, c);
            if (mapMeta.length > 0) {
                metadata = ensureHasMetadata(topic, prolog1, metadata, doc);

                Element before = DITAUtil.findChildByClass(
                    metadata,
                    StringList.indexOf(METADATA_ELEMENTS, c), 
                    METADATA_ELEMENTS);
                insertBefore(metadata, mapMeta, before, doc);
            }
        }
    }

    private static Element ensureHasProlog(Element topic, Element prolog,
                                           Document doc) {
        if (prolog == null) {
            prolog = DITAUtil.findChildByClass(topic, "topic/prolog");

            if (prolog == null) {
                prolog = doc.createElementNS(null, "prolog");
                prolog.setAttributeNS(null, "class", "- topic/prolog ");

                Element before = DITAUtil.findChildByClass(
                    topic, 
                    StringList.indexOf(TOPIC_ELEMENTS, "topic/body"), 
                    TOPIC_ELEMENTS);
                topic.insertBefore(prolog, before);
            }
        }

        return prolog;
    }

    private static Element ensureHasMetadata(Element topic, 
                                             Element[] prolog1,
                                             Element metadata,
                                             Document doc) {
        if (metadata == null) {
            prolog1[0] = ensureHasProlog(topic, prolog1[0], doc);

            metadata = DITAUtil.findChildByClass(prolog1[0], "topic/metadata");

            if (metadata == null) {
                metadata = doc.createElementNS(null, "metadata");
                metadata.setAttributeNS(null, "class", "- topic/metadata ");

                Element before = DITAUtil.findChildByClass(
                    prolog1[0],
                    StringList.indexOf(PROLOG_ELEMENTS, "topic/resourceid"), 
                    PROLOG_ELEMENTS);
                prolog1[0].insertBefore(metadata, before);
            }
        }

        return metadata;
    }

    private static void insertBefore(Element parent, Element[] newChildren, 
                                     Element before, Document doc) {
        for (int i = 0; i < newChildren.length; ++i) {
            Node copy = doc.importNode(newChildren[i], /*deep*/ true);
            parent.insertBefore(copy, before);
        }
    }

    // -----------------------------------------------------------------------

    public static void main(String[] args) 
        throws Exception {
        java.io.File inFile = null;
        java.io.File outDir = null;
        if (args.length != 2 ||
            !(inFile = new java.io.File(args[0])).isFile() ||
            !(outDir = new java.io.File(args[1])).isDirectory()) {
            System.err.println(
                "usage: java com.xmlmind.ditac.preprocess.CopyMeta" +
                " in_map_file out_dir");
            System.exit(1);
        }

        LoadedDocuments loadedDocs = new LoadedDocuments();
        LoadedDocument loadedMap = loadedDocs.load(inFile);
        switch (loadedMap.type) {
        case BOOKMAP:
        case MAP:
            break;
        default:
            System.err.println("'" + inFile + "' does not contain a map");
            System.exit(1);
        }

        processMap(loadedMap.document.getDocumentElement(),
                   loadedDocs);

        java.util.Iterator<LoadedDocument> iter = loadedDocs.iterator();
        while (iter.hasNext()) {
            LoadedDocument loadedDoc = iter.next();
            if (loadedDoc != loadedMap) {
                java.io.File outFile = new java.io.File(
                    outDir, 
                    com.xmlmind.util.URLUtil.getBaseName(loadedDoc.url));

                com.xmlmind.ditac.util.SaveDocument.save(loadedDoc.document, 
                                                         outFile);
            }
        }
    }
}
