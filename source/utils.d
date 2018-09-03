module vcs.utils;

import std.stdio : writefln, File;
import std.file;
import std.path;
import std.string : endsWith;
import std.format : format;
import core.stdc.stdlib : exit;
import std.uuid : randomUUID;
import std.array : replace;

void VCSMessage(string msg) {
    writefln("VCS::%s", msg);
}

/// TODO::Find a better way to search for the project root...
string findVCSDirectory(string path) {
    try {
        foreach(string p; dirEntries(path, SpanMode.breadth)) {
            if(p.endsWith(".vcs")) {
                return p;
            }
        }
        return findVCSDirectory(buildPath(path, ".."));

    } catch(Exception) {
        auto msg = format!"Maximum search depth reached (%s): Permission Denied (Is this a valid repository?)"(path);
        VCSMessage(msg);
        exit(1);
        return null; /// Shuts up the compiler
    }
}


string createRandomUUID() {
    string uuid = randomUUID().toString().replace("-", "");
    return cast(string)uuid[0..8];
}

void writeFile(string name, string contents, string flag = "wb") {
    auto f = File(name, flag);
    f.write(contents);
    f.close();
}
/* Other Utilities if I can be arsed */