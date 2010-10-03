/* Copyright 2010 Jimmy Cao

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License. */

import dfl.internal.winapi;
import std.stdio;
import std.string;

void main() {
	HANDLE hc = GetStdHandle(STD_OUTPUT_HANDLE);
	SetConsoleTextAttribute(hc, 0x0a);
	
	writeln("Welcome to the TSPION launch system.\n");
	writeln("Copyright 2010 - Jimmy Cao.");
	writeln("TSPION comes with ABSOLUTELY NO WARRANTY.");
	write("Would you like to launch TSPION after unpacking (Y/n)?  ");
	
	auto yesorno = readln();
	bool autolaunch = false;
	if(yesorno.strip.toupper == "Y")
		autolaunch = true;
	writeln("\n");
	
	SetConsoleTextAttribute(hc, 0x0d);
	unpack();
	launch(autolaunch);
	SetConsoleTextAttribute(hc, 0x07);
}

void unpack() {
	char[] exedata = loadExeRC();
	char[] dlldata = loadDllRC();
	
	auto exefile = File("tspion.exe", "w");
	auto dllfile = File("hook.dll", "w");
	
	scope(exit) {
		exefile.close();
		dllfile.close();
	}
	
	write_wp(exedata, exefile);
	write_wp(dlldata, dllfile);
}

void write_wp(char[] data, File fl) {
	float lendata = data.length;
	int progress;
	write("["~" ".repeat(50)~"]"~"   0.00%");
	foreach(i, c; data) {  //intended to be slow
		auto cprog = cast(int)((i/lendata)*50);
		if(progress < cprog) {
			write("\b".repeat(60));
			write("["~"*".repeat(cprog)~" ".repeat(50-cprog)~"]");
			writef("%7.2f", 100.0*i/lendata);
			write("%");
			stdout.flush();
			progress = cprog;
		}
		fl.rawWrite(std.conv.to!string(c));
	}
	write("\b".repeat(60));
	write(" ".repeat(60));
	write("\b".repeat(60));
	writefln("Unpacked %s.", fl.name);
}

void launch(bool beginkeylog) {
	char[] modfname;
	modfname.length = 256;
	auto ns = GetModuleFileNameA(cast(HMODULE)null, &modfname[0], 256);
	string modname = std.conv.to!string(modfname[0 .. ns]).strip;
	
	if(beginkeylog)
		std.process.system(`start tspion.exe sd "`~modname~`"`);
	else
		std.process.system(`start tspion.exe sdonly "`~modname~`"`);
}

Exception up(string msg) {
	return new Exception(msg);
}

char[] loadExeRC() {
	HRSRC hrc = FindResourceExA(GetModuleHandleA(null),
								MAKEINTRESOURCEA(10),
								MAKEINTRESOURCEA(300),  //Resource 300 (tspion.exe)
								cast(ushort)MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL));
	if(!hrc)
		throw up("Could not find resources.");  //har har har.
		
	HGLOBAL hrc_h = LoadResource(null, hrc);
	if(!hrc)
		throw up("Could not load resources.");
		
	auto rcsize = SizeofResource(null, hrc);
	char[] rcdata = (cast(char*)LockResource(hrc_h))[0 .. rcsize];
	return rcdata;
}

char[] loadDllRC() {
	HRSRC hrc = FindResourceExA(GetModuleHandleA(null),
								MAKEINTRESOURCEA(10),
								MAKEINTRESOURCEA(5000),  //Resource 5000 (hook.dll)
								cast(ushort)MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL));
	if(!hrc)
		throw up("Could not find resources.");  //har har har.
		
	HGLOBAL hrc_h = LoadResource(null, hrc);
	if(!hrc)
		throw up("Could not load resources.");
		
	auto rcsize = SizeofResource(null, hrc);
	char[] rcdata = (cast(char*)LockResource(hrc_h))[0 .. rcsize];
	return rcdata;
}