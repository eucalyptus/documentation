/*
 * Copyright (c) 2010-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.util.Iterator;
import java.util.List;
import java.util.ArrayList;
import java.util.Stack;
import static javax.xml.XMLConstants.XML_NS_URI;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.util.ArrayUtil;
import com.xmlmind.util.StringList;
import com.xmlmind.util.StringUtil;
import com.xmlmind.util.XMLText;
import com.xmlmind.util.KeyValuePair;
import com.xmlmind.util.LinearHashtable;
import com.xmlmind.ditac.util.DOMUtil;
import com.xmlmind.ditac.util.DITAUtil;

/*package*/ final class CascadeMeta {
    private CascadeMeta() {}

    public static void processTopic(Element topic) {
        Element relatedLinks = DITAUtil.findChildByClass(topic,
                                                        "topic/related-links");
        if (relatedLinks != null) {
            processRelatedLinks(relatedLinks);
        }
    }
    
    private static void processRelatedLinks(Element relatedLinks) {
        Stack<LinearHashtable<String, Object>> stack =
            new Stack<LinearHashtable<String, Object>>();

        LinearHashtable<String, Object> push = 
            new LinearHashtable<String, Object>(23);

        String[] attrNames = {
            "type", "role", "otherrole", "format", "scope",
            "rev"
        };

        for (String attrName : attrNames) {
            String localValue = getAttribute(relatedLinks, attrName);

            if (localValue == null || 
                (localValue = localValue.trim()).length() == 0) {
                localValue = "";
            }
            push.put(attrName, localValue);
        }

        String[] attrNames2 = DITAUtil.getFilterAttributes(relatedLinks);

        for (String attrName : attrNames2) {
            if ("rev".equals(attrName)) {
                // All select-atts except @rev are additive.
                continue;
            }

            String localValue = getAttribute(relatedLinks, attrName);

            String[] pushedValue;
            if (localValue == null || 
                (localValue = localValue.trim()).length() == 0) {
                pushedValue = StringUtil.EMPTY_LIST;
            } else {
                pushedValue = XMLText.splitList(localValue);
            }

            push.put(attrName, pushedValue);
        }

        checkOtherrole(relatedLinks, push);

        stack.push(push);

        Node child = relatedLinks.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                boolean isLink = DITAUtil.hasClass(childElement, "topic/link");
                processRelatedLinks(childElement, isLink, stack);
            }

            child = child.getNextSibling();
        }

        stack.pop();
    }

    private static String getAttribute(Element element, String qName) {
        if (qName.startsWith("xml:")) {
            return element.getAttributeNS(XML_NS_URI, qName.substring(4));
        } else {
            return element.getAttributeNS(null, qName);
        }
    }

    private static void removeAttribute(Element element, String qName) {
        if (qName.startsWith("xml:")) {
            element.removeAttributeNS(XML_NS_URI, qName.substring(4));
        } else {
            element.removeAttributeNS(null, qName);
        }
    }

    private static void setAttribute(Element element, String qName, 
                                     String value) {
        if (qName.startsWith("xml:")) {
            element.setAttributeNS(XML_NS_URI, qName, value);
        } else {
            element.setAttributeNS(null, qName, value);
        }
    }

    private static void checkOtherrole(Element element,
                                       LinearHashtable<String, Object> push) {
        String otherrole = getAttribute(element, "otherrole");
        if (otherrole != null && otherrole.length() == 0) {
            otherrole = null;
        }

        if (otherrole != null &&
            !"other".equals(getAttribute(element, "role"))) {
            if (push != null) {
                push.put("otherrole", "");
            }

            removeAttribute(element, "otherrole");
        }
    }

    private static
    void processRelatedLinks(Element element, boolean isLink,
                             Stack<LinearHashtable<String, Object>> stack) {
        LinearHashtable<String, Object> push = null;
        if (!isLink) {
            push = new LinearHashtable<String, Object>(23);
        }

        cascadeAttributes(stack.peek(), element, /*updateElement*/ true, push);

        checkOtherrole(element, push);

        if (!isLink) {
            stack.push(push);

            Node child = element.getFirstChild();
            while (child != null) {
                if (child.getNodeType() == Node.ELEMENT_NODE) {
                    Element childElement = (Element) child;

                    isLink = DITAUtil.hasClass(childElement, "topic/link");
                    if (isLink ||
                        DITAUtil.hasClass(childElement,
                                          "topic/linklist", "topic/linkpool")) {
                        processRelatedLinks(childElement, isLink, stack);
                    }
                    // SPECIFICITY: elements such as title, desc or linkinfo
                    // are considered as being integral part of their
                    // link/linklist parent. They cannot be filtered out or
                    // flagged independently of their link/linklist parent.
                }

                child = child.getNextSibling();
            }

            stack.pop();
        }
    }

    private static void cascadeAttributes(LinearHashtable<String,Object> top,
                                         Element element,
                                         boolean updateElement,
                                         LinearHashtable<String,Object> push) {
        Iterator<KeyValuePair<String, Object>> iter = top.entries();
        while (iter.hasNext()) {
            KeyValuePair<String, Object> e = iter.next();

            String attrName = e.key;
            Object cascadedValue = e.value;

            String localValue = getAttribute(element, attrName);

            Object newCascadedValue;
            if (localValue == null || 
                (localValue = localValue.trim()).length() == 0) {
                newCascadedValue = cascadedValue;
            } else {
                if (cascadedValue instanceof String) {
                    // Not additive.
                    newCascadedValue = localValue;
                } else {
                    // Additive.
                    newCascadedValue = 
                        addAttributeValues((String[]) cascadedValue,
                                           localValue);
                }
            }

            if (push != null) {
                push.put(attrName, newCascadedValue);
            }

            String newLocalValue;
            if (newCascadedValue instanceof String) {
                newLocalValue = (String) newCascadedValue;
            } else {
                newLocalValue =
                    StringUtil.join(' ', (String[]) newCascadedValue);
            }
            if (newLocalValue.length() > 0) {
                if (updateElement) {
                    setAttribute(element, attrName, newLocalValue);
                }
            }
        }
    }

    private static String[] addAttributeValues(String[] attrValue,
                                               String added) {
        String[] items = XMLText.splitList(added);

        for (int i = 0; i < items.length; ++i) {
            String item = items[i];

            if (attrValue == null) {
                attrValue = new String[] { item };
            } else {
                if (!StringList.contains(attrValue, item)) {
                    attrValue = StringList.append(attrValue, item);
                }
            }
        }

        return attrValue;
    }

    // -----------------------------------------------------------------------

    // "xnal-d/authorinformation" is a "topic/author"
    // "delay-d/exportanchors" is a "topic/keywords".

    public static final String[] TOPICMETA_ELEMENTS = {
        "topic/navtitle",
        "map/linktext",
        "map/searchtitle",
        "map/shortdesc",
        "topic/author",
        "topic/source",
        "topic/publisher",
        "topic/copyright",
        "topic/critdates",
        "topic/permissions",
        "topic/metadata",
        "topic/audience",
        "topic/category",
        "topic/keywords", 
        "topic/prodinfo",
        "topic/othermeta",
        "topic/resourceid",
        "topic/data",
        "topic/data-about",
        "topic/foreign",
        "topic/unknown"
    };

    public static final String[] CASCADED_ELEMENTS = {
        "topic/audience", // Any number.
        "topic/author", // Any number.
        "topic/category", // Any number.
        "topic/copyright", // Any number.
        "topic/critdates", // At most one.
        "topic/metadata", // Any number.
        "topic/permissions", // At most one.
        "topic/prodinfo", // Any number.
        "topic/publisher" // At most one.
    };

    public static final boolean[] CASCADED_ELEMENT_SINGLE = {
        /*topic/audience*/ false,
        /*topic/author*/ false,
        /*topic/category*/ false,
        /*topic/copyright*/ false,
        /*topic/critdates*/ true,
        /*topic/metadata*/ false,
        /*topic/permissions*/ true,
        /*topic/prodinfo*/ false,
        /*topic/publisher*/ true
    };

    public static void processMap(Element map) {
        Stack<LinearHashtable<String, Object>> stack =
            new Stack<LinearHashtable<String, Object>>();

        ArrayList<LinearHashtable<String, Object>> colspecs = new 
            ArrayList<LinearHashtable<String, Object>>();

        // Cascaded attributes ---

        LinearHashtable<String, Object> push1 = 
            new LinearHashtable<String, Object>(37);

        String[] attrNames = {
            "linking", "toc", "print", "search",
            "format", "scope", "type",
            "xml:lang", "translate", "dir",
            "processing-role",
            "rev"
        };

        for (String attrName : attrNames) {
            String localValue = getAttribute(map, attrName);

            if (localValue == null || 
                (localValue = localValue.trim()).length() == 0) {
                localValue = "";
            }
            push1.put(attrName, localValue);
        }

        String[] attrNames2 = DITAUtil.getFilterAttributes(map);

        for (String attrName : attrNames2) {
            if ("rev".equals(attrName)) {
                // All select-atts except @rev are additive.
                continue;
            }

            String localValue = getAttribute(map, attrName);

            String[] pushedValue;
            if (localValue == null || 
                (localValue = localValue.trim()).length() == 0) {
                pushedValue = StringUtil.EMPTY_LIST;
            } else {
                pushedValue = XMLText.splitList(localValue);
            }

            push1.put(attrName, pushedValue);
        }

        // Cascaded elements ---

        LinearHashtable<String, Object> push2 = 
            new LinearHashtable<String, Object>(23);

        Element mapMeta = DITAUtil.findChildByClass(map, "map/topicmeta");

        for (int k = 0; k < CASCADED_ELEMENTS.length; ++k) {
            String c = CASCADED_ELEMENTS[k];
            boolean single = CASCADED_ELEMENT_SINGLE[k];
            
            Element[] meta = findChildrenByClass(mapMeta, c);
            if (meta.length == 0) {
                if (single) {
                    push2.put(c, Boolean.FALSE);
                } else {
                    push2.put(c, DOMUtil.NO_ELEMENTS);
                }
            } else {
                if (single) {
                    push2.put(c, meta[0]);
                } else {
                    addElements(push2, c, meta);
                }
            }
        }

        Document doc = map.getOwnerDocument();

        stack.push(push1);
        stack.push(push2);

        Node child = map.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                boolean hasMeta = 
                    DITAUtil.hasClass(childElement, "map/topicref", 
                                      "map/reltable", "map/relcolspec");
                if (hasMeta ||
                    DITAUtil.hasClass(childElement, "map/relheader", 
                                      "map/relrow", "map/relcell")) {
                    processMap(childElement, hasMeta, colspecs, stack, doc);
                }
            }

            child = child.getNextSibling();
        }

        stack.pop();
        stack.pop();
    }

    private static Element findChildByClass(Element element, String cls) {
        if (element == null) {
            return null;
        } else {
            return DITAUtil.findChildByClass(element, cls);
        }
    }

    private static Element[] findChildrenByClass(Element element, String cls) {
        if (element == null) {
            return DOMUtil.NO_ELEMENTS;
        } else {
            return DITAUtil.findChildrenByClass(element, cls);
        }
    }

    private static void addElements(LinearHashtable<String, Object> push,
                                    String cls, Element[] elements) {
        Element[] list = (Element[]) push.get(cls);
        if (list == null) {
            push.put(cls, elements);
        } else {
            push.put(cls, ArrayUtil.insert(list, list.length, elements));
        }
    }

    private static 
    void processMap(Element element, boolean hasMeta,
                    List<LinearHashtable<String, Object>> colspecs,
                    Stack<LinearHashtable<String, Object>> stack,
                    Document doc) {
        int stackSize = stack.size();
        LinearHashtable<String, Object> top1 = stack.get(stackSize-2);
        LinearHashtable<String, Object> top2 = stack.get(stackSize-1);

        // Cascade attributes ---

        LinearHashtable<String, Object> push1 = 
            new LinearHashtable<String, Object>(37);

        cascadeAttributes(top1, element, /*updateElement*/ true, push1);

        // Cascade elements ---

        LinearHashtable<String, Object> push2 = 
            new LinearHashtable<String, Object>(23);

        cascadeElements(top2, element, hasMeta, push2, doc);

        stack.push(push1);
        stack.push(push2);

        if (DITAUtil.hasClass(element, "map/relcolspec")) {
            colspecs.add(push1);
            colspecs.add(push2);
        }

        Node child = element.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                hasMeta = DITAUtil.hasClass(childElement, "map/topicref", 
                                            "map/relcolspec", "map/reltable");
                boolean isRow = DITAUtil.hasClass(childElement, "map/relrow");
                if (hasMeta || isRow ||
                    DITAUtil.hasClass(childElement, "map/relcell", 
                                      "map/relheader")) {
                    if (isRow && colspecs.size() > 0) {
                        processRelrow(childElement, colspecs, stack, doc);
                    } else {
                        processMap(childElement, hasMeta, colspecs, stack, doc);
                    }
                }
            }

            child = child.getNextSibling();
        }

        stack.pop();
        stack.pop();
    }

    private static void cascadeElements(LinearHashtable<String,Object> top,
                                        Element element, boolean hasMeta,
                                        LinearHashtable<String,Object> push,
                                        Document doc) {
        Element meta = null;
        if (hasMeta) {
            meta = findChildByClass(element, "map/topicmeta");
        }

        Iterator<KeyValuePair<String, Object>> iter = top.entries();
        while (iter.hasNext()) {
            KeyValuePair<String, Object> e = iter.next();

            String cls = e.key;
            Object cascaded = e.value;

            Object newCascaded;
            if (cascaded instanceof Element[]) {
                // Additive.
                Element[] cascadedValues = (Element[]) cascaded;
                int cascadedValueCount = cascadedValues.length;

                Element[] localValues = findChildrenByClass(meta, cls);

                if (localValues.length > 0) {
                    newCascaded = ArrayUtil.insert(cascadedValues, 
                                                   cascadedValueCount,
                                                   localValues);
                } else {
                    newCascaded = cascaded;
                }

                if (hasMeta && cascadedValueCount > 0) {
                    meta = ensureHasMeta(element, meta, doc);

                    Element before = DITAUtil.findChildByClass(
                        meta,
                        StringList.indexOf(TOPICMETA_ELEMENTS, cls), 
                        TOPICMETA_ELEMENTS);
                    insertBefore(meta, cascadedValues, before, doc);
                }
            } else {
                // Not additive.
                Element cascadedValue = 
                    (cascaded instanceof Element)? (Element) cascaded : null;

                Element localValue = findChildByClass(meta, cls);

                if (localValue != null) {
                    newCascaded = localValue;
                } else {
                    newCascaded = cascaded;

                    if (hasMeta && cascadedValue != null) {
                        meta = ensureHasMeta(element, meta, doc);

                        Element before = DITAUtil.findChildByClass(
                            meta,
                            StringList.indexOf(TOPICMETA_ELEMENTS, cls), 
                            TOPICMETA_ELEMENTS);
                        insertBefore(meta, cascadedValue, before, doc);
                    }
                }
            }

            push.put(cls, newCascaded);
        }
    }
    
    private static Element ensureHasMeta(Element element, Element meta,
                                         Document doc) {
        if (meta == null) {
            meta = doc.createElementNS(null, "topicmeta");
            meta.setAttributeNS(null, "class", "- map/topicmeta ");

            // Insert it after the title (first) child element, if any.
            Node before = DOMUtil.getFirstChildElement(element);
            if (before != null && 
                DITAUtil.hasClass((Element) before, "topic/title")) {
                before = before.getNextSibling();
            }

            element.insertBefore(meta, before);
        }

        return meta;
    }

    private static void insertBefore(Element parent, Element newChild, 
                                     Element before, Document doc) {
        Node copy = doc.importNode(newChild, /*deep*/ true);
        parent.insertBefore(copy, before);
    }

    private static void insertBefore(Element parent, Element[] newChildren, 
                                     Element before, Document doc) {
        for (int i = 0; i < newChildren.length; ++i) {
            Node copy = doc.importNode(newChildren[i], /*deep*/ true);
            parent.insertBefore(copy, before);
        }
    }

    private static 
    void processRelrow(Element element,
                       List<LinearHashtable<String, Object>> colspecs,
                       Stack<LinearHashtable<String, Object>> stack,
                       Document doc) {
        int stackSize = stack.size();
        LinearHashtable<String, Object> top1 = stack.get(stackSize-2);
        LinearHashtable<String, Object> top2 = stack.get(stackSize-1);

        // Cascade attributes ---

        LinearHashtable<String, Object> push1 = 
            new LinearHashtable<String, Object>(37);

        cascadeAttributes(top1, element, /*updateElement*/ true, push1);

        // Cascade elements ---

        LinearHashtable<String, Object> push2 = 
            new LinearHashtable<String, Object>(23);

        cascadeElements(top2, element, /*hasMeta*/ false, push2, doc);

        stack.push(push1);
        stack.push(push2);

        int column = 0;

        Node child = element.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, "map/relcell")) {
                    LinearHashtable<String, Object> topA = null;
                    LinearHashtable<String, Object> topB = null;
                    if (2*column+1 < colspecs.size()) {
                        topA = colspecs.get(2*column);
                        topB = colspecs.get(2*column+1);
                    }

                    if (topA != null) {
                        LinearHashtable<String, Object> pushA = 
                            new LinearHashtable<String, Object>(37);

                        cascadeAttributes(topA, element, /*update*/ false, 
                                          pushA);

                        LinearHashtable<String, Object> pushB = 
                            new LinearHashtable<String, Object>(23);

                        cascadeElements(topB, element, /*hasMeta*/ false, 
                                        pushB, doc);

                        stack.push(pushA);
                        stack.push(pushB);
                    }

                    processMap(childElement, /*hasMeta*/ false, 
                               colspecs, stack, doc);

                    if (topA != null) {
                        stack.pop();
                        stack.pop();
                    }

                    ++column;
                }
            }

            child = child.getNextSibling();
        }

        stack.pop();
        stack.pop();
    }

    // -----------------------------------------------------------------------

    /**
     * Invoked by a MaprefIncluder to in order to cascade metadata 
     * from a mapref to the included map or map branch.
     * <p>The specified mapref has not yet been detached from the document 
     * being processed by the includer.
     * <p>The specified range of replacement nodes have not yet been attached 
     * to the document being processed by the includer. These nodes may be
     * topicrefs or reltables.
     * <p>The map document processed by the MaprefIncluder is assumed 
     * to have been processed itself using CascadeMeta.processMap 
     * prior to the MaprefIncluder transclusion step.
     */
    public static void processMapref(Element mapref, Node[] nodeRange) {
        Stack<LinearHashtable<String, Object>> stack =
            new Stack<LinearHashtable<String, Object>>();

        ArrayList<LinearHashtable<String, Object>> colspecs = new 
            ArrayList<LinearHashtable<String, Object>>();

        // Cascaded attributes ---

        LinearHashtable<String, Object> push1 = 
            new LinearHashtable<String, Object>(37);

        // Do *not* cascade from map to map:
        // "format", "scope",
        // "xml:lang", "translate", "dir".

        String[] attrNames = {
            "linking", "toc", "print", "search",
            "type",
            "processing-role",
            "rev"
        };

        for (String attrName : attrNames) {
            String localValue = getAttribute(mapref, attrName);

            if (localValue == null || 
                (localValue = localValue.trim()).length() == 0) {
                localValue = "";
            }
            push1.put(attrName, localValue);
        }

        String[] attrNames2 = DITAUtil.getFilterAttributes(mapref);

        for (String attrName : attrNames2) {
            if ("rev".equals(attrName)) {
                // All select-atts except @rev are additive.
                continue;
            }

            String localValue = getAttribute(mapref, attrName);

            String[] pushedValue;
            if (localValue == null || 
                (localValue = localValue.trim()).length() == 0) {
                pushedValue = StringUtil.EMPTY_LIST;
            } else {
                pushedValue = XMLText.splitList(localValue);
            }

            push1.put(attrName, pushedValue);
        }

        // Cascaded elements ---

        LinearHashtable<String, Object> push2 = 
            new LinearHashtable<String, Object>(23);

        Element maprefMeta = 
            DITAUtil.findChildByClass(mapref, "map/topicmeta");

        for (int k = 0; k < CASCADED_ELEMENTS.length; ++k) {
            String c = CASCADED_ELEMENTS[k];
            boolean single = CASCADED_ELEMENT_SINGLE[k];
            
            Element[] meta = findChildrenByClass(maprefMeta, c);
            if (meta.length == 0) {
                if (single) {
                    push2.put(c, Boolean.FALSE);
                } else {
                    push2.put(c, DOMUtil.NO_ELEMENTS);
                }
            } else {
                if (single) {
                    push2.put(c, meta[0]);
                } else {
                    addElements(push2, c, meta);
                }
            }
        }

        Document doc = mapref.getOwnerDocument();

        stack.push(push1);
        stack.push(push2);

        for (Node node : nodeRange) {
            if (node.getNodeType() == Node.ELEMENT_NODE) {
                Element element = (Element) node;

                boolean hasMeta = 
                    DITAUtil.hasClass(element, "map/topicref", 
                                      "map/reltable", "map/relcolspec");
                if (hasMeta ||
                    DITAUtil.hasClass(element, "map/relheader", 
                                      "map/relrow", "map/relcell")) {
                    processMap(element, hasMeta, colspecs, stack, doc);
                }
            }
        }

        stack.pop();
        stack.pop();
    }

    // -----------------------------------------------------------------------

    public static void main(String[] args) 
        throws java.io.IOException {
        if (args.length != 2) {
            System.err.println(
                "usage: java com.xmlmind.ditac.preprocess.CascadeMeta" +
                " in_map_or_topic_file out_file");
            System.exit(1);
        }
        java.io.File inFile = new java.io.File(args[0]);
        java.io.File outFile = new java.io.File(args[1]);

        org.w3c.dom.Document doc = 
            com.xmlmind.ditac.util.LoadDocument.load(inFile);

        Element root = doc.getDocumentElement();
        if (DITAUtil.hasClass(root, "map/map")) {
            CascadeMeta.processMap(root);
        } else if (DITAUtil.hasClass(root, "topic/topic")) {
            CascadeMeta.processTopic(root);
        } else {
            System.err.println("'" + inFile + "', not a DITA map or topic");
            System.exit(1);
        }

        com.xmlmind.ditac.util.SaveDocument.save(doc, outFile);
    }
}
