import dvcs.utils;
import std.format : format;
import std.stdio : writeln, writefln;

void parseArguments(string[] cmdLineArgs) {
    string initialArg = cmdLineArgs[0];
    
    switch(initialArg) {
        case "init":
			import controls.init;
            initDirectory(cmdLineArgs[1..$]);
            break;
        case "snap":
			import controls.snapshot;
            auto snap = Snapshot(cmdLineArgs[1..$]);
            snap.parseArgs();
            break;
        case "revert":
            import controls.revert;
            auto revert = Revert(cmdLineArgs[1..$]);
            revert.revertToCommit();
            break;
        case "debug":
            debugSystem();
            break;
        default:
			auto msg = format!"Unknown command: %s\n"(initialArg);
            DVCSMessage(msg);
            break;
    }
}

void main(string[] args) {
	parseArguments(args[1..$]);
}
