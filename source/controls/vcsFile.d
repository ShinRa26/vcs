module controls.vcsFile;

import std.file;
import std.path;
import std.zlib;
import vcs.utils;
import std.base64;
import std.format : format;

struct VCSFile {
    string filename;
    ubyte[] contents;

    this(string filename) {
        this.filename = absolutePath(filename);

        if(!isFile(this.filename)) {
            string msg = format!"\"%s\" is not a valid file, skipping..."(this.filename);
            VCSMessage(msg);
            this.contents = null;
        } else {
            this.contents = zLibCompressAndEncode();
            auto msg = format!"Create VCSFile: \"%s\""(this.filename);
            VCSMessage(msg);
        }
    }

    ubyte[] zLibCompressAndEncode() {
        ubyte[] data = cast(ubyte[])std.file.read(this.filename);
        ubyte[] compressed = compress(data);
        ubyte[] encoded = cast(ubyte[])Base64.encode(compressed);

        return data;
    }   
}