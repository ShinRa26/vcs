import vcs.utils;
import std.format : format;
import std.stdio : writeln, writefln;

void parseArguments(string[] cmdLineArgs) {
    string initialArg = cmdLineArgs[0];
    
    switch(initialArg) {
        case "init":
			import controls.initControl;
            initDirectory(cmdLineArgs[1..$]);
            break;
        case "commit":
			import controls.commitControl;
            auto commitControl = CommitControl(cmdLineArgs[1..$]);
            break;
        case "revert":
            break;
        default:
			auto msg = format!"Unknown command: %s\n"(initialArg);
            VCSMessage(msg);
            break;
    }
}

void main(string[] args) {
	parseArguments(args[1..$]);
}
