module controls.snapshot;

import std.file;
import std.path;
import vcs.utils;
import controls.vcsFile;
import std.algorithm : canFind;
import std.string : endsWith, split;
import std.digest.sha;
import std.format : format;


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

struct Snapshot {
    string[] args;
    string rootDir;
    VCSFile[] stage;
    bool allFiles;
    
    this(string[] args) {
        this.args = args;
        this.rootDir = findVCSDirectory(getcwd());
    }
    
    void parseArgs() {
        switch(this.args[0]) {
            case ".":
                /// Current Directory downwards
                fromDirectory(getcwd());
                break;
            case "-A":
                /// Everything from the root downwards
                this.allFiles = true;
                fromDirectory(dirName(this.rootDir));
                break;
            default:
                /// Individual files
                break;
        }
    }

    void fromDirectory(string directory) {
        foreach(string dir; dirEntries(directory, SpanMode.depth)) {
            /// Ignore git files just in case...
            if(isDir(dir) || canFind(dir, ".git") || canFind(dir, ".vcs")) {
                continue;
            }

            if(isFile(dir)) {
                this.stage ~= VCSFile(dir);
            }
        }

        writeCommit();
    }

    void writeCommit() {
        string commitDirectory = buildPath(this.rootDir, createRandomUUID());

        /// Check for file changes 
        /// If allFiles set, don't check
        if(!this.allFiles) {
            if(!contentChanged()) {
                VCSMessage("No changes detected, nothing to commit.");
                return;
            }
        }

        mkdir(commitDirectory);
        foreach(VCSFile x; this.stage) {
            string savePath = buildPath(commitDirectory, x.shaContents);
            string contents = format!"Filepath: %s\n\n%s"(x.filename, cast(string)x.contents);

            auto msg = format!"Created VCSFile: %s"(baseName(x.filename));
            VCSMessage(msg);

            writeFile(savePath, contents);
        }
    }

    /// Ugly implementation
    /// TODO::Fix this crock of shit
    bool contentChanged() {
        int pathCounter;
        VCSFile[] newStage;
        VCSMessage("Checking for content changes...");

        foreach(string path; dirEntries(this.rootDir, SpanMode.depth)) {
            if(isFile(path)) {
                string content = cast(string)read(path);
                string originalName = content.split("\n\n")[0].split(": ")[1];
                
                foreach(VCSFile f; this.stage) {
                    if(f.filename == originalName && f.shaContents != baseName(path)) {
                        newStage ~= f;
                        break;            
                    }
                }
            }
            pathCounter++;
        }

        if(newStage.length != 0) {
            this.stage = newStage;
            return true;
        } else if(pathCounter == 0){
            return true;
        } else {
            return false;
        }
    }
}