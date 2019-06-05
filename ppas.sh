#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking /home/qlixes/projects/appdesktop/lib/x86_64-linux/extico.res
OFS=$IFS
IFS="
"
/usr/bin/x86_64-w64-mingw32-windres --preprocessor=/usr/bin/cpp --include /usr/bin/ -O res -D FPC -o /home/qlixes/projects/appdesktop/lib/x86_64-linux/extico.res /home/qlixes/projects/appdesktop/extico.rc
if [ $? != 0 ]; then DoExitLink /home/qlixes/projects/appdesktop/lib/x86_64-linux/extico.res; fi
IFS=$OFS
echo Linking /home/qlixes/projects/appdesktop/lib/x86_64-linux/appdesktop.or
OFS=$IFS
IFS="
"
/usr/bin/fpcres -o /home/qlixes/projects/appdesktop/lib/x86_64-linux/appdesktop.or -a x86_64 -of elf  '@/home/qlixes/projects/appdesktop/lib/x86_64-linux/appdesktop.reslst'
if [ $? != 0 ]; then DoExitLink /home/qlixes/projects/appdesktop/lib/x86_64-linux/appdesktop.or; fi
IFS=$OFS
echo Linking appdesktop
OFS=$IFS
IFS="
"
/usr/bin/ld -b elf64-x86-64 -m elf_x86_64  --dynamic-linker=/lib64/ld-linux-x86-64.so.2    -L. -o appdesktop link.res
if [ $? != 0 ]; then DoExitLink appdesktop; fi
IFS=$OFS
echo Linking appdesktop
OFS=$IFS
IFS="
"
/usr/bin/objcopy --only-keep-debug appdesktop appdesktop.dbg
if [ $? != 0 ]; then DoExitLink appdesktop; fi
IFS=$OFS
echo Linking appdesktop
OFS=$IFS
IFS="
"
/usr/bin/objcopy --add-gnu-debuglink=appdesktop.dbg appdesktop
if [ $? != 0 ]; then DoExitLink appdesktop; fi
IFS=$OFS
echo Linking appdesktop
OFS=$IFS
IFS="
"
/usr/bin/strip --strip-unneeded appdesktop
if [ $? != 0 ]; then DoExitLink appdesktop; fi
IFS=$OFS
