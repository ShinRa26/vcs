module controls.commitControl;

import std.file;
import std.path;
import vcs.utils;
import controls.vcsFile;
import std.string : endsWith;


/***
* Storing files
* 
* Read the content:
*   Compress and encode data
*   Calculate hash of content
*   Use that hash as the filename
*   Write out data to file with that name
* 
* TODO::Figure out how to determine which files have been added before
* Maybe snapshot project at first then work out a solution...
**/

struct CommitControl {
    string[] args;
    string rootDir;
    VCSFile[] stage;
    
    this(string[] args) {
        this.args = args;
        this.rootDir = findVCSDirectory(getcwd());
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
}