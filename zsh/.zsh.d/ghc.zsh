GHCDIR=$HOME/bin

# List available GHC versions
ghc-list-available() {
  echo "Available versions:"
  for ver in $GHCDIR/ghc-*; do
    echo "  ${ver##$GHCDIR/ghc-}"
  done
}

# Switch to a specific GHC version
ghc-switch() {
  if [ -z "$1" ]; then
    echo "USAGE: ghc-switch VERSION"
    ghc-list-available
    return 1
  fi


  VER_PATH="$HOME/bin/ghc-$1"
  if [ -d "$VER_PATH" ]; then
    export path=($VER_PATH/bin ${(@)path:#*ghc*})
    export GHC_VERSION=$1
    ghc --version
  else
    echo "GHC $1 isn't available"
    ghc-list-available
    return 1
  fi
}

# Install a new version of GHC
ghc-install() {
  if [ -z "$1" ]; then
    echo "USAGE: ghc-install VERSION"
    echo "Already installed:"
    ghc-list-available
    return 1
  fi

  VERSION=$1
  FILE=ghc-$VERSION-x86_64-apple-darwin.tar.xz
  DIR=`pwd`

  cd /tmp \
    && wget https://www.haskell.org/ghc/dist/$VERSION/$FILE \
    && tar xf $FILE \
    && cd ghc-$VERSION \
    && ./configure --prefix=$GHCDIR/ghc-$VERSION \
    && make install \
    && ghc-switch $VERSION \
    && cd $DIR \
    || (echo "Failed while installing GHC $VERSION" && cd $DIR && return 1)

}

# Cycle GHC versions
g() {
  case $GHC_VERSION in
    7.8.4)
      ghc-switch 7.10.2
      ;;
    *)
      ghc-switch 7.8.4
      ;;
  esac
}

# Append to the prompt where helpful
ghc_prompt_string() {
  [ -n "$GHC_VERSION" ] && echo "[$GHC_VERSION]"
}

export RPS1='$(ghc_prompt_string)'$RPS1
export PATH="$PATH:$HOME/.cabal/bin"