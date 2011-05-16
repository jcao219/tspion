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

import std.stdio;
import std.c.windows.windows;
import core.runtime;
import core.thread;
import std.string;
import std.path;
import std.file;

alias int HHOOK;
alias int HOOKPROC;
immutable int MAX_PATH = 260;

extern(Windows) {
	HHOOK SetWindowsHookExA(int idHook, HOOKPROC lpfn, HINSTANCE hMod, DWORD dwThreadId);
	BOOL UnhookWindowsHookEx(HHOOK hhk);
	SHORT GetAsyncKeyState(int nVirtKey);
	BOOL GetMessageA(LPMSG lpMsg, HWND hWnd, UINT wMsgFilterMin, UINT wMsgFilterMax);
	VOID ExitProcess(UINT uExitCode);
	DWORD GetModuleFileNameA(HMODULE hModule, char* lpFilename, DWORD nSize);
}

__gshared HHOOK hHook;

int main(string[] args) {
	//First we will try to delete launch.exe
	deleteLauncher(args);
	if(args.length == 3 && args[1] == "sdonly")
		return 0;
	
	HINSTANCE h_inst_dll = cast(HINSTANCE) Runtime.loadLibrary("hook.dll");
	if(h_inst_dll is null) {
		writeln("Error loading hook.dll.");
		return 1;
	}
	
	(new Thread((){
		while(true) {
			Sleep(50);
			if(GetAsyncKeyState(VK_MENU) < 0 && GetAsyncKeyState(VK_CONTROL) < 0 &&
			GetAsyncKeyState(VK_SHIFT) < 0 && GetAsyncKeyState(0x53) < 0) {
				bool exitcode = cast(bool)UnhookWindowsHookEx(hHook);
				Runtime.unloadLibrary(cast(HMODULE)h_inst_dll);
				ExitProcess(exitcode);
				break;
			}
		}
	})).start();
	
	HOOKPROC hproc = cast(HOOKPROC)GetProcAddress(h_inst_dll, "_KeyboardHook@12");
	hHook = SetWindowsHookExA(13, hproc, h_inst_dll, 0);
	while(GetMessageA(null, null, 0, 0)){}
	Runtime.unloadLibrary(cast(HMODULE)h_inst_dll);
	return UnhookWindowsHookEx(hHook);
}

void deleteLauncher(string[] args) {
	string modulename;
	if(args.length == 3 && ((args[1] == "sd") || (args[1] == "sdonly")))
		modulename = args[2].strip;
	else
		return;
	int i = 0;
	while(exists(modulename)) {
		++i;
		Sleep(500);
		try
			remove(modulename);
		catch(FileException e)
			if(i > 5)
				return;
	}
}