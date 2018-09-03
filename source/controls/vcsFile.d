module controls.vcsFile;

import std.file;
import std.path;
import std.zlib;
import vcs.utils;
import std.base64;
import std.digest.sha;
import std.format : format;

struct VCSFile {
    string filename;
    ubyte[] contents;
    string shaContents;

    this(string filename) {
        this.filename = absolutePath(filename);

        if(!isFile(this.filename)) {
            string msg = format!"\"%s\" is not a valid file, skipping..."(this.filename);
            VCSMessage(msg);
            this.contents = null;
        } else {
            this.contents = zLibCompressAndEncode();
            string x;
        }
    }

    ubyte[] zLibCompressAndEncode() {
        ubyte[] data = cast(ubyte[])std.file.read(this.filename);
        ubyte[] compressed = compress(data);
        ubyte[] encoded = cast(ubyte[])Base64.encode(compressed);

        ubyte[] sha = sha1Of(data);
        this.shaContents = toHexString(sha);
        return encoded;
    }   
}