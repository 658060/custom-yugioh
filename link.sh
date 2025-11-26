#!/usr/bin/env bash
# this script symlinks the databases, scripts, and card arts 
# to all installed versions of edopro for the current user.

# if you are not on nixos you may need to change the directory
# `~/.local/share/edopro/*/` below to wherever you manually 
# installed edopro.

cd $(dirname $0)

for dir in ~/.local/share/edopro/*/
do
  # symlink card databases
  for db in *.cdb
  do
    ln -sf $(pwd)/$db ${dir}expansions/$db
  done

  if [[ ! -d ${dir}/script/user-custom ]] then
    mkdir ${dir}/script/user-custom
  fi
  #symlink card scripts
  for scr in ./script/*.lua
  do
    id=${scr##*/}
    ln -sf $(pwd)/$scr ${dir}script/user-custom/$id
  done

  # symlink pictures
  for pic in ./img/*.png
  do
    id=${pic##*/}
    ln -sf $(pwd)/$pic ${dir}pics/$id
  done
  for field in ./img/field/*.png
  do
    id=${field##*/}
    ln -sf $(pwd)/$field ${dir}pics/field/$id
  done
done
