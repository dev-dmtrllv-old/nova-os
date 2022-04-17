export TARGET="i686"
export PREFIX="$HOME/opt/cross"
export PATH="$PREFIX/bin:$PATH"

BINUTILS_VERSION="2.38"
GCC_VERSION="11.2.0"

SRC_DIR="$HOME/src"

SRC_BINUTILS="$HOME/src/binutils-$BINUTILS_VERSION"
SRC_GCC="$HOME/src/gcc-"$GCC_VERSION

TAR_BINUTILS="binutils-$BINUTILS_VERSION.tar.gz"
TAR_GCC="gcc-$GCC_VERSION.tar.gz"

BUILD_BINUTILS="$HOME/src/build-binutils-$BINUTILS_VERSION"
BUILD_GCC="$HOME/src/build-gcc-$GCC_VERSION"

BINUTILS_URL="https://ftp.gnu.org/gnu/binutils/binutils-$BINUTILS_VERSION.tar.gz"
GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz"


sudo apt install build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo libisl-dev nasm qemu-system-i386 -y

if [ ! -d "$SRC_DIR" ]; then
	mkdir $SRC_DIR
fi

cd $SRC_DIR

if [ ! -d $BUILD_BINUTILS ]; then
	if [ ! -d $SRC_BINUTILS ]; then
		if [ ! -f $TAR_BINUTILS ]; then
			wget $BINUTILS_URL
		fi
		tar -xf $TAR_BINUTILS
	fi

	mkdir -p $BUILD_BINUTILS

	cd $BUILD_BINUTILS
	
	../binutils-$BINUTILS_VERSION/configure --target="$TARGET-elf" --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
	
	make
	make install
fi

cd $SRC_DIR

if [ ! -d $BUILD_GCC ]; then
	if [ ! -d $SRC_GCC ]; then
		if [ ! -f $TAR_GCC ]; then
			wget $GCC_URL
		fi
		tar -xf $TAR_GCC
	fi

	mkdir -p $BUILD_GCC
	
	cd $BUILD_GCC
	
	../gcc-$GCC_VERSION/configure --target="$TARGET-elf" --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
	
	make all-gcc
	make all-target-libgcc
	
	make install-gcc
	make install-target-libgcc
fi

case `grep -F "$PREFIX/bin" "$HOME/.profile" >/dev/null; echo $?` in
  0)
    ;;
  1)
	echo "export PATH=\"$PREFIX/bin:\$PATH\""$'\r' >> "$HOME/.profile"
    ;;
  *)
    echo "error exporting to \$PATH!"
    ;;
esac

source $HOME/.profile
