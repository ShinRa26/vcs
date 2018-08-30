module controls.initControl;
import std.file;
import std.path;
import vcs.utils;
import std.format : format;

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
        auto msg = format!"VCS::Initialised VCS repository at \"%s\""(dirCheck);
        VCSMessage(msg);
        dirCheck.mkdir;
    }
}