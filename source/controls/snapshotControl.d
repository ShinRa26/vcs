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

    /**
    * Get the last commit and compare the current state of the project to that.
    * Update files if necessary
    * Issue: If last commit has less changes than the current, that might cause a problem...
    *
    * INHERINTLY FLAWED -- CHANGES ARENT NECESSARY
    * FILES THAT HAVE CHANGED BUT NOT IN THE PREVIOUS COMMIT ARENT RECOGNISED
    * REMOVE -- JUST SNAPSHOT ENTIRE PROJECT AT ONCE
    */
    bool contentChanged() {
        size_t pathCounter;
        DVCSFile[] newStage;
        string lastCommit = getLastCommit();

        if(lastCommit == "") {
            return true;
        }

        foreach(string commitFile; dirEntries(lastCommit, SpanMode.depth)) {
            if(isFile(commitFile)) {
                string content = cast(string)read(commitFile);
                string originalName = content.split("\n\n")[0].split(": ")[1];

                foreach(DVCSFile f; this.stage) {
                    if(f.filename == originalName && f.shaContents != baseName(commitFile)) {
                        /// Bugs out here, need to check which files to add and which not to
                        newStage ~= f;
                        break;
                    }
                    newStage ~= f;
                }
            }

            pathCounter++;
        }

        if(newStage.length != 0) {
            this.stage = newStage;
            return true;
        } else if(pathCounter == 0) {
            return true;
        } else {
            return false;
        }

    }

    string getLastCommit() {
        string[SysTime] commits;
        auto currTime = Clock.currTime();

        foreach(string dir; dirEntries(this.rootDir, SpanMode.breadth)) {
            if(isDir(dir)) {
                commits[timeLastModified(dir)] = dir;
            }
        }

        SysTime[] modTimes = commits.keys;
        if(modTimes.length == 0) {
            return "";
        }


        modTimes.sort!("a > b");
        return commits[modTimes[0]];
    }
}