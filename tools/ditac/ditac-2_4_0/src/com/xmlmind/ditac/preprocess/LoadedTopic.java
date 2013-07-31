/*
 * Copyright (c) 2009-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.util.ArrayList;
import org.w3c.dom.Node;
import org.w3c.dom.Element;
import com.xmlmind.util.URIComponent;
import com.xmlmind.ditac.util.ConsoleHelper;
import com.xmlmind.ditac.util.DITAUtil;

/**
 * Not part of the public, documented, API.
 */
public final class LoadedTopic {
    public final Element element;
    public final Object parent;
    public String topicId;
    public final LoadedTopic[] topics;

    private boolean excluded;

    // -----------------------------------------------------------------------

    public LoadedTopic(Element element, Object parent, ConsoleHelper console) {
        this.element = element;
        this.parent = parent;

        // This may change the value of @id. Therefore topicId and @id
        // are initially in sync.
        topicId = DITAUtil.ensureHasValidID(element, console);

        ArrayList<LoadedTopic> list = new ArrayList<LoadedTopic>();

        Node child = element.getFirstChild();
        while (child != null) {
            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;
                if (DITAUtil.hasClass(childElement, "topic/topic")) {
                    list.add(new LoadedTopic(childElement, this, console));
                }
            }

            child = child.getNextSibling();
        }

        topics = new LoadedTopic[list.size()];
        list.toArray(topics);
    }

    public void setExcluded(boolean exclude) {
        excluded = exclude;
    }

    public boolean isExcluded() {
        return excluded;
    }

    public LoadedTopic getParentTopic() {
        if (parent instanceof LoadedTopic) {
            return (LoadedTopic) parent;
        } else {
            return null;
        }
    }

    public LoadedDocument getAncestorDocument() {
        Object ancestor = parent;
        while (ancestor != null) {
            if (ancestor instanceof LoadedDocument) {
                return (LoadedDocument) ancestor;
            }
            ancestor = ((LoadedTopic) ancestor).parent;
        }
        return null;
    }

    public String getHref() {
        String location = "???";
        LoadedDocument loadedDoc = getAncestorDocument();
        if (loadedDoc != null) {
            location = loadedDoc.url.toExternalForm();
        }
        return location + "#" + URIComponent.quoteFragment(topicId);
    }

    public String toString() {
        return getHref();
    }
}
