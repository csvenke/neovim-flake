#!/usr/bin/env bash

name="world"
printf '%s\n' $name

greet() {
  printf '%s\n' "hello $1"
}

greet "$name"
