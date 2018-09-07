module controls.revert;

import std.file;
import std.path;
import std.zlib;
import std.base64;
import std.string : split;
import std.format : format;

import dvcs.utils;

struct Revert {
    string[] args;
    string rootDir;

    this(string[] args) {
        this.args = args;
        this.rootDir = findDVCSDirectory(getcwd());
    }

    void revertToCommit() {
        string commitID = this.args[0];
        string commitPath = buildPath(this.rootDir, commitID);

        if(!isDir(commitPath)) {
            auto msg = format!"Commit ID \"%s\" cannot be found!"(commitID);
            DVCSMessage(msg);
            return;
        }


        foreach(string commitFile; dirEntries(commitPath, SpanMode.depth)) {
            string content = cast(string)read(commitFile);
            string[] splitContent = content.split("\n\n");

            string savePath = splitContent[0].split(": ")[1];
            string fileData = splitContent[1];

            string fileContents = decodeContent(fileData);
            writeFile(savePath, fileContents);
            
        }
    }

    string decodeContent(string data) {
        ubyte[] decodedData = Base64.decode(data);
        ubyte[] decompressedData = cast(ubyte[])uncompress(cast(string)decodedData);

        return cast(string)decompressedData;
    }
}