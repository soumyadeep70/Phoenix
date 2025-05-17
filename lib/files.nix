{ lib }:
{
  getFiles =
    path:
    let
      exploreDir =
        dirPath:
        builtins.filter (item: item != null) (
          lib.attrsets.mapAttrsToList (name: type: if type == "regular" then "${dirPath}/${name}" else null) (
            builtins.readDir dirPath
          )
        );
    in
    exploreDir (builtins.toString path);

  getFilesRecursive =
    path:
    let
      exploreDirRecursive =
        dirPath:
        lib.lists.flatten (
          lib.attrsets.mapAttrsToList (
            name: type:
            let
              fullPath = "${dirPath}/${name}";
            in
            if type == "regular" then
              [ fullPath ]
            else if type == "directory" then
              exploreDirRecursive fullPath
            else
              [ ]
          ) (builtins.readDir dirPath)
        );
    in
    exploreDirRecursive (builtins.toString path);

  getDirs =
    path:
    builtins.attrNames (
      lib.attrsets.filterAttrs (name: type: type == "directory") (builtins.readDir path)
    );
}
