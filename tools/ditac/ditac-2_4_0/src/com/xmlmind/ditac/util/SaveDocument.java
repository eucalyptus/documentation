/*
 * Copyright (c) 2009-2013 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.util;

import java.io.IOException;
import java.io.OutputStream;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.File;
import org.w3c.dom.DOMConfiguration;
import org.w3c.dom.Node;
import org.w3c.dom.Document;
import org.w3c.dom.ls.LSException;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSSerializer;
import org.w3c.dom.ls.LSOutput;
import com.xmlmind.util.ThrowableUtil;

public final class SaveDocument {
    private SaveDocument() {}

    public static void save(Document doc, File file) 
        throws IOException {
        DOMImplementationLS impl;
        try {
          impl = (DOMImplementationLS) DOMUtil.getDOMImplementation();
        } catch (Exception shouldNotHappen) {
            throw new IOException(ThrowableUtil.reason(shouldNotHappen));
        }

        OutputStream out = 
            new BufferedOutputStream(new FileOutputStream(file));

        LSOutput output = impl.createLSOutput();
        output.setByteStream(out);
        output.setEncoding("UTF-8");
        // For possible error messages.
        output.setSystemId(file.toURI().toASCIIString()); 
        
        LSSerializer writer = impl.createLSSerializer();

        DOMConfiguration config = writer.getDomConfig();
        config.setParameter("discard-default-content", Boolean.FALSE);
        //config.setParameter("format-pretty-print", Boolean.TRUE);

        try {
            writer.write(doc, output);
            out.flush();
        } catch (LSException e) {
            throw new IOException(ThrowableUtil.reason(e));
        } finally {
            out.close();
        }
    }
}
