module controls.initControl;

import std.file;
import std.path;
import dvcs.utils;
import std.stdio;
import std.format : format;

const string dvcsConfig = ".dvcsConfig";
const string dvcsIgnore = ".dvcsIgnore";

void initDirectory(string[] args) {
    string directory = args[0];

    if(directory == ".") {
        checkForInitDirectory(getcwd());
    } else {
        checkForInitDirectory(directory);
    }
}

void checkForInitDirectory(string directory) {
    string dirCheck = buildPath(directory, ".dvcs");
    try {
        if(isDir(dirCheck)) {
            auto msg = format!".dvcs directory already exists in this location: \"%s\""(dirCheck);
            DVCSMessage(msg);
        }
    } catch(FileException e) {
        auto msg = format!"Initialised DVCS repository at \"%s\""(dirCheck);
        DVCSMessage(msg);
        dirCheck.mkdir;

        createConfigFile(directory, dirCheck);
        createIgnoreFile(directory);
    }
}

void createConfigFile(string targetDir, string dvcsPath) {
    auto savePath = buildPath(targetDir, dvcsConfig);
    auto f = File(savePath, "w");
    f.writef("[DVCSPath] -- %s\n", dvcsPath);

    auto msg = format!"Written config file at \"%s\""(savePath);
    DVCSMessage(msg);
}

void createIgnoreFile(string targetDir) {
    auto savePath = buildPath(targetDir, dvcsIgnore);
    auto f = File(savePath, "w");
    f.write("");
    
    auto msg = format!"Created ignore file at \"%s\""(savePath);
    DVCSMessage(msg);
}