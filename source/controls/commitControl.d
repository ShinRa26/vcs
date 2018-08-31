module controls.commitControl;

import std.file;
import std.path;
import vcs.utils;
import controls.vcsFile;
import std.string : endsWith;

struct CommitControl {
    string[] args;
    string rootDir;
    VCSFile[] stage;
    
    this(string[] args) {
        this.args = args;
        this.rootDir = findRootDirectory(getcwd());
    }
    
    void parseArgs() {
        switch(this.args[0]) {
            case ".":
                /// Current Directory downwards
                break;
            case "-A":
                /// Everything from the root downwards
                break;
            default:
                /// Individual files
                break;
        }
    }

    /// TODO::Need to know when we're not in a repo...
    string findRootDirectory(string path) {
        foreach(string p; dirEntries(path, SpanMode.breadth)) {
            if(p.endsWith(".vcs")) {
                VCSMessage(p);
                return p;
            }
        }
        return findRootDirectory(buildPath(path, ".."));
    }
}