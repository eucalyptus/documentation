/*
 * Copyright (c) 2002-2011 Pixware SARL. All rights reserved.
 *
 * Author: Hussein Shafie
 *
 * This file is part of several XMLmind projects.
 * For conditions of distribution and use, see the accompanying LEGAL.txt file.
 */
package com.xmlmind.util;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.io.FilterInputStream;
import java.io.FilterOutputStream;

/*TEST_BASE64_STREAM
import java.io.File;
import java.io.FileInputStream;
import java.io.BufferedInputStream;
import java.io.FileOutputStream;
import java.io.BufferedOutputStream;
TEST_BASE64_STREAM*/

/*DECODER_TOOL
import java.io.File;
import java.io.FileInputStream;
import java.io.BufferedInputStream;
import java.io.FileOutputStream;
import java.io.BufferedOutputStream;
DECODER_TOOL*/

/**
 * Base-64 encoder/decoder. Compliant with MIME's base64 scheme.
 */
public final class Base64 {
    private Base64() {}

    private static final String digits = 
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + 
        "abcdefghijklmnopqrstuvwxyz0123456789+/=";
    private static final char[] toDigit = digits.toCharArray();

    private static byte[] toDigit2;
    static {
        try {
            toDigit2 = digits.getBytes("US-ASCII");
        } catch (UnsupportedEncodingException cannotHappen) {
            cannotHappen.printStackTrace();
        }
    }

    private static byte[] fromDigit = new byte[256];
    static {
        for (int i = 0; i < 256; ++i) 
            fromDigit[i] = -1;

        for (int i = 'A'; i <= 'Z'; ++i) 
            fromDigit[i] = (byte) (i - 'A');

        for (int i = 'a'; i <= 'z'; ++i) 
            fromDigit[i] = (byte) (26 + i - 'a');

        for (int i = '0'; i <= '9'; ++i) 
            fromDigit[i] = (byte) (52 + i - '0');

        fromDigit['+'] = 62;
        fromDigit['/'] = 63;
    }

    private static final int DIGIT1          = 0;
    private static final int DIGIT2          = 1;
    private static final int DIGIT3_OR_EQUAL = 2;
    private static final int EQUAL           = 3;
    private static final int DIGIT4_OR_EQUAL = 4;
    private static final int END             = 5;

    /**
     * Decodes base-64 encoded string.
     * 
     * @param s base-64 string to be decoded
     * @return decoded binary data or <code>null</code> if string cannot be
     * decoded.
     */
    public static byte[] decode(String s) {
        return decode(s, Integer.MAX_VALUE);
    }

    /**
     * Same as {@link #decode(String)}, except that argument limit allows to
     * limit the number of decoded bytes. This is useful, for example, to
     * detect the format of a base-64 encoded image based on its magic string.
     */
    public static byte[] decode(String s, int limit) {
        // Note that a zero-length base 64 string is valid.
        int length = s.length();
        byte[] b = new byte[3*(length/4) + 2];
        int j = 0;
        int state = DIGIT1;
        int bits = 0;
        int bitCount = 0;

        for (int i = 0 ; i < length; ++i) {
            char c = s.charAt(i);
            if (Character.isWhitespace(c)) {
                // Same state.
                continue;
            }

            int value = 0;

            switch (state) {
            case DIGIT1:
                if (c > 255 || (value = fromDigit[c]) < 0) {
                    return null;
                }
                state = DIGIT2;
                break;

            case DIGIT2:
                if (c > 255 || (value = fromDigit[c]) < 0) {
                    return null;
                }
                state = DIGIT3_OR_EQUAL;
                break;

            case DIGIT3_OR_EQUAL:
                if (c == '=') {
                    state = EQUAL;
                    continue;
                } else {
                    if (c > 255 || (value = fromDigit[c]) < 0) {
                        return null;
                    }
                    state = DIGIT4_OR_EQUAL;
                }
                break;

            case EQUAL:
                if (c == '=') {
                    state = END;
                    continue;
                } else {
                    return null;
                }

            case DIGIT4_OR_EQUAL:
                if (c == '=') {
                    state = END;
                    continue;
                } else {
                    if (c > 255 || (value = fromDigit[c]) < 0) {
                        return null;
                    }
                    state = DIGIT1;
                }
                break;

            case END:
                return null;

            default:
                throw new RuntimeException("unknown state " + state);
            }

            bits <<= 6; 
            bits |= value; 
            bitCount += 6;

            if (bitCount >= 8) {
                bitCount -= 8;
                b[j++] = (byte) ((bits >> bitCount) & 0xFF);
                if (j >= limit) {
                    state = END;
                    break;
                }
            }
        }

        switch (state) {
        case DIGIT1:
        case END:
            break;
        default:
            return null;
        }

        if (j != b.length) {
            byte[] b2 = new byte[j];
            System.arraycopy(b, 0, b2, 0, j);
            b = b2;
        }

        return b;
    }

    /**
     * Encodes binary data to base-64.
     * 
     * @param b binary data to be encoded
     * @return base-64 encoded string
     */
    public static String encode(byte[] b) {
        final int byteCount = b.length;

        int charCount = ((byteCount + 2) / 3) * 4;
        char[] chars = new char[charCount + ((charCount + 75)/76)];

        int j = 0;
        int k = 0;
        for (int i = 0; i < byteCount; i += 3) {
            boolean char4 = false;
            boolean char3 = false;

            int bits = ((int) b[i]) & 0xFF;
            bits <<= 8;
            if (i+1 < byteCount) {
                bits |= ((int) b[i+1]) & 0xFF;
                char3 = true;
            }
            bits <<= 8;
            if (i+2 < byteCount) {
                bits |= ((int) b[i+2]) & 0xFF;
                char4 = true;
            }
            chars[j+3] = toDigit[(char4? (bits & 0x3F): 64)];
            bits >>>= 6;
            chars[j+2] = toDigit[(char3? (bits & 0x3F): 64)];
            bits >>>= 6;
            chars[j+1] = toDigit[bits & 0x3F];
            bits >>>= 6;
            chars[j] = toDigit[bits & 0x3F];

            j += 4;

            k += 4;
            if (k == 76) {
                chars[j++] = '\n';
                k = 0;
            }
        }

        if (k > 0) {
            chars[j] = '\n';
        }

        return new String(chars);
    }

    // -----------------------------------------------------------------------

    /*TEST_BASE64
    public static void main(String[] args) throws Exception {
        if (args.length != 3 ||
            !("encode".equals(args[0]) || "decode".equals(args[0]))) {
            System.err.println(
                "usage: java com.xmlmind.util.Base64" + 
                " encode|decode source_file destination_file");
            System.exit(1);
        }

        if ("decode".equals(args[0])) {
            String string = FileUtil.loadString(new java.io.File(args[1]));
            byte[] bytes = Base64.decode(string);
            if (bytes != null) {
                FileUtil.saveBytes(bytes, new java.io.File(args[2]));
            } else {
                System.exit(3);
            }
        } else {
            byte[] bytes = FileUtil.loadBytes(new java.io.File(args[1]));
            String string = Base64.encode(bytes);
            FileUtil.saveString(string, new java.io.File(args[2]));
        }
    }
    TEST_BASE64*/

    // -----------------------------------------------------------------------

    /**
     * A filter input stream that decodes the base-64 encoded data obtained
     * from its underlying InputStream.
     */
    public static final class InputStream extends FilterInputStream {
        private byte[] decoded;
        private int decodedSize;
        private int decodedPos;

        public InputStream(java.io.InputStream in) {
            this(in, 4096);
        }

        public InputStream(java.io.InputStream in, int bufferSize) {
            super(in);

            // Must be a multiple of 3 because decode state is not preserved
            // between the successive invocations of decode().
            bufferSize = 3*(bufferSize/4);
            if (bufferSize <= 0) {
                bufferSize = 3072;
            }
            decoded = new byte[bufferSize];
            decodedSize = decodedPos = 0;
        }

        public int read() 
            throws IOException {
            if (decodedPos == decodedSize) {
                decode();
            }

            if (decodedSize == 0) {
                return -1;
            } else {
                return (decoded[decodedPos++] & 0xFF);
            }
        }

        private void decode() 
            throws IOException {
            decodedSize = decodedPos = 0;
            
            boolean eof = false;
            int state = DIGIT1;
            int bits = 0;
            int bitCount = 0;

            for (;;) {
                // Better use a BufferedInputStream.
                int code = in.read();
                if (code < 0) {
                    eof = true;
                    break;
                }

                char c = (char) (code & 0xFF);
                if (Character.isWhitespace(c)) {
                    // Same state.
                    continue;
                }

                int value = 0;

                switch (state) {
                case DIGIT1:
                    if (c > 255 || (value = fromDigit[c]) < 0) {
                        throw new IOException("invalid base 64 data");
                    }
                    state = DIGIT2;
                    break;

                case DIGIT2:
                    if (c > 255 || (value = fromDigit[c]) < 0) {
                        throw new IOException("invalid base 64 data");
                    }
                    state = DIGIT3_OR_EQUAL;
                    break;

                case DIGIT3_OR_EQUAL:
                    if (c == '=') {
                        state = EQUAL;
                        continue;
                    } else {
                        if (c > 255 || (value = fromDigit[c]) < 0) {
                            throw new IOException("invalid base 64 data");
                        }
                        state = DIGIT4_OR_EQUAL;
                    }
                    break;

                case EQUAL:
                    if (c == '=') {
                        state = END;
                        continue;
                    } else {
                        throw new IOException("invalid base 64 data");
                    }

                case DIGIT4_OR_EQUAL:
                    if (c == '=') {
                        state = END;
                        continue;
                    } else {
                        if (c > 255 || (value = fromDigit[c]) < 0) {
                            throw new IOException("invalid base 64 data");
                        }
                        state = DIGIT1;
                    }
                    break;

                case END:
                    throw new IOException("invalid base 64 data");

                default:
                    throw new RuntimeException("unknown state " + state);
                }

                bits <<= 6; 
                bits |= value; 
                bitCount += 6;

                if (bitCount >= 8) {
                    bitCount -= 8;
                    decoded[decodedSize++] =
                        (byte) ((bits >> bitCount) & 0xFF);
                    if (decodedSize == decoded.length) {
                        break;
                    }
                }
            }

            if (eof) {
                switch (state) {
                case DIGIT1:
                case END:
                    break;
                default:
                    throw new IOException(
                        "truncated base 64 data (state=" + state + ")");
                }
            }
        }

        public int read(byte[] b) 
            throws IOException {
            return read(b, 0, b.length);
        }

        public int read(byte[] b, int off, int len) 
            throws IOException {
            int i = 0;

            for (; i < len; ++i) {
                int code = read();
                if (code < 0) {
                    return (i > 0)? i : -1;
                }

                b[off + i] = (byte) code;
            }

            return i;
        }

        public long skip(long n)
            throws IOException {
            long i = 0;

            for (; i < n; ++i) {
                if (read() < 0)
                    break;
            }

            return i;
        }

        public int available()
            throws IOException {
            return (decodedSize - decodedPos);
        }

        public void close()
            throws IOException {
            in.close();
        }

        public boolean markSupported() { return false; }
        public void mark(int readlimit) {}
        public void reset() throws IOException { 
            throw new IOException("mark not supported"); 
        }
    }

    // -----------------------------------------------------------------------

    /**
     * A filter output stream that encodes in base-64 the binary data passed
     * to its underlying OutputStream.
     */
    public static final class OutputStream extends FilterOutputStream {
        private byte[] bytes;
        private int byteCount;
        private byte[] encoded;
        private int encodedSize;
        private int lineLength;

        public OutputStream(java.io.OutputStream out) {
            this(out, 4096);
        }

        public OutputStream(java.io.OutputStream out, int bufferSize) {
            super(out);

            bytes = new byte[3];
            byteCount = 0;

            encoded = new byte[bufferSize];
            encodedSize = lineLength = 0;
        }

        public void write(int b)
            throws IOException {
            if (byteCount == 3)
                encode();

            bytes[byteCount++] = (byte) b;
        }

        public void write(byte[] b)
            throws IOException {
            write(b, 0, b.length);
        }

        public void write(byte[] b, int off, int len)
            throws IOException {
            for (int i = 0; i < len; ++i) {
                if (byteCount == 3)
                    encode();

                bytes[byteCount++] = b[off + i];
            }
        }

        public void flush()
            throws IOException {
            if (encodedSize > 0) {
                out.write(encoded, 0, encodedSize);
                encodedSize = 0;
            }
            out.flush();
        }

        public void close()
            throws IOException {
            encode();
            if (lineLength > 0) {
                encoded[encodedSize++] = '\n';
            }
            flush();
            out.close();
        }

        private void encode() 
            throws IOException {
            if (byteCount > 0) {
                if (encodedSize + 5 >= encoded.length) {
                    out.write(encoded, 0, encodedSize);
                    encodedSize = 0;
                }

                boolean char4 = false;
                boolean char3 = false;

                int bits = ((int) bytes[0]) & 0xFF;
                bits <<= 8;
                if (byteCount > 1) {
                    bits |= ((int) bytes[1]) & 0xFF;
                    char3 = true;
                }
                bits <<= 8;
                if (byteCount > 2) {
                    bits |= ((int) bytes[2]) & 0xFF;
                    char4 = true;
                }
                encoded[encodedSize+3] = toDigit2[(char4? (bits & 0x3F): 64)];
                bits >>>= 6;
                encoded[encodedSize+2] = toDigit2[(char3? (bits & 0x3F): 64)];
                bits >>>= 6;
                encoded[encodedSize+1] = toDigit2[bits & 0x3F];
                bits >>>= 6;
                encoded[encodedSize] = toDigit2[bits & 0x3F];

                encodedSize += 4;

                lineLength += 4;
                if (lineLength == 76) {
                    encoded[encodedSize++] = '\n';
                    lineLength = 0;
                }

                byteCount = 0;
            }
        }
    }

    // -----------------------------------------------------------------------

    /*TEST_BASE64_STREAM
    public static void main(String[] args) throws Exception {
        if (args.length != 3 ||
            !("encode".equals(args[0]) || "decode".equals(args[0]))) {
            System.err.println(
                "usage: java com.xmlmind.util.Base64" + 
                " encode|decode source_file destination_file");
            System.exit(1);
        }

        if ("decode".equals(args[0])) {
            Base64.InputStream in = 
                new Base64.InputStream(
                    new BufferedInputStream(
                        new FileInputStream(new File(args[1]))));

            BufferedOutputStream out = 
                new BufferedOutputStream(
                    new FileOutputStream(new File(args[2])));

            copy(in, out);
        } else {
            BufferedInputStream in = 
                new BufferedInputStream(
                    new FileInputStream(new File(args[1])));

            Base64.OutputStream out = 
                new Base64.OutputStream(
                    new BufferedOutputStream(
                        new FileOutputStream(new File(args[2]))));

            copy(in, out);
        }
    }

    private static final void copy(java.io.InputStream in,
                                   java.io.OutputStream out)
        throws IOException {
        byte[] buffer = new byte[8192];
        int count;

        try {
            try {
                while ((count = in.read(buffer)) != -1) 
                    out.write(buffer, 0, count);

                out.flush();
            } finally {
                out.close();
            }
        } finally {
            in.close();
        }
    }
    TEST_BASE64_STREAM*/

    /*DECODER_TOOL
    public static void main(String[] args) {
        File inFile = null;
        if (args.length != 1 || !(inFile = new File(args[0])).isFile()) {
            System.err.println(
                "usage: java com.xmlmind.util.Base64 base64_input_file");
            System.exit(1);
        }

        File outFile = new File(args[0] + ".TMP");
        IOException error = null;

        try {
            Base64.InputStream in = new Base64.InputStream(
                new BufferedInputStream(new FileInputStream(inFile)));
            byte[] buffer = new byte[8192];
            int count;

            try {
                BufferedOutputStream out = 
                    new BufferedOutputStream(new FileOutputStream(outFile));

                try {
                    while ((count = in.read(buffer)) != -1) 
                        out.write(buffer, 0, count);

                    out.flush();
                } catch (IOException e) {
                    error = e;
                } finally {
                    out.close();
                }
            } catch (IOException e) {
                error = e;
            } finally {
                in.close();
            }
        } catch (IOException e) {
            error = e;
        }

        if (error != null) {
            String reason = error.getMessage();
            if (reason == null)
                reason = error.getClass().getName();

            System.err.println("Cannot decode '" + inFile + 
                               "' to '" + outFile + "': " + reason);
            System.exit(2);
        }

        if (!inFile.delete() || !outFile.renameTo(inFile)) {
            System.err.println("Cannot rename '" + inFile + 
                               "' to '" + outFile + "'.");
            System.exit(3);
        }
    }
    DECODER_TOOL*/
}
