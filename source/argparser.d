module vcs.argparser;

void parseArguments(string[] cmdLineArgs) {
    import std.stdio : writeln;
    string initialArg = cmdLineArgs[0];

    writeln(cmdLineArgs);
    
    switch(initialArg) {
        case "init":
            break;
        case "add":
            break;
        case "commit":
            break;
        case "revert":
            break;
        default:
            break;
    }
}