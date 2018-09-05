module controls.snapshot;

import std.file;
import std.path;
import vcs.utils;
import controls.vcsFile;
import std.algorithm : canFind;
import std.string : endsWith, split;
import std.digest.sha;
import std.format : format;


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
        /// TODO::Replace this with ignore file system
        foreach(string dir; dirEntries(directory, SpanMode.depth)) {
            if(isDir(dir) || toIgnore(dir)) {
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

    // bool contentChanged() {
    //     return false;
    // }

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

    bool toIgnore(string toCheck) {
        string[] ignoreList = parseIgnoreFile(buildPath(dirName(this.rootDir), ".vcsIgnore"));

        /// Check if the file/dir is present to ignore
        if(canFind(ignoreList, toCheck)) {
            return true;
        }

        /// Check wildcard entries
        foreach(string ignore; ignoreList) {
            if(canFind(ignore, "*")) {
                string split;
                try{
                    split = ignore.split("*")[0];
                } catch(Exception) {
                    split = ignore.split("*")[1];
                }

                if(canFind(split, toCheck)) {
                    return true;
                }
            }
        }

        return false;
    }
}