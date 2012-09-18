/*
 * Copyright (c) 2010-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;
import java.util.ArrayList;
import static javax.xml.XMLConstants.XML_NS_URI;
import org.w3c.dom.Node;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Attr;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.XMLText;
import com.xmlmind.util.Console;
import com.xmlmind.ditac.util.SimpleConsole;
import com.xmlmind.ditac.util.ConsoleHelper;
import com.xmlmind.ditac.util.DOMUtil;
import com.xmlmind.ditac.util.DITAUtil;

/*package*/ final class ConrefPusher {
    private ConsoleHelper console;

    private LoadedDocuments docs;

    // -----------------------------------------------------------------------

    public ConrefPusher() {
        this(null);
    }

    public ConrefPusher(Console c) {
        setConsole(c);
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

    public void process(LoadedDocument[] loadedDocs) {
        docs = new LoadedDocuments(null, null);

        int loadedDocCount = loadedDocs.length;
        for (int i = 0; i < loadedDocCount; ++i) {
            LoadedDocument loadedDoc = loadedDocs[i];
            
            // loadedDocs are assumed to have been already processed by
            // another instance of LoadedDocuments.

            loadedDocs[i] = docs.put(loadedDoc.url, loadedDoc.document, 
                                     /*process*/ false);
        }

        for (int i = 0; i < loadedDocCount; ++i) {
            executeActions(loadedDocs[i].document, /*exec*/ true);
        }
    }

    private void executeActions(Node tree, boolean exec) {
        Node child = tree.getFirstChild();
        while (child != null) {
            Node next = child.getNextSibling();

            if (child.getNodeType() == Node.ELEMENT_NODE) {
                Element childElement = (Element) child;

                String conaction = 
                    childElement.getAttributeNS(null, "conaction");
                if (conaction != null && conaction.length() > 0) {
                    next = executeAction(conaction, childElement, exec);
                }

                if (DOMUtil.getAncestorDocument(childElement) != null) {
                    // A child element having conaction="mark" is now
                    // detached from the document.
                    executeActions(childElement, exec);
                }
            }

            child = next;
        }
    }

    private enum PushType {
        PUSH_REPLACE,
        PUSH_BEFORE,
        PUSH_AFTER
    }

    private Node executeAction(String conaction, Element element, 
                               boolean exec) {
        PushType pushType = null;
        Element pushedElement = null;
        URL targetURL = null;
        Node nextNode = null;

        String conref = DITAUtil.getNonEmptyAttribute(element, null, "conref");
        removeConactionAttributes(element);

        conaction = conaction.trim();
        if ("pushreplace".equals(conaction)) {

            if (exec) {
                targetURL = getTargetURL(conref, element);
                if (targetURL != null) {
                    pushType = PushType.PUSH_REPLACE;
                    pushedElement = element;
                }
            }

            nextNode = element.getNextSibling();

        } else if ("pushbefore".equals(conaction)) {

            Element markElement = 
                getConactionElement(element, "mark", (exec == true));
            if (markElement == null) {
                // Orphaned pushbefore element.

                nextNode = element.getNextSibling();
            } else {
                if (exec) {
                    conref = DITAUtil.getNonEmptyAttribute(markElement,
                                                           null, "conref");

                    targetURL = getTargetURL(conref, markElement);
                    if (targetURL != null) {
                        pushType = PushType.PUSH_BEFORE;
                        pushedElement = element;
                    }
                }

                nextNode = markElement.getNextSibling();
                removeMarkElement(markElement);
            }

        } else if ("mark".equals(conaction)) {

            Element pushafterElement =
                getConactionElement(element, "pushafter", (exec == true));
            if (pushafterElement == null) {
                // Orphaned mark element.
                // To be removed.
            } else {
                // This conaction has already been taken into account, so get
                // rid of these attributes.
                removeConactionAttributes(pushafterElement);

                if (exec) {
                    targetURL = getTargetURL(conref, element);
                    if (targetURL != null) {
                        pushType = PushType.PUSH_AFTER;
                        pushedElement = pushafterElement;
                    }
                }
            }

            // Note that the next scanned element may be our pushafter
            // element. In such case, we'll no nothing except traverse it.
            nextNode = element.getNextSibling();
            removeMarkElement(element);

        } else if ("pushafter".equals(conaction)) {
            // Orphaned pushafter element.

            if (exec) {
                console.warning(element, 
                                Msg.msg("missingConactionElementBefore", 
                                        element.getLocalName(), "mark"));
            }

            nextNode = element.getNextSibling();
        }

        if (pushType != null) {
            executeAction(pushType, pushedElement, targetURL);
        }

        return nextNode;
    }

    private URL getTargetURL(String conref, Element element) {
        URL url = null;

        if (conref == null) {
            console.warning(element, Msg.msg("missingAttribute", "conref"));
        } else {
            try {
                // Conref has been made absolute by LoadedDocuments.
                url = URLUtil.createURL(conref);
            } catch (MalformedURLException ignored) {
                console.warning(element, 
                                Msg.msg("invalidAttribute", conref, "conref"));
            }
        }

        return url;
    }

    private static void removeMarkElement(Element element) {
        if (!DITAUtil.hasClass(element, "topic/topic") &&
            !DITAUtil.hasClass(element, "map/map")) {
            element.getParentNode().removeChild(element);
        } else {
            removeConactionAttributes(element);
        }
    }

    private static void removeConactionAttributes(Element element) {
        element.removeAttributeNS(null, "conaction");
        element.removeAttributeNS(null, "conref");
        element.removeAttributeNS(null, "conrefend");
        element.removeAttributeNS(null, "conkeyref");
    }

    private Element getConactionElement(Element element, String conaction,
                                        boolean exec) {
        Element next = DOMUtil.getNextElement(element);
        if (next != null &&
            (!conaction.equals(DITAUtil.getNonEmptyAttribute(next, null, 
                                                             "conaction")) ||
             !DOMUtil.sameName(element, next))) {
            next = null;
        }

        if (next == null && exec) {
            console.warning(element, 
                            Msg.msg("missingConactionElementAfter", 
                                    element.getLocalName(), conaction));
        }

        return next;
    }

    private void executeAction(PushType pushType, Element pushedElement, 
                               URL targetURL) {
        Element target = findTarget(targetURL, pushedElement);
        if (target == null) {
            return;
        }

        if (DOMUtil.isAncestorOf(pushedElement, target)) {
            console.warning(pushedElement, 
                            Msg.msg("sourceIsAncestorOfTarget"));
            return;
        }

        if (DOMUtil.isAncestorOf(target, pushedElement) &&
            pushType == PushType.PUSH_REPLACE) {
            console.warning(pushedElement, 
                            Msg.msg("sourceIsDescendantOfTarget"));
            return;
        }

        Element copy = copyPushed(pushType, pushedElement, target);
        if (copy == null) {
            return;
        }

        Node targetParent = target.getParentNode();
        switch (pushType) {
        case PUSH_REPLACE:
            targetParent.replaceChild(copy, target);
            break;
        case PUSH_BEFORE:
            targetParent.insertBefore(copy, target);
            break;
        case PUSH_AFTER:
            targetParent.insertBefore(copy, target.getNextSibling());
            break;
        }
    }

    private Element findTarget(URL targetURL, Element pushedElement) {
        // For error messages.
        String conref = targetURL.toExternalForm();

        String fragment = URLUtil.getFragment(targetURL);
        if (fragment != null) {
            targetURL = URLUtil.setFragment(targetURL, null);
        }

        LoadedDocument targetDoc = docs.get(targetURL);
        if (targetDoc == null) {
            console.warning(pushedElement, 
                            Msg.msg("targetDocNotLoaded", targetURL));
            return null;
        }

        Element target = null;

        switch (targetDoc.type) {
        case MAP:
        case BOOKMAP:
            if (fragment != null) {
                // Branch or the whole map (e.g. conref="foo.ditamap#foo").
                target = 
                    DITAUtil.findElementById(targetDoc.document, fragment);
            } else {
                target = targetDoc.document.getDocumentElement();
            }
            break;
        case MULTI_TOPIC:
        case TOPIC:
            {
                String topicId = null;
                String elementId = null;

                if (fragment != null) {
                    int pos = fragment.lastIndexOf('/');
                    if (pos > 0 && pos+1 < fragment.length()) {
                        topicId = fragment.substring(0, pos);
                        elementId = fragment.substring(pos+1);
                    } else {
                        topicId = fragment;
                        elementId = null;
                    }
                }

                LoadedTopic loadedTopic;
                if (topicId != null) {
                    loadedTopic = targetDoc.findTopicById(topicId);
                } else {
                    loadedTopic = targetDoc.getFirstTopic();
                }

                if (loadedTopic != null) {
                    target = loadedTopic.element;

                    if (elementId != null) {
                        target = DITAUtil.findElementById(target, elementId);
                    }
                }
            }
            break;
        }

        if (target == null) {
            console.warning(pushedElement, 
                            Msg.msg("targetNotFound", conref, "conref"));
        }

        return target;
    }

    private Element copyPushed(PushType pushType, Element pushedElement, 
                               Element target) {
        // Check domains ---

        String sourceDomains =
            DOMUtil.lookupAttribute(pushedElement, null, "domains");
        if (sourceDomains == null || sourceDomains.length() == 0) {
            String uri = 
                DOMUtil.getAncestorDocument(pushedElement).getDocumentURI();
            console.warning(pushedElement, Msg.msg("noDomains", uri));
            return null;
        }

        String targetDomains =
            DOMUtil.lookupAttribute(target, null, "domains");
        if (targetDomains == null || targetDomains.length() == 0) {
            String uri = DOMUtil.getAncestorDocument(target).getDocumentURI();
            console.warning(target, Msg.msg("noDomains", uri));
            return null;
        }

        if (!DITAUtil.checkDomains(targetDomains, sourceDomains)) {
            console.warning(pushedElement,
                            Msg.msg("reversedDomainMismatch", 
                                    XMLText.collapseWhiteSpace(targetDomains), 
                                    XMLText.collapseWhiteSpace(sourceDomains)));
            return null;
        }

        // Check elements ---

        switch (pushType) {
        case PUSH_REPLACE:
            // LIMITATION: we do not support generalizing the pushed element
            // in order to match the target element.

            if (!DOMUtil.sameName(pushedElement, target)) {
                console.warning(pushedElement, 
                                Msg.msg("sourceAndTargetAreDifferentElements",
                                        DOMUtil.formatName(pushedElement),
                                        DOMUtil.formatName(target)));
                return null;
            }
            break;
        case PUSH_BEFORE:
        case PUSH_AFTER:
            {
                Element pushedParent = DOMUtil.getParentElement(pushedElement);
                Element targetParent = DOMUtil.getParentElement(target);

                if ((pushedParent == null && targetParent != null) ||
                    (pushedParent != null && targetParent == null) ||
                    (pushedParent != null && targetParent != null &&
                     !DOMUtil.sameName(pushedParent, targetParent) &&
                     !DITAUtil.isSpecializedFrom(pushedParent,
                                                 targetParent))) {
                    console.warning(
                        pushedElement,
                        Msg.msg("sourceParentNotSpecializedFromTargetParent",
                                DOMUtil.formatName(pushedParent),
                                DOMUtil.formatName(targetParent)));
                    return null;
                }
            }
            break;
        }

        // Copy ---

        Element copy = (Element) 
            target.getOwnerDocument().importNode(pushedElement, /*deep*/ true);

        String lang = 
            DOMUtil.lookupAttribute(pushedElement, XML_NS_URI, "lang");
        if (lang != null && lang.length() > 0) {
            copy.setAttributeNS(XML_NS_URI, "xml:lang", lang);
        }

        // Discard all attributes and elements related to conaction found
        // anywhere inside the copy.
        executeActions(copy, /*exec*/ false);

        if (pushType == PushType.PUSH_REPLACE) {
            NamedNodeMap attrs = target.getAttributes();
            int attrCount = attrs.getLength();

            for (int i = 0; i < attrCount; ++i) {
                Attr attr = (Attr) attrs.item(i);

                String attrNS = attr.getNamespaceURI();
                String attrLocalName = attr.getLocalName(); 

                if (XML_NS_URI.equals(attrNS) && 
                    "lang".equals(attrLocalName)) {
                    continue;
                }

                if (DITAUtil.getNonEmptyAttribute(copy, attrNS, 
                                                  attrLocalName) == null) {
                    copy.setAttributeNS(attrNS, /*qName*/ attr.getName(), 
                                        attr.getValue());
                }
            }
        }

        return copy;
    }
}
