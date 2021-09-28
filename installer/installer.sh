#!/bin/bash

usage(){
  echo "Uso clicreate.sh [install|uninstall] [stable|develop|version]"
  echo "Environment:"
	echo "PREFIX=$PREFIX"
	echo "REPO_HOME=$REPO_HOME"
	echo "REPO_NAME=$REPO_NAME"
	exit 1
}

# Isso precisa ser mais inteligente para cada sistema operacional host?
if [ -z "$PREFIX" ] ; then
	PREFIX="/usr/local"
fi


if [ -z "$REPO_NAME" ] ; then
	REPO_NAME="clicreate"
fi

if [ -z "$REPO_HOME" ] ; then
	REPO_HOME="https://github.com/sidinei-silva/clicreate.git"
fi

EXEC_PREFIX="$PREFIX"
BINDIR="$EXEC_PREFIX/bin"
DATAROOTDIR="$PREFIX/share"
DOCDIR="$DATAROOTDIR/doc/clicreate"

EXEC_FILES="cli-create"
SCRIPT_FILES="cli-create-create clicreate-common clicreate-shFlags"
HOOK_FILES="$REPO_NAME/hooks/*"


echo "### cli-create installer ###"

case "$1" in
uninstall)
	echo "Uninstalling cli-create from $PREFIX"
	if [ -d "$BINDIR" ] ; then
		for script_file in $SCRIPT_FILES $EXEC_FILES ; do
			echo "rm -vf $BINDIR/$script_file"
			rm -vf "$BINDIR/$script_file"
		done
		rm -rf "$DOCDIR"
	else
		echo "The '$BINDIR' directory was not found."
	fi
	exit
	;; 
install)
  if [ -z $2 ]; then
		usage
		exit
	fi

  echo "🚀 Installing cli-create to $BINDIR"

  if [ -d "$REPO_NAME" -a -d "$REPO_NAME/.git" ] ; then
		echo "Using existing repo: $REPO_NAME"
	else
		echo "Cloning repo from GitHub to $REPO_NAME"
		git clone "$REPO_HOME" "$REPO_NAME"
	fi

  cd "$REPO_NAME"
  echo "cd $REPO_NAME"
	git pull
  echo "git pull"
	cd "$OLDPWD"
  echo "cd $OLDPWD"

  case "$2" in
	stable)
		cd "$REPO_NAME"
    echo "cd $REPO_NAME"
		git checkout master
		echo "git checkout master"
		cd "$OLDPWD"
		echo "cd $OLDPWD"
		;;
	develop)
		cd "$REPO_NAME"
    echo "cd $REPO_NAME"
		git checkout develop
		echo "git checkout develop"
		cd "$OLDPWD"
		echo "cd $OLDPWD"
		;;
	version)
    cd "$REPO_NAME"
    echo "cd $REPO_NAME"
		git checkout tags/$3
		echo "git checkout tags/$3"
		cd "$OLDPWD"
		echo "cd $OLDPWD"
		;;		
	*)
		usage
		exit
		;;
	esac
  echo "Instalando bin"
  install -v -d -m 0755 "$PREFIX/bin"
  echo "Instalando hooks"
	install -v -d -m 0755 "$DOCDIR/hooks"
  for exec_file in $EXEC_FILES ; do
    echo "Instalando execfile"
		install -v -m 0755 "$REPO_NAME/$exec_file" "$BINDIR"
	done
	for script_file in $SCRIPT_FILES ; do
    echo "Instalando script_file"
		install -v -m 0644 "$REPO_NAME/$script_file" "$BINDIR"
	done
	for hook_file in $HOOK_FILES ; do
    echo "Instalando hook_file"
		install -v -m 0644 "$hook_file"  "$DOCDIR/hooks"
	done
	exit
	;;
help)
  usage
  exit
  ;;
*)
  usage
  exit
  ;;
esac
