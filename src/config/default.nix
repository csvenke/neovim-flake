{ pkgs }:

let
  inherit (builtins) readDir readFile toFile attrNames concatStringsSep filter;
  inherit (pkgs.lib) pipe strings lists;

  mkFile = name: path:
    (toFile name (readFile path));

  mkFiles = suffix: directory:
    pipe directory [
      readDir
      attrNames
      (filter (name: strings.hasSuffix suffix name))
      (map (name: mkFile name "${directory}/${name}"))
    ];

  mkVimRc = files:
    pipe files [
      lists.flatten
      (map (file: "luafile ${file}"))
      (concatStringsSep "\n")
    ];
in

mkVimRc [
  (mkFiles ".lua" ./core)
  (mkFiles ".lua" ./plugins)
]
