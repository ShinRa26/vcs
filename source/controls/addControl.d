module controls.addControl;

import std.file;
import std.path;
import vcs.utils;

struct AddControl {
    string[] args;
    string vcsDirectory;
    
    this(string[] args) {
        this.args = args;
        this.vcsDirectory = findRootDirectory();
    }

    string findRootDirectory() {
        string cwd = getcwd();

        /// TODO::Find .vcs folder
        return cwd;
    }
}