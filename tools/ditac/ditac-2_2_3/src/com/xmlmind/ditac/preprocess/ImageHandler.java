/*
 * Copyright (c) 2009-2010 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of the XMLmind DITA Converter project.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.ditac.preprocess;

import java.io.File;
import java.net.URL;
import com.xmlmind.util.Console;

/**
 * A {@link PreProcessor} invokes the same ImageHandler to process all the
 * images contained in all the documents being preprocessed. However, an
 * ImageHandler is invoked only for images having an URL which is relative to
 * the document being preprocessed, not for image having an absolute URL.
 * <p>A basic ImageHandler may copy its image argument to a directory which is
 * part of the deliverable. A more sophisticated ImageHandler may convert its
 * image argument to a different format (example: convert a <tt>.svg</tt>
 * image to <tt>.png</tt>).
 */
public interface ImageHandler {
    /**
     * Parses specified parameter string.
     * 
     * @param parameters parameter string having a syntax which is specific to
     * this ImageHandler
     * @exception Exception If for any reason this operation fails
     */
    void parseParameters(String parameters)
        throws Exception;

    /**
     * Reset the internal state of this ImageHandler. Invoked by the
     * PreProcessor before a run. Allows the PreProcessor to reuse the same
     * ImageHandler to process several documents.
     */
    void reset()
        throws Exception;

    /**
     * Process specified image.
     * 
     * @param imageURL The URL of the image to be processed
     * @param outDir The directory where the input image, as is or modified,
     * is to be copied
     * @param console Console on which progress, trace, debug, etc, message
     * can be displayed. May be <code>null</code>.
     * @return The properly escaped, relative to <tt>outDir</tt>, URL of the
     * processed image.
     * <p>Return <code>null</code> if default processing is to take place. The
     * default processing does nothing at all and returns
     * <code>imageURL.toExternalForm()</code>. This means that the deliverable
     * will point to the images referenced in the source document.
     * @exception Exception if, for any reason, this operation fails
     */
    String handleImage(URL imageURL, File outDir, Console console)
        throws Exception;
}
