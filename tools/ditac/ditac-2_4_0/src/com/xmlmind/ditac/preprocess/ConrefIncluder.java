/*
 * Copyright (c) 2009-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import static javax.xml.XMLConstants.XML_NS_URI;
import org.w3c.dom.Node;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Attr;
import org.w3c.dom.Element;
import org.w3c.dom.Document;
import com.xmlmind.util.ArrayUtil;
import com.xmlmind.util.URIComponent;
import com.xmlmind.util.URLUtil;
import com.xmlmind.util.XMLText;
import com.xmlmind.util.Console;
import com.xmlmind.ditac.util.DOMUtil;
import com.xmlmind.ditac.util.DITAUtil;

/*package*/ final class ConrefIncluder extends Includer {
    private static final class ConrefIncl extends Incl {
        public final URL targetURL;
        public final String targetId;
        public final String targetId2;
        public final String endOfRangeId;

        public ConrefIncl(Element directiveElement, URL url1, URL url2) {
            super(directiveElement);

            String fragment = URLUtil.getFragment(url1);
            if (fragment == null) {
                targetURL = url1;
                targetId = targetId2 = null;
            } else {
                targetURL = URLUtil.setFragment(url1, null);
                int pos = fragment.lastIndexOf('/');
                if (pos > 0 && pos+1 < fragment.length()) {
                    targetId = fragment.substring(0, pos);
                    targetId2 = fragment.substring(pos+1);
                } else {
                    targetId = fragment;
                    targetId2 = null;
                }
            }

            if (url2 != null) {
                String endId = null;
                String endId2 = null;

                fragment = URLUtil.getFragment(url2);
                if (fragment != null) {
                    int pos = fragment.lastIndexOf('/');
                    if (pos > 0 && pos+1 < fragment.length()) {
                        endId = fragment.substring(0, pos);
                        endId2 = fragment.substring(pos+1);
                    } else {
                        endId = fragment;
                        endId2 = null;
                    }
                }

                if (targetId2 != null) {
                    endOfRangeId = endId2;
                } else if (targetId != null && endId2 == null) {
                    endOfRangeId = endId;
                } else {
                    endOfRangeId = null;
                }
            } else {
                endOfRangeId = null;
            }
        }

        public String getConrefHref() {
            StringBuilder buffer = 
                new StringBuilder(targetURL.toExternalForm());
            if (targetId != null) {
                buffer.append('#');
                buffer.append(URIComponent.quoteFragment(targetId));

                if (targetId2 != null) {
                    buffer.append('/');
                    buffer.append(URIComponent.quoteFragment(targetId2));
                }
            }
            return buffer.toString();
        }

        public String getConrefendHref() {
            if (endOfRangeId == null) {
                return null;
            }

            StringBuilder buffer = 
                new StringBuilder(targetURL.toExternalForm());

            if (targetId2 != null) {
                buffer.append('#');
                buffer.append(URIComponent.quoteFragment(targetId));
                buffer.append('/');
                buffer.append(URIComponent.quoteFragment(endOfRangeId));
            } else {
                buffer.append('#');
                buffer.append(URIComponent.quoteFragment(endOfRangeId));
            }

            return buffer.toString();
        }
    }

    // -----------------------------------------------------------------------

    public ConrefIncluder() {
        this(null, null);
    }

    public ConrefIncluder(Keys keys, Console c) {
        super(keys, c);
    }

    protected Incl detectInclusion(Element element) {
        // LoadedDocuments.process did this:
        // @conkeyref have been converted to @conref.
        // @conref, @conrefend contain absolute URLs.

        String conref = DITAUtil.getNonEmptyAttribute(element, null, "conref");
        if (conref != null &&
            DITAUtil.getNonEmptyAttribute(element,null,"conaction") == null) {
            URL url1 = null;
            try {
                url1 = URLUtil.createURL(conref);
            } catch (MalformedURLException ignored) {
                console.warning(element, 
                                Msg.msg("invalidAttribute", conref, "conref"));
            }

            if (url1 != null) {
                URL url2 = null;

                String conrefend = 
                    DITAUtil.getNonEmptyAttribute(element, null, "conrefend");
                if (conrefend != null) {
                    try {
                        url2 = URLUtil.createURL(conrefend);
                    } catch (MalformedURLException ignored) {
                        console.warning(element, 
                                        Msg.msg("invalidAttribute", 
                                                conrefend, "conrefend"));
                    }
                }

                ConrefIncl conrefIncl = new ConrefIncl(element, url1, url2);

                if (url2 != null && conrefIncl.endOfRangeId == null) {
                    console.warning(element, Msg.msg("inconsistentConrefend", 
                                                     conrefend, conref));
                }

                return conrefIncl;
            }
        }

        return null;
    }

    protected void fetchIncluded(Incl incl)
        throws IOException, InclusionException {
        ConrefIncl conrefIncl = (ConrefIncl) incl;

        Doc targetDoc = fetchDoc(conrefIncl.targetURL);

        Element target = findConrefTarget(conrefIncl, targetDoc);

        Element copy = copyConrefTarget(incl.directiveElement, target);
        if (conrefIncl.endOfRangeId == null ||
            conrefIncl.endOfRangeId.equals(
                DITAUtil.getNonEmptyAttribute(target, null, "id"))) {
            incl.replacementNodes = new Node[] { copy };
        } else {
            Node[] copies = copyConrefTargetRange(conrefIncl, target);
            incl.replacementNodes = ArrayUtil.insert(copies, 0, copy);
        }
    }

    private Element findConrefTarget(ConrefIncl incl, Doc targetDoc) 
        throws InclusionException {
        Element target = null;

        switch (targetDoc.type) {
        case MAP:
        case BOOKMAP:
            if (incl.targetId == null) {
                target = targetDoc.document.getDocumentElement();
            } else if (incl.targetId2 == null) {
                // Branch or the whole map (e.g. conref="foo.ditamap#foo").
                target = DITAUtil.findElementById(targetDoc.document, 
                                                  incl.targetId);
            }
            break;
        case MULTI_TOPIC:
        case TOPIC:
            {
                LoadedTopic loadedTopic;
                if (incl.targetId == null) {
                    loadedTopic = targetDoc.getFirstTopic();
                } else {
                    loadedTopic = targetDoc.findTopicById(incl.targetId);
                }

                if (loadedTopic != null) {
                    target = loadedTopic.element;

                    if (incl.targetId2 != null) {
                        target = DITAUtil.findElementById(target,
                                                          incl.targetId2);
                    }
                }
            }
            break;
        }

        if (target == null) {
            throw new InclusionException(
              Msg.msg("targetNotFound", incl.getConrefHref(), "conref"));
        }

        return target;
    }

    private Element copyConrefTarget(Element conrefSource,
                                     Element conrefTarget) 
        throws InclusionException {
        // Check ---

        Document conrefSourceDocument = conrefSource.getOwnerDocument();
        Document conrefTargetDocument = conrefTarget.getOwnerDocument();

        checkDomains(conrefSource, conrefSourceDocument,
                     conrefTarget, conrefTargetDocument);

        // Copy ---
        
        // Our UserData is also copied by importNode.
        Element copy = (Element) 
            conrefSourceDocument.importNode(conrefTarget, /*deep*/ true);

        copyAttributes(conrefSource, conrefTarget, copy);

        return copy;
    }

    private void checkDomains(Element conrefSource,
                              Document conrefSourceDocument,
                              Element conrefTarget, 
                              Document conrefTargetDocument) 
        throws InclusionException {
        if (!DOMUtil.sameName(conrefSource, conrefTarget)) {
            throw new InclusionException(
                Msg.msg("sourceAndTargetAreDifferentElements",
                        DOMUtil.formatName(conrefSource),
                        DOMUtil.formatName(conrefTarget)));
        }

        String sourceDomains =
            DOMUtil.lookupAttribute(conrefSource, null, "domains");
        if (sourceDomains == null || sourceDomains.length() == 0) {
            throw new InclusionException(
                Msg.msg("noDomains", conrefSourceDocument.getDocumentURI()));
        }

        String targetDomains =
            DOMUtil.lookupAttribute(conrefTarget, null, "domains");
        if (targetDomains == null || targetDomains.length() == 0) {
            throw new InclusionException(
                Msg.msg("noDomains", conrefTargetDocument.getDocumentURI()));
        }

        if (!DITAUtil.checkDomains(sourceDomains, targetDomains)) {
            // Not an exception. Happens to easily when including from
            // a ditabase.
            console.warning(conrefSource, 
                            Msg.msg("domainMismatch", 
                                    XMLText.collapseWhiteSpace(targetDomains), 
                                    XMLText.collapseWhiteSpace(sourceDomains)));
        }
    }

    private static void copyAttributes(Element conrefSource,
                                       Element conrefTarget,
                                       Element copy) {
        // This function also copies @class from conrefSource to copy.
        // This works because conrefSource and conrefTarget have the
        // same element type.

        DOMUtil.removeAllAttributes(copy);

        // Note that the "conref" and "conrefend" attributes may be copied
        // from the conref target because the conref target may itself be a
        // conref source!

        NamedNodeMap conrefSourceAttrs = conrefSource.getAttributes();
        int conrefSourceAttrCount = conrefSourceAttrs.getLength();

        String[] dontCopyFromTargetList = new String[4+conrefSourceAttrCount];
        int dontCopyFromTargetCount = 0;
        dontCopyFromTargetList[dontCopyFromTargetCount++] = "id";
        dontCopyFromTargetList[dontCopyFromTargetCount++] = "xtrf";
        dontCopyFromTargetList[dontCopyFromTargetCount++] = "xtrc";
        dontCopyFromTargetList[dontCopyFromTargetCount++] = "xml:lang";

        for (int i = 0; i < conrefSourceAttrCount; ++i) {
            Attr attr = (Attr) conrefSourceAttrs.item(i);

            String attrNS = attr.getNamespaceURI();
            String attrName = attr.getName(); // Qualified name.
            String attrValue = attr.getValue();

            if ("id".equals(attrName)) {
                copy.setAttributeNS(null, attrName, attrValue);
            } else {
                if (!"conref".equals(attrName) &&
                    !"conrefend".equals(attrName) &&
                    !"xtrf".equals(attrName) &&
                    !"xtrc".equals(attrName) &&
                    !"xml:lang".equals(attrName) &&
                    !"-dita-use-conref-target".equals(attrValue) &&
                    // Using XXE, a newly created element having a required
                    // attribute often has "???" as its attribute value.
                    // Example: <image href="???"/>.  
                    // In fact, the attribute value is not really specified
                    // and as such, must not be copied.
                    !"???".equals(attrValue)) {
                    copy.setAttributeNS(attrNS, attrName, attrValue);
                    dontCopyFromTargetList[dontCopyFromTargetCount++] = 
                        attrName;
                }
            }
        }

        NamedNodeMap conrefTargetAttrs = conrefTarget.getAttributes();
        int conrefTargetAttrCount = conrefTargetAttrs.getLength();

        for (int i = 0; i < conrefTargetAttrCount; ++i) {
            Attr attr = (Attr) conrefTargetAttrs.item(i);

            String attrNS = attr.getNamespaceURI();
            String attrName = attr.getName(); // Qualified name.
            String attrValue = attr.getValue();

            boolean copyAttr = true;
            for (int k = 0; k < dontCopyFromTargetCount; ++k) {
                if (dontCopyFromTargetList[k].equals(attrName)) {
                    copyAttr = false;
                    break;
                }
            }

            if (copyAttr) {
                // Note that "-dita-use-conref-target" is propagated from
                // target to included.
                copy.setAttributeNS(attrNS, attrName, attrValue);
            }
        }

        String lang = DOMUtil.lookupAttribute(conrefTarget, XML_NS_URI, "lang");
        if (lang != null && lang.length() > 0) {
            copy.setAttributeNS(XML_NS_URI, "xml:lang", lang);
        }
    }

    private static Node[] copyConrefTargetRange(ConrefIncl conrefIncl,
                                                Element conrefTarget) 
        throws InclusionException {
        // Find end of range ---

        String endOfRangeId = conrefIncl.endOfRangeId;
        Element endOfRange = null;
        int rangeSize = 0;

        Node node = conrefTarget.getNextSibling();
        while (node != null) {
            ++rangeSize;

            if (node.getNodeType() == Node.ELEMENT_NODE) {
                Element element = (Element) node;

                if (endOfRangeId.equals(
                        DITAUtil.getNonEmptyAttribute(element, null, "id"))) {
                    endOfRange = element;
                    break;
                }
            }

            node = node.getNextSibling();
        }

        if (endOfRange == null) {
            throw new InclusionException(
                Msg.msg("targetNotFound", conrefIncl.getConrefendHref(),
                        "conrefend"));
        }

        // Check ---

        if (!DOMUtil.sameName(endOfRange, conrefTarget)) {
            throw new InclusionException(
                Msg.msg("invalidConrefRange", DOMUtil.formatName(conrefTarget), 
                        DOMUtil.formatName(endOfRange)));
        }

        Element conrefSource = conrefIncl.directiveElement;
        Document conrefSourceDocument = conrefSource.getOwnerDocument();

        Element conrefSourceParent = DOMUtil.getParentElement(conrefSource);
        Element conrefTargetParent = DOMUtil.getParentElement(conrefTarget);

        if (conrefSourceParent != null && 
            conrefTargetParent != null &&
            !DOMUtil.sameName(conrefSourceParent, conrefTargetParent) &&
            !DITAUtil.isSpecializedFrom(conrefTargetParent,
                                        conrefSourceParent)) {
            throw new InclusionException(
                Msg.msg("targetParentNotSpecializedFromSourceParent",
                        DOMUtil.formatName(conrefTargetParent),
                        DOMUtil.formatName(conrefSourceParent)));
        }

        // Copy ---

        Node[] range = new Node[rangeSize];
        rangeSize = 0;

        node = conrefTarget.getNextSibling();
        while (node != null) {
            Node copy = conrefSourceDocument.importNode(node, /*deep*/ true);
            range[rangeSize++] = copy;

            if (node.getNodeType() == Node.ELEMENT_NODE) {
                Element element = (Element) node;
                Element elementCopy = (Element) copy;
                
                if (DOMUtil.sameName(element, conrefSource)) {
                    String saveId = 
                        DITAUtil.getNonEmptyAttribute(element, null, "id");
                    
                    // If an element of the range has the same element type as
                    // conrefSource, then override attributes on referenced
                    // content. However @id is special. See below.

                    copyAttributes(conrefSource, element, elementCopy);

                    // Preserve @id on intermediate nodes of the range.
                    if (saveId != null) {
                        elementCopy.setAttributeNS(null, "id", saveId);
                    } else {
                        elementCopy.removeAttributeNS(null, "id");
                    }
                }

                if (element == endOfRange) {
                    // Discard @id on the end of range element.
                    elementCopy.removeAttributeNS(null, "id");

                    // Done.
                    break;
                }
            }

            node = node.getNextSibling();
        }

        return range;
    }

    // -----------------------------------------------------------------------

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println(
                "usage: java com.xmlmind.ditac.preprocess.ConrefIncluder" +
                " in_dita_file out_flat_dita_file");
            System.exit(1);
        }
        java.io.File inFile = new java.io.File(args[0]);
        java.io.File outFile = new java.io.File(args[1]);

        LoadedDocument loadedDoc = 
            (new LoadedDocuments()).load(inFile.toURI().toURL());

        com.xmlmind.ditac.util.SimpleConsole console = 
            new com.xmlmind.ditac.util.SimpleConsole(null, false, 
                                                    Console.MessageType.ERROR);
        ConrefIncluder includer = new ConrefIncluder(null, console);
        boolean done = includer.process(loadedDoc);

        com.xmlmind.ditac.util.SaveDocument.save(loadedDoc.document, outFile);
        System.exit(done? 0 : 2);
    }
}
