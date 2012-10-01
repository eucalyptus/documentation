/*
 * Copyright (c) 2010-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.io.IOException;
import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import org.w3c.dom.Node;
import org.w3c.dom.Attr;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.util.ThrowableUtil;
import com.xmlmind.util.StringList;
import com.xmlmind.util.StringUtil;
import com.xmlmind.util.URIComponent;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.FileUtil;
import com.xmlmind.util.XMLText;
import com.xmlmind.util.Console;
import com.xmlmind.ditac.util.SimpleConsole;
import com.xmlmind.ditac.util.ConsoleHelper;
import com.xmlmind.ditac.util.DITAUtil;

/*package*/ final class KeysLoader implements Constants {
    private ConsoleHelper console;    
    private URL mapURL;
    private Document mapDoc;
    private Filter filter;

    private static final int LAST_PASS = 9;

    // -----------------------------------------------------------------------

    public KeysLoader() {
        this(null);
    }

    public KeysLoader(Console console) {
        setConsole(console);
    }

    public void setConsole(Console c) {
        if (c == null) {
            c = new SimpleConsole();
        }
        this.console = ((c instanceof ConsoleHelper)? 
                        (ConsoleHelper) c : new ConsoleHelper(c));
    }

    public ConsoleHelper getConsole() {
        return console;
    }

    public boolean loadMap(File file) 
        throws IOException {
        return loadMap(FileUtil.fileToURL(file));
    }

    public boolean loadMap(URL url) 
        throws IOException {
        LoadedDocuments loadedDocs = 
            new LoadedDocuments(/*keys*/ null, console);

        LoadedDocument loadedDoc;
        try {
            // May throw an IOException.
            loadedDoc = loadedDocs.load(url, /*process*/ true);
        } catch (IllegalArgumentException e) {
            throw new IOException(e.getMessage());
        }

        switch (loadedDoc.type) {
        case BOOKMAP:
        case MAP:
            break;
        default:
            throw new IOException(Msg.msg("notAMap", URLUtil.toLabel(url)));
        }

        mapURL = url;
        mapDoc = loadedDoc.document;

        return (new MapSimplifier(/*keys*/ null, console)).simplify(mapDoc, 
                                                                    mapURL);
    }

    public URL getMapURL() {
        return mapURL;
    }

    public void setFilter(Filter filter) {
        this.filter = filter;
    }

    public Filter getFilter() {
        return filter;
    }

    public Keys createKeys() {
        return createKeys(null);
    }

    public Keys createKeys(LoadedDocuments loadedTopics) {
        if (mapDoc == null) {
            throw new IllegalStateException("no map");
        }

        Element map = mapDoc.getDocumentElement();
        if (filter != null) {
            map = (Element) map.cloneNode(/*deep*/ true);
            filter.filterMap(map);
        }

        if (loadedTopics == null) {
            loadedTopics = new LoadedDocuments(/*keys*/ null, console);
        }
        Keys keys = new Keys();

        // Add key entries ---

        int[] keyrefCount = new int[1];
        int prevKeyrefCount = -1;
        long now = System.currentTimeMillis();
        int iteration = 0;

        for (int pass = 0; pass <= LAST_PASS; ++pass) {
            console.debug(Msg.msg("iteration", iteration++));

            keyrefCount[0] = 0;
            if (!collectKeys(map, loadedTopics, keys, keyrefCount, 
                             (pass == LAST_PASS))) {
                return null;
            }

            if (keyrefCount[0] == 0) {
                // Done.
                break;
            }

            if (keyrefCount[0] == prevKeyrefCount) {
                // No change. Next pass will be the last one.
                pass = LAST_PASS-1;
            }
            prevKeyrefCount = keyrefCount[0];
        }

        console.debug(Msg.msg("keysCollected", 
                              iteration, System.currentTimeMillis()-now));

        //System.out.println(keys);
        return keys;
    }

    private boolean collectKeys(Element tree, LoadedDocuments loadedTopics, 
                                Keys keys, int[] keyrefCount, 
                                boolean lastPass) {
        Node child = tree.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                String keyList;
                if (DITAUtil.hasClass(childElement, "map/topicref") &&
                    (keyList = 
                     DITAUtil.getNonEmptyAttribute(childElement,
                                                   null, "keys")) != null) {
                    boolean add = true;
                    boolean skip = false;

                    if (DITAUtil.getNonEmptyAttribute(childElement, null,
                                                      "conkeyref") != null) {
                        console.warning(childElement, 
                                        Msg.msg("ignoringAttrInKeydef", 
                                                "conkeyref", keyList));
                        skip = true;
                    }
                    
                    String keyref = 
                        DITAUtil.getNonEmptyAttribute(childElement, 
                                                      null, "keyref");
                    if (keyref != null) {
                        if (keyref.lastIndexOf('/') < 0) {
                            String href = null; 

                            Keys.Entry entry = keys.getEntry(keyref);
                            if (entry != null) {
                                href = entry.getAttribute(null, "href");
                            }

                            if (href != null) {
                                // Add using *this* href.
                                childElement.setAttributeNS(null, "href",
                                                            href);
                                
                                // These attributes come with the above href.
                                String value =
                                    entry.getAttribute(null, "format");
                                if (value != null) {
                                     childElement.setAttributeNS(null, "format",
                                                                 value);
                                }
                                value = entry.getAttribute(null, "scope");
                                if (value != null) {
                                     childElement.setAttributeNS(null, "scope",
                                                                 value);
                                }
                                value = entry.getAttribute(DITAC_NS_URI,
                                                           ABSOLUTE_HREF_NAME);
                                if (value != null) {
                                    childElement.setAttributeNS(
                                        DITAC_NS_URI, ABSOLUTE_HREF_QNAME,
                                        value);
                                }
                            } else {
                                if (lastPass) {
                                    console.warning(
                                        childElement, 
                                        Msg.msg("ignoringAttrInKeydef", 
                                                "keyref", keyList));

                                    if (DITAUtil.getNonEmptyAttribute(
                                            childElement,
                                            null, "href") == null) {
                                        skip = true;
                                    }
                                    // Otherwise, add==true.
                                } else {
                                    // Do not add during this pass. 
                                    // Retry later.
                                    add = false;
                                    ++keyrefCount[0];
                                }
                            }
                        } else {
                            // Something like keys="foo" keyref="bar/gee" is
                            // not a usable key definition.
                            
                            console.warning(childElement, 
                                            Msg.msg("ignoringAttrInKeydef", 
                                                    "keyref", keyList));

                            if (DITAUtil.getNonEmptyAttribute(
                                    childElement, null, "href") == null) {
                                skip = true;
                            }
                            // Otherwise, add==true.
                        }
                    }

                    if (skip) {
                        // Mark as processed.
                        childElement.removeAttributeNS(null, "keys");
                        childElement.removeAttributeNS(null, "keyref");

                        console.warning(childElement, 
                                        Msg.msg("skippingKeydef", keyList));
                    } else if (add) {
                        // Mark as processed.
                        childElement.removeAttributeNS(null, "keys");
                        childElement.removeAttributeNS(null, "keyref");

                        if (!addKeys(keyList, childElement, loadedTopics,
                                     keys)) {
                            return false;
                        }
                    }
                    // Otherwise, may be during next pass.
                }

                if (!collectKeys(childElement, loadedTopics, keys, 
                                 keyrefCount, lastPass)) {
                    return false;
                }
            }

            child = child.getNextSibling();
        }

        return true;
    }

    private static String[] SKIPPED_ATTRIBUTES = {
        "keys",
        "processing-role",
        "id",
        "class",
        "keyref"
    };

    private boolean addKeys(String keyList, Element element, 
                            LoadedDocuments loadedTopics, Keys keys) {
        // Quick check ---

        boolean add = false;

        String[] keyItems = XMLText.splitList(keyList);
        for (String key : keyItems) {
            if (!keys.contains(key)) {
                add = true;
                break;
            }
        }

        if (!add) {
            return true;
        }

        // Create the topicref which is bound to the key ---

        String href = null;
        String scope = null;
        String format = null;

        Element topicref = mapDoc.createElementNS(null, "topicref");
        topicref.setAttributeNS(null, "class", "- map/topicref ");

        NamedNodeMap attrs = element.getAttributes();
        int attrCount = attrs.getLength();
        
        for (int i = 0; i < attrCount; ++i) {
            Attr attr = (Attr) attrs.item(i);

            String attrName = attr.getName(); // A QName.
            String attrValue = attr.getValue();

            if (!StringList.contains(SKIPPED_ATTRIBUTES, attrName) &&
                (attrValue = attrValue.trim()).length() > 0) {
                topicref.setAttributeNS(attr.getNamespaceURI(), attrName, 
                                        attrValue);

                if ("href".equals(attrName)) {
                    href = attrValue;
                } else if ("scope".equals(attrName)) {
                    scope = attrValue;
                } else if ("format".equals(attrName)) {
                    format = attrValue.toLowerCase();
                }
            }
        }

        Element meta = DITAUtil.findChildByClass(element, "map/topicmeta");
        if (meta != null) {
            topicref.appendChild(meta.cloneNode(/*deep*/ true));
        }

        // Normalize the href of a topic ---

        if (href != null) {
            URL url = null;
            String ext = null;
            try {
                // Href has been made absolute by LoadedDocuments.
                url = URLUtil.createURL(href);

                ext = URLUtil.getExtension(url);
                if (ext != null) {
                    ext = ext.toLowerCase();
                }
            } catch (MalformedURLException ignored) {}

            if (url != null &&
                url.getRef() == null && 
                (scope == null || "local".equals(scope.trim())) &&
                ((format != null && "dita".equals(format.trim())) ||
                 (format == null && 
                  ("dita".equals(ext) || "xml".equals(ext))))) {
                // We have a local topic whose URL has no #topic_id fragment.

                LoadedDocument loadedDoc;
                try {
                    loadedDoc = loadedTopics.load(url, /*process*/ false);
                } catch (Exception e) {
                    console.error(element, Msg.msg("cannotLoad", url, 
                                                   ThrowableUtil.reason(e)));
                    return false;
                }

                LoadedTopic firstTopic = loadedDoc.getFirstTopic();
                if (firstTopic != null) {
                    href = URIComponent.setFragment(href, firstTopic.topicId);
                    topicref.setAttributeNS(null, "href", href);
                }
            }
        }

        // Add keys ---

        for (String key : keyItems) {
            if (!keys.contains(key)) {
                keys.setEntry(new Keys.Entry(key, topicref));
            }
        }

        return true;
    }
}
