module vcs.utils;

import std.stdio : writefln;
import std.file;
import std.path;
import std.string : endsWith;
import std.format : format;
import core.stdc.stdlib : exit;

void VCSMessage(string msg) {
    writefln("VCS::%s", msg);
}

/// TODO::Find a better way to search for the project root...
string findVCSDirectory(string path) {
    try {
        foreach(string p; dirEntries(path, SpanMode.breadth)) {
            if(p.endsWith(".vcs")) {
                VCSMessage(p);
                return p;
            }
        }
        return findRootDirectory(buildPath(path, ".."));

    } catch(Exception) {
        auto msg = format!"Maximum search depth reached (%s): Permission Denied (Is this a valid repository?)"(path);
        VCSMessage(msg);
        exit(1);
        return null; /// Shuts up the compiler
    }
}

/* Other Utilities if I can be arsed */