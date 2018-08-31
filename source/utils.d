module vcs.utils;

import std.stdio : writefln;
import std.file;
import std.path;
import std.string : endsWith;

void VCSMessage(string msg) {
    writefln("VCS::%s", msg);
}

string getVCSDirectory(string cwd) {
    return null;
}

/* Other Utilities if I can be arsed */