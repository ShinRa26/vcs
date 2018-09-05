module controls.snapshot;

/// Standard modules
import std.file;
import std.path;
import std.format : format;
import std.string : endsWith, split;
import std.algorithm : canFind, find;

/// Custom modules
import vcs.utils;
import controls.vcsFile;

/// VCS Ignore filename
const string vcsIgnoreFile = ".vcsIgnore";

/**
TODO::Document
*/
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
            // VCSMessage(dir);
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

    /**
    * Needs reworked.
    * Commits fine but duplicate commits a file that has already been committed if change is detected.
    * TODO::Rework
    */
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
        string[] ignoreList = parseIgnoreFile(buildPath(dirName(this.rootDir), vcsIgnoreFile));
        
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
}