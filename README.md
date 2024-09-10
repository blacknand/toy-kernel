# 32-bit x86 kernel for i686 microprocessor
A minimal sstem
## Setting up cross compiler
You need to setup a cross compiler so you can compile for the i686 (the target) from your actual machine (the host). Without a cross compiler, the compiler will assume that you are trying to run the code on your host operating system and can cause all kinds of problems. These two platforms will differ in operating system, CPU and executable format. The cross compiler will be using the GNU toolchain. This README assumes your are on a Linux machine.
### Which compiler version to use
I would recommend always using the newest `gcc` version. You can see your current compiler version with:
```
gcc --version
```
### Which binutils version to choose
Again I would recommend using the latest binutils. You can see your binutils linker version with:
```
ld --version
```
### Preparing for the build
The following are required to build `gcc`:
- A Unix-like enviroment (Windows users can use Cygwin or WSL)
- GCC
- G++ (if building a version of GCC >= 4.8.0)
- Make
- Bison
- Flex
- GMP
- MPFR
- MPC
- Texinfo
- ISL
### Downloading GCC and binutils source cpde
Create a suitable directory such as `$HOME/src` and download the source code into it.
- Download binutils via the [GNU FTP server](https://ftp.gnu.org/gnu/binutils/):
    ```wget https://ftp.gnu.org/gnu/binutils/```
- Download GCC via the [GNU FTP server](https://www.gnu.org/software/gcc/mirrors.html), make sure to choose the corresponding mirror site for your location. In my case:  
    ```https://mirrorservice.org/sites/sourceware.org/pub/gcc/```
### Building the compiler
We build a compiler toolset that is running on your host (your machine) that is able to turn source code into object files for the target machine (i686-elf).

You need to decide where to install your new compiler. It is a terrible idea to install it into any syste directories. You also need to decide if you are installing it globally (for all users) or just you. I would recommend just installing it for you., into `$HOME/opt/cross` We are also building out of the GCC source directory because it can cause the build to fail.
### Preperation
Execute the following:
```
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
```
This adds the installation prefix to the PATH of the current shell session (not permenant) which ensures that the compiler build is able to detect our new binutils once we have built them below. The prefix will configure the build process so that all files of the cross-compiler enviroment will end up in `$HOME/opt/cross`. 
### Binutils
Execute the following:
```
cd $HOME/src

mkdir build-binutils
cd build-binutils
../binutils-x.y.z/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install
```
This compiles the binutils including the assembler, disassembler and other sutff which is runnable on your system but handling code in the format specified by `$TARGET`. 
- `--disable-nls` tells binutils to not include native language support.
- `--with-sysroot` tells binutils to enable sysroot support in the cross-compiler by pointing it to a default empty directory.
### GCC
Once you have completed everything previously, you can now build `gcc`:
```
cd $HOME/src

# The $PREFIX/bin dir _must_ be in the PATH. We did that above.
which -- $TARGET-as || echo $TARGET-as is not in the PATH

mkdir build-gcc
cd build-gcc
../gcc-x.y.z/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc
```
We also build `libgcc`, a low-level support library that the compiler expects to be available at compile time. Linking against `libgcc` provides integer, floating point, decimal, stack unwinding (useful for exception handling) and other supporting functions.
- `--disable-nls` is the same as binutils above
- `--without-headers` tells `GCC` not to rely on any C library (standard or runtime) being present for the target
- `--enable-languages` tells `GCC` not to compile all the other langauge frontends it supports, but only C (a pure and holy language)
It will take a while to build the cross-compiler. 
### Error while building GCC
I got an error when trying to build GCC because it could not build `libgcc`. If this is the case, do:  
```  
rm -rf build-gcc  
rm -rf build-binutils  
```   
and then redo *carefully* the binutils step and then the `gcc` step.  
### Using the new compiler
Congratulations, you now have a new "naked" cross compiler. It does not have access to a C library nor C runtime yet, therefore you cannot use most of the standard includes or create runnable binaries. It is sufficient however, to compile this simple kernel. The toolset now resides in `$HOME/opt/cross`. You can now run the new compiler by invoking something along the lines of:  
```$HOME/opt/cross/bin/$TARGET-gcc --version```  
or  
```i686-elf-gcc --version```  
This compiler is *not* able to compile normal C programs. The cross-compiler will present errors when you try to `#include` any standard headers (execpt platform-independent headers, and those generated by the compiler itself). 

The C standard define two kinds of different executing enviroments - "freestanding" and "hosted". A kernel is "freestanding", everything you do in the user space is "hosted". A "freestanding" enviroment only needs to provide a subset of the C library.

To use your new compiler simply by invoking `$TARGET-gcc`, execute the following:  
```export PATH="$HOME/opt/cross/bin:$PATH"```  
again this is only temporary, adding only your new compiler to your `PATH` for this shell session. 
### The Book of C, Chapter 1: Verses 1-5
1. In the beginning, there was C, and C was with the programmer, and C was the light.
2. And lo, the language was pure, for it spake in simplicity and power.
3. Come unto C, all ye who are burdened by the errors of untyped code, and ye shall find rest in its syntax.
4. For C forgiveth, and in its functions, your logic shall be made whole.
5. Step into the light, O child of code, for C absolves you of your sins. In its pointers, ye shall find truth, and in its arrays, eternal structure.
