#!/bin/bash
set -e

GO_VERSION="1.8.1"
TARGETS="darwin-amd64 freebsd-386 freebsd-amd64 linux-386 linux-armv6l linux-ppc64le"
WIN_TARGETS="windows-386 windows-amd64"
BASE_URL="https://storage.googleapis.com/golang"

mkdir -p $GOPATH/src &&
mkdir -p $GOROOT &&
mkdir -p $DOWNLOADS &&

yum install -y git
yum install -y unzip

# Setup linux-amd64 as the default package
DEFAULT_PKG="go$GO_VERSION.linux-amd64.tar.gz"
curl -o "$DOWNLOADS/$DEFAULT_PKG" "$BASE_URL/$DEFAULT_PKG"
tar xz -C "$TOOLS" -f "$DOWNLOADS/$DEFAULT_PKG"

# Download all other targets and extract the cross-compiled std pkg.
for TARGET in $TARGETS
do
  DIR=$(echo $TARGET | sed "s/-/_/")
  mkdir "$DOWNLOADS/$DIR"

  FILE="go$GO_VERSION.$TARGET.tar.gz"
  URL="$BASE_URL/$FILE"
  echo "Downloading $URL"
  curl -o "$DOWNLOADS/$FILE" $URL
  tar xz -C "$DOWNLOADS/$DIR" -f "$DOWNLOADS/$FILE"

  PDIR=$DIR
  if [ $DIR = "linux_armv6l" ]
  then
    PDIR="linux_arm"
  fi

  mv "$DOWNLOADS/$DIR/go/pkg/$PDIR" "$GOROOT/pkg"
done

for TARGET in $WIN_TARGETS
do
  DIR=$(echo $TARGET | sed "s/-/_/")
  mkdir "$DOWNLOADS/$DIR"

  FILE="go$GO_VERSION.$TARGET.zip"
  URL="$BASE_URL/$FILE"
  echo "Downloading $URL"
  curl -o "$DOWNLOADS/$FILE" $URL
  unzip "$DOWNLOADS/$FILE" -d "$DOWNLOADS/$DIR/"

  mv "$DOWNLOADS/$DIR/go/pkg/$DIR" "$GOROOT/pkg"
done

rm -rf $DOWNLOADS

yum remove unzip -y
yum clean all

ls -l $GOROOT/pkg
go version
