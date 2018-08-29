import std.stdio : writeln;
import vcs.argparser : parseArguments;


void main(string[] args) {
	parseArguments(args[1..$]);
}
