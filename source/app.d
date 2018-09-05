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
        case "snap":
			import controls.snapshot;
            auto snap = Snapshot(cmdLineArgs[1..$]);
            snap.parseArgs();
            break;
        case "revert":
            break;
        case "debug":
            debugSystem();
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
