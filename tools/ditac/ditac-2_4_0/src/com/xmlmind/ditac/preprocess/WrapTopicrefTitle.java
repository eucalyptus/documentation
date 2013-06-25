/*
 * Copyright (c) 2010-2012 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.net.URL;
import java.net.MalformedURLException;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.XMLText;
import com.xmlmind.ditac.util.DOMUtil;
import com.xmlmind.ditac.util.DITAUtil;

/*package*/ final class WrapTopicrefTitle implements Constants {
    public static final String BASENAME_PREFIX = "__TITLE";

    // -----------------------------------------------------------------------

    private WrapTopicrefTitle() {}

    public static void processMap(Element map, URL mapURL, 
                                  LoadedDocuments loadedDocs) {
        String urlPrefix = URLUtil.getParent(mapURL).toExternalForm();
        urlPrefix += BASENAME_PREFIX;

        process(map, urlPrefix, loadedDocs);
    }

    private static void process(Element element, String urlPrefix,
                                LoadedDocuments loadedDocs) {
        Node child = element.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                if (DITAUtil.hasClass(childElement, "map/topicref") &&
                    !isBooklistPlaceholder(childElement)) {
                    String href = childElement.getAttributeNS(null, "href");
                    if (href == null || href.length() == 0) {
                        Document topicDoc = createTitleContainer(childElement);
                        if (topicDoc != null) {
                            Element topic = topicDoc.getDocumentElement();

                            String id = 
                              Integer.toString(System.identityHashCode(topic),
                                               Character.MAX_RADIX);

                            URL url = null;
                            try {
                                url = new URL(urlPrefix + id + ".dita");
                            } catch (MalformedURLException cannotHappen) {
                                cannotHappen.printStackTrace();
                            }

                            if (url != null) {
                                LoadedDocument synthDoc =
                                    loadedDocs.put(url, topicDoc, 
                                                   /*process*/ false);
                                synthDoc.setSynthetic(/*originalURL*/ null);

                                id = topic.getAttributeNS(null, "id");
                                href =
                                  URLUtil.setFragment(url, id).toExternalForm();
                                childElement.setAttributeNS(null, "href", href);
                            }
                        }
                    }

                    process(childElement, urlPrefix, loadedDocs);
                }
            }

            child = child.getNextSibling();
        }
    }

    private static boolean isBooklistPlaceholder(Element topicref) {
        return (DITAUtil.getParentByClass(topicref,
                                          "bookmap/booklists") != null &&
                DITAUtil.getNonEmptyAttribute(topicref, null, "href") == null &&
                DITAUtil.findChildByClass(topicref, "map/topicref") == null);
    }

    private static Document createTitleContainer(Element topicref) {
        Element navtitle = null;
        String navtitleText = null;

        Element topicmeta = 
            DITAUtil.findChildByClass(topicref, "map/topicmeta");
        if (topicmeta != null) {
            navtitle = DITAUtil.findChildByClass(topicmeta, "topic/navtitle");
        }

        if (navtitle == null) {
            navtitleText = 
                DITAUtil.getNonEmptyAttribute(topicref, null, "navtitle");
            if (navtitleText != null &&
                (navtitleText = 
                 XMLText.collapseWhiteSpace(navtitleText)).length() == 0) {
                navtitleText = null;
            }
        }

        if (navtitle == null && navtitleText == null &&
            DITAUtil.findChildByClass(topicref, "map/topicref") != null) {
            // Implicit title? ---

            for (int i = 0; i < ROOT_ROLE_COUNT; ++i) {
                String cls = ROOT_ROLES[i];

                if (DITAUtil.hasClass(topicref, cls)) {
                    navtitleText = "__AUTO__" + 
                        cls.substring(cls.lastIndexOf('/') + 1) + "__";
                    break;
                }
            }
        }

        if (navtitle == null && navtitleText == null) {
            return null;
        }

        // ---

        Document doc = DOMUtil.newDocument();

        Element topic = doc.createElementNS(null, "topic");
        topic.setAttributeNS(null, "class", "- topic/topic ");
        topic.setAttributeNS(null, "id", DITAUtil.generateID(topic));

        doc.appendChild(topic);

        Element title = doc.createElementNS(null, "title");
        title.setAttributeNS(null, "class", "- topic/title ");
            
        topic.appendChild(title);

        if (navtitle != null) {
            DOMUtil.copyChildren(navtitle, title, doc);
        } else {
            title.appendChild(doc.createTextNode(navtitleText));
        }

        return doc;
    }
}
