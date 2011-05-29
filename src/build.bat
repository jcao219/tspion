@echo off

echo Building in debug mode

   REM Copyright 2010 Jimmy Cao

   REM Licensed under the Apache License, Version 2.0 (the "License");
   REM you may not use this file except in compliance with the License.
   REM You may obtain a copy of the License at

       REM http://www.apache.org/licenses/LICENSE-2.0

   REM Unless required by applicable law or agreed to in writing, software
   REM distributed under the License is distributed on an "AS IS" BASIS,
   REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   REM See the License for the specific language governing permissions and
   REM limitations under the License.

IF NOT EXIST build MKDIR build
cd build
dmd -ofhook.dll ..\hook.d ..\hook.def ..\dll.d
dmd ..\tspion.d
del hook.map
del hook.obj
del tspion.map
del tspion.obj
cd ..
echo Build complete