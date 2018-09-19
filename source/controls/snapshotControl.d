module controls.snapshot;

/// Standard modules
import std.file;
import std.path;
import std.format : format;
import std.string : endsWith, split;
import std.algorithm : canFind, find, sort;
import std.datetime.systime : SysTime, Clock;

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
        if(emptyArgCheck(this.args)) {
            DVCSMessage("Pass in files or directory to snapshot!");
            return;
        }
        
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
            case "-f":
                // INdividual files
                this.allFiles = true;
                individualFiles(this.args[1..$]);
                break;
            default:
                break;
        }
    }

    /// TODO::Create absolute path for each file
    void individualFiles(string[] args) {
        foreach(string f; args) {
            if(toIgnore(this.ignoreFile, f)) {
                continue;
            }

            if(isFile(f)) {
                this.stage ~= DVCSFile(f);
            }
        }

        writeCommit();
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
            if(!detectChange()) {
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

    /*
    * This might work maybe
    */
    bool detectChange() {
        string[] unchanged;

        // Check all previous commits
        foreach(string commitFile; dirEntries(this.rootDir, SpanMode.depth)) {
            // Skip if a directory
            if(isDir(commitFile)) {
                continue;
            }

            // Read the contents of the commit
            string content = cast(string)read(commitFile);
            string originalName = content.split("\n\n")[0].split(": ")[1];

            // Loop through each file in the stage
            foreach(DVCSFile f; this.stage) {
                // If the stage file is a match for our current file, add it to the unchanged
                if(f.filename == originalName && f.shaContents == baseName(commitFile)) {
                    // Prevents multiple addition fo the same file
                    if(!canFind(unchanged, f.filename))
                        unchanged ~= f.filename;
                }
            }
        }

        // No changes should result in the same size of unchaged and the current stage
        if(unchanged.length == this.stage.length) {
            return false;
        }

        return true;
    }
}