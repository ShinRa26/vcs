module controls.snapshot;

/// Standard modules
import std.file;
import std.path;
import std.format : format;
import std.string : endsWith, split;
import std.algorithm : canFind, find;

/// Custom modules
import dvcs.utils;
import controls.dvcsFile;

/// DVCS Ignore filename
const string dvcsIgnoreFile = ".dvcsIgnore";
const string dvcsConfigFile = ".dvcsConfig";

/**
TODO::Document
*/
struct Snapshot {
    string[] args;
    string rootDir, configFile, ignoreFile;
    DVCSFile[] stage;
    bool allFiles;
    
    this(string[] args) {
        this.args = args;
        this.rootDir = findDVCSDirectory(getcwd());
        this.configFile = buildPath(dirName(this.rootDir), dvcsConfigFile);
        this.ignoreFile = buildPath(dirName(this.rootDir), dvcsIgnoreFile);
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
            if(isDir(dir) || toIgnore(this.ignoreFile, dir)) {
                continue;
            }

            if(isFile(dir)) {
                this.stage ~= DVCSFile(dir);
            }
        }

        writeCommit();
    }

    void writeCommit() {
        string commitID = createRandomUUID();
        string commitDirectory = buildPath(this.rootDir, commitID);

        /// Check for file changes 
        /// If allFiles set, don't check
        if(!this.allFiles) {
            if(!contentChanged()) {
                DVCSMessage("No changes detected, nothing to commit.");
                return;
            }
        }

        mkdir(commitDirectory);
        foreach(DVCSFile x; this.stage) {
            string savePath = buildPath(commitDirectory, x.shaContents);
            string contents = format!"Filepath: %s\n\n%s"(x.filename, cast(string)x.contents);

            auto msg = format!"Created DVCSFile: %s"(baseName(x.filename));
            DVCSMessage(msg);

            writeFile(savePath, contents);
        }

        writeToConfig(this.configFile, commitID);
    }

    bool contentChanged() {
        return false;
    }

    /**
    * Needs reworked.
    * Commits fine but duplicate commits a file that has already been committed if change is detected.
    * TODO::Rework
    */
    // bool contentChanged() {                                                                                                        
    //     int pathCounter;
    //     DVCSFile[] newStage;
    //     DVCSMessage("Checking for content changes...");

    //     foreach(string path; dirEntries(this.rootDir, SpanMode.depth)) {
    //         if(isFile(path)) {
    //             string content = cast(string)read(path);
    //             string originalName = content.split("\n\n")[0].split(": ")[1];
                
    //             foreach(DVCSFile f; this.stage) {
    //                 if(f.filename == originalName && f.shaContents != baseName(path)) {
    //                     newStage ~= f;
    //                     break;            
    //                 }
    //             }
    //         }
    //         pathCounter++;
    //     }

    //     if(newStage.length != 0) {
    //         this.stage = newStage;
    //         return true;
    //     } else if(pathCounter == 0){
    //         return true;
    //     } else {
    //         return false;
    //     }
    // }
}