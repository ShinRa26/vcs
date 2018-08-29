import std.stdio : writeln, writefln;

void parseArguments(string[] cmdLineArgs) {
    string initialArg = cmdLineArgs[0];
    
    switch(initialArg) {
        case "init":
			import controls.initControl;
            break;
        case "add":
			import controls.addControl;
            break;
        case "commit":
            break;
        case "revert":
            break;
        default:
			writefln("VCS::Unknown command: %s\n", initialArg);
            break;
    }
}

void main(string[] args) {
	parseArguments(args[1..$]);
}
