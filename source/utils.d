module dvcs.utils;

import std.stdio : writefln, File;
import std.file;
import std.path;
import std.string : endsWith, split;
import std.format : format;
import core.stdc.stdlib : exit;
import std.uuid : randomUUID;
import std.array : replace;
import std.algorithm : canFind, find;
import std.datetime.systime : SysTime, Clock;

void DVCSMessage(string msg, int flag = 0) {
    switch(flag) {
        case 0:
            writefln("DVCS::INFO:: - %s", msg);
            break;
        case 1:
            writefln("DVCS::DEBUG:: - %s", msg);
            break;
        case 2:
            writefln("DVCS::FATAL:: - %s", msg);
            break;
        default:
            break;

    }
}

string findDVCSDirectory(string path) {
    try {
        foreach(string p; dirEntries(path, SpanMode.breadth)) {
            if(p.endsWith(".dvcs")) {
                return p;
            }
        }
        return findDVCSDirectory(buildPath(path, ".."));

    } catch(Exception) {
        auto msg = format!"Maximum search depth reached (%s): Permission Denied (Is this a valid repository?)"(path);
        DVCSMessage(msg);
        exit(1);
        return ""; /// Shuts up the compiler
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

void writeToConfig(string configFilename, string tag, string msg = "") {
    SysTime currTime = Clock.currTime();
    string timestamp = currTime.toString().split(".")[0];

    string content = format!"\n[%s] -- %s %s\n"(tag, timestamp, msg);

    writeFile(configFilename, content, "a");
}

string[] parseIgnoreFile(string path) {
    string content = cast(string)read(path);

    version(Windows) {
        return content.split("\r\n");
    }
    version(Posix) {
        return content.split("\n");
    }
}

bool toIgnore(string ignoreFile, string toCheck) {
    string[] ignoreList = parseIgnoreFile(ignoreFile);

    /// Search for matches
    foreach(string ignore; ignoreList) {
        /// Exact matches
        if(canFind(toCheck, ignore)) {
            return true;
        }

        /// Search for wildcard entries
        if(foundWildcard(toCheck, ignore)) {
            return true;
        }
    }

    return false;
}

bool foundWildcard(string toCheck, string ignoreName) {
    string[] ignoreSplit = ignoreName.split(".");

    if(canFind(ignoreName, "*.")) {
        /// Wildcard for file extensions
        string ext = ignoreSplit[1];
        if(canFind(toCheck, ext)) {
            return true;
        }
    } else if(canFind(ignoreName, ".*")) {
        /// Wildcard for filenames
        string fname = ignoreSplit[0];
        if(canFind(toCheck, fname)) {
            return true;
        }
    }

    return false;
}

void debugSystem() {
    import std.file;
    string path = "";

    version(Windows) {
        path = "D:\\Projects\\D\\vcs\\.dvcs";
    }

    version(Posix) {
        path = "/home/group/personal/d/vcs/.dvcs";
    }

    DVCSMessage("Initialising debug", 1);
    DVCSMessage(path, 1);
}

bool emptyArgCheck(string[] args) {
    return args.length == 0;
}
/* Other Utilities if I can be arsed */