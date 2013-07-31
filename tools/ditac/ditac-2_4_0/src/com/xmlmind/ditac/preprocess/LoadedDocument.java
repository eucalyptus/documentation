/*
 * Copyright (c) 2009-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.net.URL;
import java.util.ArrayList;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.ditac.util.ConsoleHelper;
import com.xmlmind.ditac.util.DOMUtil;
import com.xmlmind.ditac.util.DITAUtil;
import com.xmlmind.ditac.util.Resolve;

/**
 * Not part of the public, documented, API.
 */
public class LoadedDocument {
    public enum Type {
        MAP,
        BOOKMAP,
        MULTI_TOPIC,
        TOPIC
    }

    public final URL url;
    public final Document document;
    public final Type type;

    private boolean synthetic;
    private URL originalURL;

    private LoadedTopic[] topics;

    // -----------------------------------------------------------------------

    public LoadedDocument(URL url, Document document) 
        throws IllegalArgumentException {
        assert(url.getRef() == null);
        this.url = url;
        this.document = document;

        Element root = document.getDocumentElement();
        if ("dita".equals(root.getLocalName())) {
            type = Type.MULTI_TOPIC;
        } else if (DITAUtil.hasClass(root, "topic/topic")) {
            type = Type.TOPIC;
        } else if (DITAUtil.hasClass(root, "bookmap/bookmap")) {
            // ***IMPORTANT*** test bookmap before map.
            type = Type.BOOKMAP;
        } else if (DITAUtil.hasClass(root, "map/map")) {
            type = Type.MAP;
        } else {
            throw new IllegalArgumentException(
                Msg.msg("unexpectedElement", DOMUtil.formatName(root)));
        }

        // No longer useful.
        root.removeAttributeNS("http://www.w3.org/2001/XMLSchema-instance",
                               /*localName*/ "noNamespaceSchemaLocation");
    }
    
    public void setSynthetic(URL originalURL) {
        synthetic = true;
        this.originalURL = originalURL;
    }

    public boolean isSynthetic() {
        return synthetic;
    }

    public URL getOriginalURL() {
        return originalURL;
    }

    public LoadedTopic[] getTopics() {
        return getTopics(null);
    }

    public LoadedTopic[] getTopics(ConsoleHelper console) {
        if (topics == null) {
            switch (type) {
            case MULTI_TOPIC:
                {
                    ArrayList<LoadedTopic> list = new ArrayList<LoadedTopic>();

                    Element root = document.getDocumentElement();

                    Node child = root.getFirstChild();
                    while (child != null) {
                        if (child.getNodeType() == Node.ELEMENT_NODE) {
                            Element element = (Element) child;
                            if (DITAUtil.hasClass(element, "topic/topic")) {
                                list.add(new LoadedTopic(element, this, 
                                                         console));
                            }
                        }

                        child = child.getNextSibling();
                    }

                    topics = new LoadedTopic[list.size()];
                    list.toArray(topics);
                }
                break;
                    
            case TOPIC:
                {
                    Element root = document.getDocumentElement();
                    topics = new LoadedTopic[] { 
                        new LoadedTopic(root, this, console) 
                    };
                }
                break;
            }
        }
        return topics;
    }

    public int getTopicCount() {
        LoadedTopic[] loadedTopics = getTopics();
        return (loadedTopics == null)? 0 : loadedTopics.length;
    }

    public LoadedTopic getFirstTopic() {
        LoadedTopic[] loadedTopics = getTopics();
        if (loadedTopics == null || loadedTopics.length == 0) {
            return null;
        }

        return loadedTopics[0];
    }

    public LoadedTopic getSingleTopic() {
        LoadedTopic[] loadedTopics = getTopics();
        if (loadedTopics == null || loadedTopics.length != 1) {
            return null;
        }

        LoadedTopic singleTopic = loadedTopics[0];

        LoadedTopic[] nestedTopics = singleTopic.topics;
        if (nestedTopics != null && nestedTopics.length > 0) {
            singleTopic = null;
        }

        return singleTopic;
    }

    public LoadedTopic findTopicById(String id) {
        LoadedTopic[] loadedTopics = getTopics();
        if (loadedTopics == null || loadedTopics.length == 0) {
            return null;
        }

        return findTopicById(loadedTopics, id);
    }

    private static LoadedTopic findTopicById(LoadedTopic[] loadedTopics, 
                                             String id) {
        for (int i = 0; i < loadedTopics.length; ++i) {
            LoadedTopic loadedTopic = loadedTopics[i];

            if (loadedTopic.topicId.equals(id)) {
                return loadedTopic;
            }

            LoadedTopic[] nestedTopics = loadedTopic.topics;
            if (nestedTopics != null && nestedTopics.length > 0) {
                LoadedTopic found = findTopicById(nestedTopics, id);
                if (found != null) {
                    return found;
                }
            }
        }
        return null;
    }

    public String toString() {
        return url.toExternalForm();
    }
}
