#!/usr/bin/perl
# utdep.pl - Check the dependencies of an Unreal Tournament (UT99) file.
# Version: 0.3.1

use strict;
use warnings;

my $debug = 0;

my $map = shift;

unless ($map) {
  print "Usage: perl -w $0 <FileName> [ -h | -n | -i | -d | -e | -a | -l | -o # | -r # ]\n";
  print "  to print headers, nametable, importtable, dependencies (default), exporttable, advanced info (nw), levelinfo, object dump (# = export id) key-value only; object dump (# = export id) more info.\n";
  exit;
}

my %headers;
my (@names, @imports, @exports);

open(MAP, "<", $map) or die "Can't open $map: $!";

# get the headers to find the tables.
getHeaders();

# check the file's signature to make sure it's an Unreal Tournament file;
if ($headers{"Signature"} ne "9e2a83c1") {
  # die "Invallid file";
}

# get the tables I need to get the dependancies
getNames();
getImports();
getImportNames();
getExports();
getExportNames();

# parseAndRunArgs();

my $arg;

$arg = shift;

unless ($arg) {
  $arg = "-d";
}

while ($arg) {
  if ($arg eq "-h") {
    printHeaders();
  }
  if ($arg eq "-n") {
    printNames();
  }
  if ($arg eq "-i") {
    printImports();
  }
  if ($arg eq "-d") {
    printDependencies();
  }
  if ($arg eq "-e") {
    printExports();
  }
  if ($arg eq "-a") {
    printAdvancedInfo();
  }
  if ($arg eq "-l") {
    printLevelInfo();
  }
  if ($arg eq "-du") {
    printDU();
  }
  if ($arg eq "-r") {
    my $item = shift;
    printRawObject($item);
  }
  if ($arg eq "-o") {
    my $item = shift;
    printObject($item);
  }
  # $arg = shift || exit;
  $arg = shift;
}

close(MAP);

#----------------------------------------#
# subroutines used above and for testing #
#----------------------------------------#

sub extractSound {
  my $item = shift;
  my $aref = $exports[$item];
  my $offset = $aref->{offset};
  my $size = $aref->{Size};

  my @properties = getExportProperties();
  my $SoundFormat = ReadIndex();
     $SoundFormat = ReadIndex();
     $SoundFormat = ReadIndex();
  print "Format: " . getName($SoundFormat) . "\n";
  my $OffsetNext = ReadLong();
  my $SoundSize = ReadIndex();
  my $SoundData;
  read(MAP, $SoundData, $SoundSize);
  print $SoundData;
}

sub getExportProperties {
  my @properties;
  my $name = getName(ReadIndex());
  while($name ne "None") {
    print "Property: $name";
    my $infoByte;
    read(MAP, $infoByte, 1);
    my $type = ($infoByte & (1+2+4+8));
    my $size = ($infoByte & (16+32+64));
    my $flag = ($infoByte & 128);
    print " $type, $size. $flag\n";


    my $name = getName(ReadIndex());
  }
}

sub getExports {
  # skip to the exports table
  seek(MAP, $headers{"ExportOffset"}, 0);
  for (my $i = 0; $i < $headers{"ExportCount"}; $i++) {
    my $class = ReadIndex();
    my $super = ReadIndex();
    my $package = ReadLong();
    my $name = ReadIndex();
    my $flags = ReadLong();
    my $size = ReadIndex();
    my $offset = -1;
    if ($size > 0) {
      $offset = ReadIndex();
    }
    $exports[$i] = {"offset" => $offset, "Package" => $package, "Super" => $super, "Class" => $class, "Name" => $name, "Size" => $size, "Flags" => $flags, "Id" => $i};
  }
}

sub getExportNames {
  for(my $i = 0; $i < $headers{"ExportCount"}; $i++) {
    $exports[$i]->{"_Package"} = getName($exports[$i]->{"Package"});
    $exports[$i]->{"_Super"} = getName($exports[$i]->{"Super"});
    ## Catch the bug where we fail to parse the file properly, and abort the process instead of looping and spewing errors.
    # if ($exports[$i]->{"Package"} < 0 || $exports[$i]->{"Package"} >= 0) {
    # } else {
      # die "getexportNames(): Package is not a number!"
    # }
    # if (!$exports[$i]->{"Package"}) {
    # if ($exports[$i]->{"Package"} eq "") {
    #   die "getexportNames(): \$export[".$i."]->{\"Package\"} has no value; aborting";
      # die "getexportNames(): Package \"" . ($exports[$i]->{"Package"}) . "\" (".$i.") is not a number; aborting";
    # }
    if ($exports[$i]->{"Class"} < 0) {
      my $tmp = $exports[$i]->{"Class"};
      $tmp *= -1;
      $tmp -= 1;
      $exports[$i]->{"_Class"} = getName($imports[$tmp]->{"Name"});
    }
    else {
      $exports[$i]->{"_Class"} = getName($exports[$i]->{"Class"});
    }
    $exports[$i]->{"_Name"} = getName($exports[$i]->{"Name"});
  }
}

sub getHeaders {
  # this shouldn't be an issue, paranoia.
  seek(MAP, 0, 0);
  $headers{"Signature"} = sprintf("%x", ReadLong());
  $headers{"Version"} = ReadShort();
  $headers{"License"} = ReadShort();
  $headers{"Flag"} = ReadLong();
  $headers{"NameCount"} = ReadLong();
  $headers{"NameOffset"} = ReadLong();
  $headers{"ExportCount"} = ReadLong();
  $headers{"ExportOffset"} = ReadLong();
  $headers{"ImportCount"} = ReadLong();
  $headers{"ImportOffset"} = ReadLong();

  # only get the GUID if the version >= 68
  if ($headers{"Version"} >= 68) {
    $headers{"GUID"} = sprintf("%x", ReadLong()) . "-" . sprintf("%x", ReadLong()) . "-" . sprintf("%x", ReadLong()) . "-" . sprintf("%x", ReadLong());
  }
}

sub getImports {
  # skip to the imports table
  seek(MAP, $headers{"ImportOffset"}, 0);
  for (my $i = 0; $i < $headers{"ImportCount"}; $i++) {
    my $offset = tell(MAP);
    my $class_package = ReadIndex();
    my $class_name = ReadIndex();
    my $package = ReadLong();
    my $name = ReadIndex();
    $imports[$i] = {"offset" => $offset, "uPackage" => $class_package, "uName" => $class_name, "Package" => $package, "Name" => $name};
  }
}

sub getImportNames {
  for(my $i = 0; $i < $headers{"ImportCount"}; $i++) {
    $imports[$i]->{"_uPackage"} = getName($imports[$i]->{"uPackage"});
    $imports[$i]->{"_uName"} = getName($imports[$i]->{"uName"});
    ## Catch the bug where we fail to parse the file properly, and abort the process instead of looping and spewing errors.
    # if ($imports[$i]->{"Package"} < 0 || $imports[$i]->{"Package"} >= 0) {
    # } else {
      # die "getImportNames(): Package is not a number!"
    # }
    # if (!$imports[$i]->{"Package"}) {
    if ($imports[$i]->{"Package"} eq "") {
      die "getImportNames(): \$import[".$i."]->{\"Package\"} has no value; aborting";
      # die "getImportNames(): Package \"" . ($imports[$i]->{"Package"}) . "\" (".$i.") is not a number; aborting";
    }
    if ($imports[$i]->{"Package"} < 0) {
      my $tmp = $imports[$i]->{"Package"};
      $tmp *= -1;
      $tmp -= 1;
      $imports[$i]->{"_Package"} = getName($imports[$tmp]->{"Name"});
    }
    else {
      $imports[$i]->{"_Package"} = getName($imports[$i]->{"Package"});
    }
    $imports[$i]->{"_Name"} = getName($imports[$i]->{"Name"});
  }
}

sub getName {
  my $i = shift;
  if ($i < 0) {
      return "Engine";
  }
  elsif ($i > $#names) {
    return "Error";
  }
  else {
    return $names[$i]->{"Name"};
  }
}

sub getNames {
  # skip to the name table.
  seek(MAP, $headers{"NameOffset"}, 0);

  my $object;
  my $length;

  for (my $i = 0; $i < $headers{"NameCount"}; $i++) {
    my $name = ReadString();
    chop($name);

    my $flag = ReadLong();
    $names[$i] = { "Name" => $name, "Flag" => $flag }; 
    # $debug && print "getNames: name=" . $object . " flag=" . $object . "\n";
  }
}

sub getObject {
  my $id = shift;
  my $offset = $exports[$id]->{"offset"};
  my $objects;

  seek(MAP, $offset, 0);
    
  # HEADER, should not be read if the object doesn't have an RF_HasStack flag
  my $flags = $exports[$id]->{"Flags"};
     
  if ($flags & 0x02000000) {
    my $node = ReadIndex();
    my $statenode = ReadIndex();
    my $probemask = ReadQWord();
    my $latentaction = ReadLong();
    if ($node != 0) {
      my $offset = ReadIndex();
    }
  }
  
  # build in savety, loop stops after 256 itterations to prevent eternal loops
  foreach (0 .. 256) {
    my $object = ReadObjectProperty();
    if (getName($object->{'name'}) eq "None") {
      last;
    }
    else {
      my $name = getName($object->{'name'});
      
      # correct arrays
      if ($objects->{$name}) {
        my $obj = $objects->{$name};
        $objects->{$name."[0]"} = $obj;
        delete($objects->{$name});
      }
      if ($object->{'i'}) {
        $name .= "[" . $object->{'i'} . "]";
      }
      $objects->{$name} = $object;
      
      if ($_ == 256) {
        warn("WARNING: more object properties available\n");
      }
    }
    
  }
  return $objects;
}

sub printAdvancedInfo {
  # prints extra info for CTF maps
  print "Advanced information:\n";
  
  printLevelInfo();
 
  my %info;
  foreach my $href(@exports) {
    $info{lc($href->{"_Class"})}++;
  }

  print "\nWeapons:";
  print "\n  Enforcer: " . (exists($info{enforcer}) ? $info{enforcer} . ", ammo: " . (exists($info{miniammo}) ? $info{miniammo} : "no") : "no");
  print "\n  Bio Rifle: " . (exists($info{ut_biorifle}) ? $info{ut_biorifle} . ", ammo: " . (exists($info{bioammo}) ? $info{bioammo} : "no") : "no");
  print "\n  Shock rifle: " . (exists($info{shockrifle}) ? $info{shockrifle} . ", ammo: " . (exists($info{shockcore}) ? $info{shockcore} : "no") : "no");
  print "\n  Pulse gun: " . (exists($info{pulsegun}) ? $info{pulsegun} . ", ammo: " . (exists($info{pammo}) ? $info{pammo} : "no") : "no");
  print "\n  Ripper: " . (exists($info{ripper}) ? $info{ripper} . ", ammo: " . (exists($info{bladehopper}) ? $info{bladehopper} : "no") : "no");
  print "\n  Minigun: " . (exists($info{minigun2}) ? $info{minigun2} . ", ammo: " . (exists($info{miniammo}) ? $info{miniammo} : "no") : "no");
  print "\n  Flak Cannon: " . (exists($info{ut_flakcannon}) ? $info{ut_flakcannon} . ", ammo: " . (exists($info{flakammo}) ? $info{flakammo} : "no") : "no");
  print "\n  Rocket Launcher: " . (exists($info{ut_eightball}) ? $info{ut_eightball} . ", ammo: " . (exists($info{rocketpack}) ? $info{rocketpack} : "no") : "no");
  print "\n  Sniper Rifle: " . (exists($info{sniperrifle}) ? $info{sniperrifle} . ", ammo: " . (exists($info{bulletbox}) ? $info{bulletbox} : "no") : "no");
  print "\n  Redeemer: " . (exists($info{warheadlauncher}) ? $info{warheadlauncher} : "no");

  print "\nPowerups:";
  print "\n  Medbox: " . (exists($info{medbox}) ? $info{medbox} : "no");
  print "\n  Health Vials: " . (exists($info{healthvial}) ? $info{healthvial} : "no");
  print "\n  Big Keg o' health: " . (exists($info{healthpack}) ? $info{healthpack} : "no");
  print "\n  Thigh pads: " . (exists($info{thighpads}) ? $info{thighpads} : "no");
  print "\n  Armor: " . (exists($info{armor2}) ? $info{armor2} : "no");
  print "\n  Shieldbelt: " . (exists($info{ut_shieldbelt}) ? $info{ut_shieldbelt} : "no");
  print "\n  Damage Amplifier: " . (exists($info{udamage}) ? $info{udamage} : "no");
  print "\n  Jump boots: " . (exists($info{ut_jumpboots}) ? $info{ut_jumpboots} : "no");

  print "\nPlayerstarts: " . $info{playerstart};

  print "\nBotpathing: " . (exists($info{pathnode}) ? "yes" : "no");
  print "\n  AlternatePaths: " . (exists($info{alternatepath}) ? "yes" : "no");
  print "\n  Ambushpoints: " . (exists($info{ambushpoint}) ? "yes" : "no");
  print "\n  DefensePoints: " . (exists($info{defensepoint}) ? "yes" : "no");

  print "\n\n";

  # print map($_ . " => " .$info{$_} . "\n", sort keys %info);
}

sub printDependencies {
  # this subroutine can probably be written a lot better but this will do for now.
  for (my $i = 0; $i < $headers{"ImportCount"}; $i++) {
    if ($imports[$i]->{"Package"} == 0) {
      # now we have a package;
      for(my $x = 0; $x < $headers{"ImportCount"}; $x++) {
        if ($imports[$i]->{"_Name"} eq $imports[$x]->{"_Package"}) {
          # there must be some hidden character for I can only use a regexp and not an exact match;
          if ($imports[$x]->{"_uName"} =~ m/Class/) {
            $imports[$i]->{"Type"} = ".u";
            last;
          }
          elsif ($imports[$x]->{"_uName"} =~ m/Texture/) {
            $imports[$i]->{"Type"} = ".utx";
          }
          elsif ($imports[$x]->{"_uName"} =~ m/Sound/) {
            $imports[$i]->{"Type"} = ".uax";
          }
          elsif ($imports[$x]->{"_uName"} =~ m/Music/) {
            $imports[$i]->{"Type"} = ".umx";
          }
	  else {
            # another deeper search for the origin of a package;
            foreach (my $y = 0; $y < $headers{"ImportCount"}; $y++) {
              if ($imports[$x]->{"_Name"} eq $imports[$y]->{"_Package"}) {
                if ($imports[$y]->{"_uName"} =~ m/Class/) {
                  $imports[$i]->{"Type"} = ".u";
                  last;
                }
                elsif ($imports[$y]->{"_uName"} =~ m/Texture/) {
                  $imports[$i]->{"Type"} = ".utx";
                }
                elsif ($imports[$y]->{"_uName"} =~ m/Sound/) {
                  $imports[$i]->{"Type"} = ".uax";
                }
                elsif ($imports[$y]->{"_uName"} =~ m/Music/) {
                  $imports[$i]->{"Type"} = ".umx";
                }
              }
             }
          }
          # if a package is marked as a non .u file it can also be .u package with some imported stuff
          # if it's an .u there's no need to look further though.
          last if ($imports[$i]->{"Type"} and $imports[$i]->{"Type"} eq ".u");
        }
        # same here.
          last if ($imports[$i]->{"Type"} and $imports[$i]->{"Type"} eq ".u");
        }
        print $imports[$i]->{"_Name"};
        if ($imports[$i]->{"Type"}) {
          print $imports[$i]->{"Type"} . "\n";
        }
        else {
        print ".???\n";
      }
    }
  }
}

sub printDU {
  # prints extra info for CTF maps
  print "Export offset: " . $headers{'ExportOffset'} . "\n";
  
  printLevelInfo();
 
  my %info;
  foreach my $href(@exports) {
    $info{lc($href->{"_Class"})}++;
  }

  print "Enforcer: " . (exists($info{enforcer}) ? $info{enforcer} . ", ammo: " . (exists($info{miniammo}) ? $info{miniammo} : "no") : "no");
  print "\nBio Rifle: " . (exists($info{ut_biorifle}) ? $info{ut_biorifle} . ", ammo: " . (exists($info{bioammo}) ? $info{bioammo} : "no") : "no");
  print "\nShock rifle: " . (exists($info{shockrifle}) ? $info{shockrifle} . ", ammo: " . (exists($info{shockcore}) ? $info{shockcore} : "no") : "no");
  print "\nPulse gun: " . (exists($info{pulsegun}) ? $info{pulsegun} . ", ammo: " . (exists($info{pammo}) ? $info{pammo} : "no") : "no");
  print "\nRipper: " . (exists($info{ripper}) ? $info{ripper} . ", ammo: " . (exists($info{bladehopper}) ? $info{bladehopper} : "no") : "no");
  print "\nMinigun: " . (exists($info{minigun2}) ? $info{minigun2} . ", ammo: " . (exists($info{miniammo}) ? $info{miniammo} : "no") : "no");
  print "\nFlak Cannon: " . (exists($info{ut_flakcannon}) ? $info{ut_flakcannon} . ", ammo: " . (exists($info{flakammo}) ? $info{flakammo} : "no") : "no");
  print "\nRocket Launcher: " . (exists($info{ut_eightball}) ? $info{ut_eightball} . ", ammo: " . (exists($info{rocketpack}) ? $info{rocketpack} : "no") : "no");
  print "\nSniper Rifle: " . (exists($info{sniperrifle}) ? $info{sniperrifle} . ", ammo: " . (exists($info{bulletbox}) ? $info{bulletbox} : "no") : "no");
  print "\nRedeemer: " . (exists($info{warheadlauncher}) ? $info{warheadlauncher} : "no");
  print "\nMedbox: " . (exists($info{medbox}) ? $info{medbox} : "no");
  print "\nHealth Vials: " . (exists($info{healthvial}) ? $info{healthvial} : "no");
  print "\nBig Keg o' health: " . (exists($info{healthpack}) ? $info{healthpack} : "no");
  print "\nThigh pads: " . (exists($info{thighpads}) ? $info{thighpads} : "no");
  print "\nArmor: " . (exists($info{armor2}) ? $info{armor2} : "no");
  print "\nShieldbelt: " . (exists($info{ut_shieldbelt}) ? $info{ut_shieldbelt} : "no");
  print "\nDamage Amplifier: " . (exists($info{udamage}) ? $info{udamage} : "no");
  print "\nJump boots: " . (exists($info{ut_jumpboots}) ? $info{ut_jumpboots} : "no");
  print "\nPlayerstarts: " . $info{playerstart};
  print "\nBotpathing: " . (exists($info{pathnode}) ? "yes" : "no");
  print "\nAlternatePaths: " . (exists($info{alternatepath}) ? "yes" : "no");
  print "\nAmbushpoints: " . (exists($info{ambushpoint}) ? "yes" : "no");
  print "\nDefensePoints: " . (exists($info{defensepoint}) ? "yes" : "no");
  print "\n\n";
}

sub printExports {
  print "Exports:";

  for (my $i = 0; $i < $headers{"ExportCount"}; $i++) {
    print "\n  Export $i: ";
    print join(".", $exports[$i]->{"_Package"}, $exports[$i]->{"_Super"}, $exports[$i]->{"_Class"}, $exports[$i]->{"_Name"});
    print " at $exports[$i]->{offset}, size: $exports[$i]->{Size}";
  }
  print "\n\n";
}

sub printHeaders {
  print "Headers:";
  print "\n  Signature: " . $headers{"Signature"};
  print "\n  Version: " . $headers{"Version"};
  print "\n  License: " . $headers{"License"};
  print "\n  Flag: " . $headers{"Flag"};
  print "\n  Name Count: " . $headers{"NameCount"};
  print "\n  Name Offset: " . $headers{"NameOffset"};
  print "\n  Export Count: " . $headers{"ExportCount"};
  print "\n  Export Offset: " . $headers{"ExportOffset"};
  print "\n  Import Count: " . $headers{"ImportCount"};
  print "\n  Import Offset: " . $headers{"ImportOffset"};

  # only print the GUID if the version >= 68
  if ($headers{"Version"} >= 68) {
    print "\n  GUID: " . $headers{"GUID"} 
  }

  print "\n\n";
}

sub printImports {
  print "Imports:";

  for (my $i = 0; $i < $headers{"ImportCount"}; $i++) {
    print "\n  Import $i: ";
    print join(".", $imports[$i]->{"_uPackage"}, $imports[$i]->{"_uName"}, $imports[$i]->{"_Package"}, $imports[$i]->{"_Name"});
  }
  print "\n\n";
}

sub printLevelInfo {
  my $id = -1;
  
  foreach my $href(@exports) {
    if ((lc($href->{"_Class"}) eq "levelinfo") and (lc($href->{"_Name"}) =~ m/levelinfo\d+/)) {
      $id = $href->{"Id"};
    }
  }
  
  if ($id != -1) {
    my $levelinfo = getObject($id);
    
    my $mapname = $map;
       $mapname =~ s/\.unr$//i;
    
    print "Mapname: " . $mapname . "\n";
    print "Title: " . ($levelinfo->{'Title'}->{'value'} ?  $levelinfo->{'Title'}->{'value'} : "") . "\n";
    print "Author: " . ($levelinfo->{'Author'}->{'value'} ?  $levelinfo->{'Author'}->{'value'} : "") . "\n";
    print "IdealPlayerCount: " . ($levelinfo->{'IdealPlayerCount'}->{'value'} ?  $levelinfo->{'IdealPlayerCount'}->{'value'} : "") . "\n";
    print "LevelEnterText: " . ($levelinfo->{'LevelEnterText'}->{'value'} ? $levelinfo->{'LevelEnterText'}->{'value'} : "") . "\n";

#     if ($levelinfo->{'Summary'}) {
#       my $summary_id = $levelinfo->{'Summary'}->{'value'} -1;
#       my $levelsummary = getObject($summary_id);
#     
#       print "LevelEnterText: " . ($levelsummary->{'LevelEnterText'}->{'value'} ? $levelsummary->{'LevelEnterText'}->{'value'} : "") . "\n";
#     }
#     else {
#       print "LevelEnterText: \n";
#     }
  }
  else {
    print "LevelInfo not found!\n";
  }
}

sub printNames {
  print "Names";
  for (my $i = 0; $i < $headers{"NameCount"}; $i++) {
    print "\n  Name $i: " . $names[$i]->{"Name"};
  }
  print "\n\n";
}

sub printObject {
  my $id = shift;
  
  my $object = getObject($id);
  
  print "Objectid=" . $id . "\n";
  print "Object=";
  print join(".", $exports[$id]->{"_Package"}, $exports[$id]->{"_Super"}, $exports[$id]->{"_Class"}, $exports[$id]->{"_Name"}) . "\n";
  
  foreach my $property(sort keys %{$object}) {
    print $property . "=" . $object->{$property}->{'value'} . "\n";
  }
}

sub printRawObject {
  my $id = shift;
  
  my $object = getObject($id);
  
  print "\n  Dump $id: ";
  print join(".", $exports[$id]->{"_Package"}, $exports[$id]->{"_Super"}, $exports[$id]->{"_Class"}, $exports[$id]->{"_Name"});
  print " at $exports[$id]->{offset}, size: $exports[$id]->{Size}\n\n";
  
  foreach my $property(sort keys %{$object}) {
    print $property . "\n";
    foreach my $key(sort keys %{$object->{$property}}) {
      print "  " . $key . "=" . $object->{$property}->{$key} . "\n";
    }
    print "\n";
  }
}

sub ReadIndex {
  # read an index coded section from MAP, I really have no idea what I'm doing
  # here, just copied the code from the original script but it seems to work ok

  my $buffer;
  my $neg;
  my $length = 6;

  for(my $i = 0; $i < 5; $i++) {
    my $more = 0;
    my $char;
    read(MAP, $char, 1);
    $char = vec($char, 0, 8);

    if ($i == 0) {
      $neg = ($char & 0x80);
      $more = ($char & 0x40);
      $buffer = ($char & 0x3F);
    }
    elsif ($i == 4) {
      $buffer |= ($char & 0x80) << $length;
      $more = 0;
    }
    else {
     $more = ($char & 0x80);
     $buffer |= ($char & 0x7F) << $length;
     $length += 7;
    }
    # print " --> $buffer ";
    last unless ($more);
  }

  if ($neg) {
    $buffer *= -1;
  }

  # print "ReadIndex returning buffer: " . $buffer . "\n";
  return $buffer;

}

sub ReadString {
  # series of unicode characters finshed by a zero
  
  my $string;
  my $char = 1;
  
  # if package version >= 64 the sting starts with the length; assuming this is an index.
  if ($headers{"Version"} >= 64) {
    my $size = ReadIndex();
  }
  
  $char = 1;
  while (ord($char) != 0) {
    read(MAP, $char, 1);
    $string .= $char;
  }

  return $string; 
}

sub ReadObjectProperty {
  my $object;
  my $char;
  
  # Offset (current position)
  $object->{'offset'} = sprintf("%x", tell);
    
  # INDEX - Name
  $object->{'name'} = ReadIndex();
  
  if (getName($object->{'name'}) eq "None") {
    return $object;
  }
  
  # BYTE - Infobyte
  read(MAP, $char, 1);
  $char = vec($char, 0, 8);
    
  $object->{'type'} = ($char & 0b00001111);
  $object->{'sizetype'} = ($char & 0b01110000) >> 4;
  $object->{'arrayflag'} = ($char & 0x80);
  
  # if arrayflag is set, next is the position of the array
  if (($object->{'arrayflag'}) and ($object->{'type'} != 3)) {
    # WARNING if i >128 terrible things will happen
    $object->{'i'} = ReadByte();
  }
  
  # if type is a struct the next byte will be the structname, assuming this is an INDEX
  if ($object->{'type'} == 10) {
    $object->{'structname'} = getName(ReadIndex());
  }
  
  # Get the size
  if ($object->{'sizetype'} == 0) {
    $object->{'size'} = 1;
  }
  elsif ($object->{'sizetype'} == 1) {
    $object->{'size'} = 2;
  }
  elsif ($object->{'sizetype'} == 2) {
    $object->{'size'} = 4;
  }
  elsif ($object->{'sizetype'} == 3) {
    $object->{'size'} = 12;
  }
  elsif ($object->{'sizetype'} == 4) {
    $object->{'size'} = 16;
  }
  elsif ($object->{'sizetype'} == 5) {
    # byte
    $object->{'size'} = ReadByte();
  }
  elsif ($object->{'sizetype'} == 6) {
    # word --> ReadShort
   $object->{'size'} = ReadShort();
  }
  elsif ($object->{'sizetype'} == 7) {
    # integer --> 32 bits (as UT was build for 32 bits) --> 4 bytes --> DWORD --> Long
    $object->{'size'} = ReadLong();
  }
    
  # OBJECT DATA
  if ($object->{'type'} == 1) {
    # BYTE - byte
    $object->{'value'} = ReadByte();
  }
  elsif ($object->{'type'} == 2) {
    # DWORD Integer
    $object->{'value'} = ReadLong();
  }
  elsif ($object->{'type'} == 3) {
    # BOOLEAN - Byte 7 of the info byte, which coincides with the arrayflag
    $object->{'value'} = $object->{'arrayflag'} / 128;
  }
  elsif ($object->{'type'} == 4) {
    # FLOAT
    $object->{'value'} = ReadFloat();
  }
  elsif ($object->{'type'} == 5) {
    # INDEX - Objectproperty
    $object->{'value'} = ReadIndex();
    
    if ($object->{'value'} < 0) {
      my $import_id = ($object->{'value'} + 1)*-1;
      $object->{'value'} .= " (" . $imports[$import_id]->{'_Package'} . "." . $imports[$import_id]->{'_Name'} . ")";
    }
    else {
      my $export_id = $object->{'value'} - 1;
      $object->{'value'} .= " (" . $exports[$export_id]->{'_Class'} . "." . $exports[$export_id]->{'_Name'} . ")";
    }
  }
  elsif ($object->{'type'} == 6) {
    # INDEX - Nameproperty
    $object->{'value'} = ReadIndex();
    $object->{'value'} .= " (" . getName($object->{'value'}) . ")";
  }
  elsif ($object->{'type'} == 7) {
    # NAME - String
    $object->{'value'} = ReadString();
  }
  elsif ($object->{'type'} == 10) {
    # Struct name, followed by values
    if (lc($object->{'structname'}) eq "pointregion") {
      # INDEX zone, DWORD ileaf, BYTE zonenumber
      my $zone = ReadIndex();
      my $ileaf = ReadLong();
      my $zonenumber = ReadByte();
      
      $object->{'value'} = "(Zone=$zone; ileaf=$ileaf; zonenumber=$zonenumber)";
    }
    elsif (lc($object->{'structname'}) eq "vector") {
      my $x = ReadFloat();
      my $y = ReadFloat();
      my $z = ReadFloat();
      
      $object->{'value'} = "(X=$x; Y=$y; Z=$z)";
    }
    elsif (lc($object->{'structname'}) eq "color") {
      my $r = ReadByte();
      my $g = ReadByte();
      my $b = ReadByte();
      my $a = ReadByte();
      
      $object->{'value'} = "(R=$r; G=$g; B=$b; A=$a)";
    }
    elsif (lc($object->{'structname'}) eq "rotator") {
      my $pitch = ReadLong();
      my $yaw = ReadLong();
      my $roll = ReadLong();
      
      $object->{'value'} = "(Pitch=$pitch; Yaw=$yaw; Roll=$roll)";
    }
    elsif (lc($object->{'structname'}) eq "scale") {
      my $x = ReadFloat();
      my $y = ReadFloat();
      my $z = ReadFloat();
      my $sheerrate = ReadLong();
      my $sheeraxis = ReadByte();
      
      $object->{'value'} = "(X=$x; Y=$y; Z=$z; Sheerrate=$sheerrate; Sheeraxis=$sheeraxis)";
    }
    else {
      die("DIE: Unknown struct: '" . $object->{'structname'} . "'\n");
    }
  }
  elsif ($object->{'type'} == 13) {
    # string;
    $object->{'value'} = ReadString();
  }
  else {
    warn("Unknown object type: ". $object->{'type'} . " at " . $object->{'offset'} . "\n");
    read(MAP, $char, $object->{'size'});
    $object->{'value'} = $char;
  }
  
  return $object;
}

sub ReadByte {
  my $string;
  read(MAP, $string, 1);
  $string = vec($string, 0, 8);
  return ($string & 0xFF);
}

sub ReadQWord {
  my $string;
  my $char = read(MAP, $string, 8);
  return unpack("B64", $string);
}

sub ReadDWord {
  my $string = shift;
  return ReadLong($string);
}

sub ReadWord {
  my $string = shift;
  return ReadShort($string);
}

sub ReadLong {
  my $string;
  my $char = read(MAP, $string, 4);
  return unpack("l", $string);
}

sub ReadShort {
  my $string;
  read(MAP, $string, 2);
  return unpack("S", $string);
}

sub ReadFloat {
  my $string;
  read(MAP, $string, 4);
  return sprintf("%.2f", unpack("f", $string));
}

=head1 NAME

  utdep.pl - retrieve the dependencies of a unreal tournament package.
  Version: 0.3.0

=head1 DESCRIPTION

  This script will extract the headers, index and import table from an unreal
  tournament package (usually a map package) and return a list of packages on
  which the package depends.

=head1 USAGE

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

=head1 CHANGELOG

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

=head1 BUGS

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

=head1 ACKNOWLEDGEMENTS

  With writing this script I had a lot of help at the Beyond Unreal forums, 
  especially from from Just**Me who gave me an example script to work from.
  You can find the topic with the example script here:
  http://forums.beyondunreal.com/showthread.php?p=2285785

  Other helpfull pages at UnrealWiki:
  http://wiki.beyondunreal.com/wiki/Package_File_Format
  http://wiki.beyondunreal.com/wiki/Package_File_Format/Data_Details

  Thanks to NogginBasher & BlackWolf for testing the script.

=head1 COPYRIGHTS & DISCLAIMER

  You have the right to copy this script, you may also redistribute, adapt and
  rewrite it if you want. I can't be held responsible for any damage of this
  script did to your system, especially not when they are redistributed or
  addapted by other persons. Use the script at your own risk.

=head1 AUTHOR

  Christiaan ter Veen [mail at rork dot nl]
  http://www.rork.nl/
