import std.stdio : writeln, writefln;

void parseArguments(string[] cmdLineArgs) {
    string initialArg = cmdLineArgs[0];
    
    switch(initialArg) {
        case "init":
			import controls.initControl;
            initDirectory(cmdLineArgs[1..$]);
            break;
        case "add":
			import controls.addControl;
            AddControl add = AddControl(cmdLineArgs[1..$]);
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
