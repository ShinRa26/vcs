module controls.dvcsFile;

import std.file;
import std.path;
import std.zlib;
import dvcs.utils;
import std.base64;
import std.digest.sha;
import std.format : format;

struct DVCSFile {
    string filename;
    ubyte[] contents;
    string shaContents;

    this(string filename) {
        this.filename = absolutePath(filename);

        if(!isFile(this.filename)) {
            string msg = format!"\"%s\" is not a valid file, skipping..."(this.filename);
            DVCSMessage(msg);
            this.contents = null;
        } else {
            this.contents = zLibCompressAndEncode();
            string x;
        }
    }

    /// Test comment
    ubyte[] zLibCompressAndEncode() {
        ubyte[] data = cast(ubyte[])std.file.read(this.filename);
        
        ubyte[] sha = sha1Of(data);
        this.shaContents = toHexString(sha);

        ubyte[] compressed = compress(data);
        ubyte[] encoded = cast(ubyte[])Base64.encode(compressed);

        return encoded;
    }   
}