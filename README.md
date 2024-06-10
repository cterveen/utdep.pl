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

To be decided, but consider it free to use, modify and distribute.
