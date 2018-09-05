module controls.initControl;

import std.file;
import std.path;
import vcs.utils;
import std.stdio;
import std.format : format;

const string vcsConfig = ".vcsConfig";
const string vcsIgnore = ".vcsIgnore";

void initDirectory(string[] args) {
    string directory = args[0];

    if(directory == ".") {
        checkForInitDirectory(getcwd());
    } else {
        checkForInitDirectory(directory);
    }
}

void checkForInitDirectory(string directory) {
    string dirCheck = buildPath(directory, ".vcs");
    try {
        if(isDir(dirCheck)) {
            auto msg = format!".vcs directory already exists in this location: \"%s\""(dirCheck);
            VCSMessage(msg);
        }
    } catch(FileException e) {
        auto msg = format!"Initialised VCS repository at \"%s\""(dirCheck);
        VCSMessage(msg);
        dirCheck.mkdir;

        createConfigFile(directory, dirCheck);
        createIgnoreFile(directory);
    }
}

void createConfigFile(string targetDir, string vcsPath) {
    auto savePath = buildPath(targetDir, vcsConfig);
    auto f = File(savePath, "w");
    f.writef("[VCSPath] -- %s", vcsPath);

    auto msg = format!"Written config file at \"%s\""(savePath);
    VCSMessage(msg);
}

void createIgnoreFile(string targetDir) {
    auto savePath = buildPath(targetDir, vcsIgnore);
    auto f = File(savePath, "w");
    f.write("");
    
    auto msg = format!"Created ignore file at \"%s\""(savePath);
    VCSMessage(msg);
}