module vcs.utils;

import std.stdio : writefln;
import std.file;
import std.path;

void VCSMessage(string msg) {
    writefln("VCS::%s", msg);
}

string findRootDirectory() {
        string cwd = getcwd();

        /// TODO::Find .vcs folder
        return cwd;
    }

/* Other Utilities if I can be arsed */