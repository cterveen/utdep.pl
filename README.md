NAME

  utdep.pl - retrieve the dependencies of a unreal tournament package.

DESCRIPTION

  This script will extract the headers, index and import table from an unreal
  tournament package (usually a map package) and return a list of packages on
  which the package depends.

USAGE

  perl -w utdep.pl <package> <switch> [windows/linux/mac]
  utdep.pl <package> <switch>  [linux]

  There are several switches:

  -h     print the headers
  -n     print the name table
  -i     print the import table
  -d     print the dependencies list (default)
  -l     print levelinfo
  -a     print advanced info (levelinfo, weapons/ammo, botpathing)
  -o #   show the properties of object, # = objectid in the export table
  -r #   dump the properties of object, # = objectid in the export table
  
  (The difference between -o and -r is that -r will print a lot more info)

CHANGELOG

  version 0.3.1
    fixed check for RF_HasStack
    
  version 0.3.0
    fixed name table reading for packageversions <64
    fixed bug in calculating the Index datatype
    added map info
    added support for reading objects

  version 0.2.0
    added some POD documentation

  version 0.1.1
    removed last character of the names
    added commandline options to print tables (nogginBasher)

  version 0.1.0
    Basic script

BUGS

   The script was tested on UT99/GOTY maps, it might work for other packages
   and/or UT versions as well. Testing revealed some bugs, most of them are
   impossible to overcome because of the way unreal packages are constructed.

   The dependencies don't have to be in the same case as the files.

   It's not possible to determine the type of all packages, in this case the
   .??? extention is used.
     Typical packages that go wrong: unrealshare.u

   Not all the packages are printed with the correct extention, the standard
   .u packages export music, sounds or textures too which will confuse the
   script. I haven't found anything to solve this so the best solution is to
   ignore them.
     In theory it's possible to check that package whether it exports the
   required data but this is beyond the intentions of this script.
     Typical packages that go wrong: editor.u, unreali.u, unrealshare.u,
   umenu.u, utmenu.u, uwindow.u

   Sometimes when using this script for an automated check in some maps errors
   occur, however they cannot be repeated when running the script on that map
   alone.
   
   When dumping object properties arrays are currently not fully supported.
   If arrays are longer then 128 the script will probably produce giberish.
   The maximum number of properties that are shown is 1024. Some datatypes
   are not implemented and might cause trouble when dumping object properties.
   (Support was added for levelinfo, which seems to work well). 
   
   QWords (64 bit strings) are parsed as bitstring rather then number to keep 
   compatibility with 32 bit systems. Currently this only affect the probemask
   of the object header.
   
   Not all object data was described, sometimes I had to do an educated guess
   based on what I found and what a value van be. Where I was wrong strange
   output is expected in further testing.

ACKNOWLEDGEMENTS

  With writing this script I had a lot of help at the Beyond Unreal forums, 
  especially from from Just**Me who gave me an example script to work from.
  You can find the topic with the example script here:
  http://forums.beyondunreal.com/showthread.php?p=2285785

  Other helpfull pages at UnrealWiki:
  http://wiki.beyondunreal.com/wiki/Package_File_Format
  http://wiki.beyondunreal.com/wiki/Package_File_Format/Data_Details

  Thanks to NogginBasher & BlackWolf for testing the script.

COPYRIGHTS & DISCLAIMER

  You have the right to copy this script, you may also redistribute, adapt and
  rewrite it if you want. I can't be held responsible for any damage of this
  script did to your system, especially not when they are redistributed or
  addapted by other persons. Use the script at your own risk.

AUTHOR

  Christiaan ter Veen [mail at rork dot nl]
  http://www.rork.nl/
