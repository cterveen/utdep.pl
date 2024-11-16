## Project name

utdep.pl

## Description

utdep.pl is a Perl script that can retrieve dependencies and other information from Unreal Tournament packages. It was initially written to determine the dependencies of Unreal Tournament map files, but got extended on the way with retrieving information about maps.

The script can be considered a beta version. The script has been used in several projects involving Unreal Tournament '99 packages and overall runs fine. Some issues are mentioned in the POD documentation. POD documentation is available and a little help text is displayed when the script is run without arguments.

No further development is intended. A derivative module of the script that reads information from Unreal Tournament packages has been written: [upkg](https://github.com/cterveen/upkg).

## Installation

Just copy the script anywhere you want.

## Use

`perl -w utdep.pl CTF-2on2-Crates.unr -d`

Run the script without package name to get other options.

## Credits

Written by Christiaan ter Veen <https://www.rork.nl/>

Thanks to Just**Me at the [Beyond Unreal](https://www.beyondunreal.com/) Forums for getting me on the way and providing an example script.  
Thanks to NogginBasher & BlackWolf for testing the script.

Technical details

- Unreal Tournament Package File Format: <https://archive.org/details/ut-package-file-format>

## Copyright
Copyright (c) 2008-2011 Christiaan ter Veen

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software within the restrictions of the Unreal(r) Engine End User License Agreement but no restrictions otherwise, including without limitation the rights to use, copy, modify, merge, publish, distribute, and/or sublicense copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The software must be available in source code form (including, but not limited to, any compiler, linker, toolchain, and runtime), and must available to all Unreal Engine Licensees free of charge, on all platforms, in any Product as to comply with the Unreal(r) Engine End User License Agreement.

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
