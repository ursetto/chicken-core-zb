#!/bin/sh
# runtests.sh - run CHICKEN testsuite
#
# - Note: this needs a proper shell, so it will not work with plain mingw
#   (just the compiler and the Windows shell, without MSYS)

set -e
TEST_DIR=`pwd`
OS_NAME=`uname -s`
export DYLD_LIBRARY_PATH=${TEST_DIR}/..
export LD_LIBRARY_PATH=${TEST_DIR}/..
export LIBRARY_PATH=${TEST_DIR}/..:${LIBRARY_PATH}

mkdir -p test-repository

# copy files into test-repository (by hand to avoid calling `chicken-install'):

for x in setup-api.so setup-api.import.so setup-download.so \
      setup-download.import.so chicken.import.so lolevel.import.so \
      srfi-1.import.so srfi-4.import.so data-structures.import.so \
      ports.import.so files.import.so posix.import.so \
      srfi-13.import.so srfi-69.import.so extras.import.so \
      irregex.import.so srfi-14.import.so tcp.import.so \
      foreign.import.so scheme.import.so srfi-18.import.so \
      utils.import.so csi.import.so irregex.import.so types.db; do
  cp ../$x test-repository
done

"${TEST_DIR}/../chicken-install" -init test-repository export
CHICKEN_REPOSITORY=${TEST_DIR}/test-repository
CHICKEN=../chicken
ASMFLAGS=
FAST_OPTIONS="-O5 -d0 -b -disable-interrupts"

if test -n "$MSYSTEM"; then
    CHICKEN="..\\chicken.exe"
    ASMFLAGS=-Wa,-w
    # make compiled tests use proper library on Windows
    cp ../libchicken.dll .
fi

compile="../csc -compiler $CHICKEN -v -I.. -L.. -include-path .. -o a.out"
compile_s="../csc -s -compiler $CHICKEN -v -I.. -L.. -include-path .."
interpret="../csi -n -include-path .."

echo "======================================== compiler tests ..."
$compile compiler-tests.scm
./a.out

echo "======================================== compiler tests (lambda-lift) ..."
$compile compiler-tests-2.scm -lambda-lift
./a.out

echo "======================================== compiler tests (unboxing) ..."
$compile compiler-tests-3.scm -unsafe -unboxing
./a.out

echo "======================================== compiler inlining tests  ..."
$compile inlining-tests.scm -optimize-level 3
./a.out

echo "======================================== scrutiny tests ..."
$compile scrutiny-tests.scm -scrutinize -analyze-only -ignore-repository -types ../types.db 2>scrutiny.out

if test -n "$MSYSTEM"; then
    dos2unix scrutiny.out
fi

# this is sensitive to gensym-names, so make it optional
if test \! -f scrutiny.expected; then
    cp scrutiny.out scrutiny.expected
fi

diff -bu scrutiny.out scrutiny.expected

echo "======================================== runtime tests ..."
$interpret -s apply-test.scm
$compile test-gc-hooks.scm
./a.out

echo "======================================== library tests ..."
$interpret -s library-tests.scm
$interpret -s records-and-setters-test.scm
$compile records-and-setters-test.scm
./a.out

echo "======================================== dynamic-wind tests ..."
$interpret -s dwindtst.scm >dwindtst.out
diff -bu dwindtst.expected dwindtst.out
$compile dwindtst.scm
./a.out >dwindtst.out
diff -bu dwindtst.expected dwindtst.out
echo "*** Skipping \"feeley-dynwind\" for now ***"
# $interpret -s feeley-dynwind.scm

echo "======================================== syntax tests ..."
$interpret -s syntax-tests.scm

echo "======================================== syntax tests (compiled) ..."
$compile syntax-tests.scm
./a.out

echo "======================================== syntax tests (2, compiled) ..."
$compile syntax-tests-2.scm
./a.out

#echo "======================================== meta-syntax tests ..."
#$interpret -bnq meta-syntax-test.scm -e '(import foo)' -e '(bar 1 2)'
#$compile_s meta-syntax-test.scm -j foo
#$compile_s foo.import.scm
#$interpret -bnq -e '(require-library meta-syntax-test)' -e '(import foo)' -e '(bar 1 2)'

echo "======================================== reexport tests ..."
$interpret -bnq reexport-tests.scm
$compile reexport-tests.scm
./a.out
rm -f reexport-m*.import*
$compile_s reexport-m1.scm -J
$compile_s reexport-m1.import.scm
$interpret -s reexport-m2.scm
$compile reexport-m2.scm
./a.out

echo "======================================== compiler syntax tests ..."
$compile compiler-syntax-tests.scm
./a.out

echo "======================================== import library tests ..."
rm -f ../foo.import.* foo.import.*
$compile import-library-test1.scm -emit-import-library foo
$interpret -s import-library-test2.scm
$compile_s foo.import.scm -o foo.import.so
$interpret -s import-library-test2.scm
$compile import-library-test2.scm
./a.out

echo "======================================== syntax tests (matchable) ..."
$interpret matchable.scm -s match-test.scm

echo "======================================== syntax tests (loopy-loop) ..."
$interpret -s loopy-test.scm

echo "======================================== r4rstest ..."
echo "(expect mult-float-print-test to fail)"
$interpret -e '(set! ##sys#procedure->string (constantly "#<procedure>"))' \
  -i -s r4rstest.scm >r4rstest.log

if test -n "$MSYSTEM"; then
    # the windows runtime library prints flonums differently
    tail r4rstest.log
else
    diff -bu r4rstest.out r4rstest.log
fi

echo "======================================== syntax tests (r5rs_pitfalls) ..."
echo "(expect two failures)"
$interpret -i -s r5rs_pitfalls.scm

echo "======================================== module tests ..."
$interpret -include-path .. -s module-tests.scm
$interpret -include-path .. -s module-tests-2.scm

echo "======================================== module tests (compiled) ..."
$compile module-tests-compiled.scm
./a.out

echo "======================================== module tests (chained) ..."
rm -f m*.import.* test-chained-modules.so
$interpret -bnq test-chained-modules.scm
$compile_s test-chained-modules.scm -j m3
$compile_s m3.import.scm
$interpret -bn test-chained-modules.so
$interpret -bn test-chained-modules.so -e '(import m3) (s3)'

echo "======================================== module tests (ec) ..."
rm -f ec.so ec.import.*
$interpret -bqn ec.scm ec-tests.scm
$compile_s ec.scm -emit-import-library ec -o ec.so
$compile_s ec.import.scm -o ec.import.so 
$interpret -bnq ec.so ec-tests.scm
# $compile ec-tests.scm
# ./a.out        # takes ages to compile

echo "======================================== hash-table tests ..."
$interpret -s hash-table-tests.scm

echo "======================================== lolevel tests ..."
$interpret -s lolevel-tests.scm

echo "======================================== port tests ..."
$interpret -s port-tests.scm

echo "======================================== fixnum tests ..."
$compile fixnum-tests.scm
./a.out

echo "======================================== srfi-4 tests ..."
$interpret -s srfi-4-tests.scm

echo "======================================== srfi-18 tests ..."
$interpret -s srfi-18-tests.scm

echo "======================================== path tests ..."
$interpret -bnq path-tests.scm

echo "======================================== posix tests ..."
$compile posix-tests.scm
./a.out

echo "======================================== regular expression tests ..."
$interpret -bnq test-irregex.scm
$interpret -bnq test-glob.scm

echo "======================================== compiler/nursery stress test ..."
for s in 100000 120000 200000 250000 300000 350000 400000 450000 500000; do
    echo "  $s"
    ../chicken ../utils.scm -:s$s -output-file tmp.c -include-path .. 
done

echo "======================================== symbol-GC tests ..."
$compile symbolgc-tests.scm
./a.out -:w

echo "======================================== finalizer tests ..."
$interpret -s test-finalizers.scm

echo "======================================== finalizer tests (2) ..."
$compile test-finalizers-2.scm
./a.out

echo "======================================== locative stress test ..."
$compile locative-stress-test.scm
./a.out

echo "======================================== syntax-rules stress test ..."
time $interpret -bnq syntax-rule-stress-test.scm

echo "======================================== embedding (1) ..."
$compile embedded1.c
./a.out

echo "======================================== embedding (2) ..."
$compile -e embedded2.scm
./a.out

echo "======================================== private repository test ..."
mkdir -p tmp
$compile private-repository-test.scm -private-repository -o tmp/xxx
tmp/xxx $PWD/tmp
PATH=$PWD/tmp:$PATH xxx $PWD/tmp
# this may crash, if the PATH contains a non-matching libchicken.dll on Windows:
#PATH=$PATH:$PWD/tmp xxx $PWD/tmp

echo "======================================== timing compilation ..."
time $compile compiler.scm $FAST_OPTIONS -debug pb -v -C "$ASMFLAGS"
echo "executing ..."
time ./a.out

echo "======================================== running slatex ..."
$compile slatex.scm $FAST_OPTIONS
mkdir -p slatexdir
rm -f slatexdir/*
time ./a.out

echo "======================================== running floating-point benchmark ..."
echo "boxed:"
$compile fft.scm $FAST_OPTIONS
time ./a.out
echo "unboxed:"
$compile fft.scm $FAST_OPTIONS -D unboxed -debug oxi | tee fft.out
time ./a.out

echo "======================================== done."
