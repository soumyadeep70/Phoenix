{ lib }:
rec {
  extractPort =
    portStr:
    let
      match = builtins.match "^[[:space:]]*([1-9][0-9]{0,4})[[:space:]]*$" portStr;
      port = if match != null then lib.toInt (builtins.head match) else null;
    in
    if port != null && port < 65536 then port else null;

  extractPortRange =
    rangeStr:
    let
      ports = lib.splitString "-" rangeStr;
    in
    if (builtins.length ports) != 2 then
      null
    else
      let
        first = extractPort (builtins.head ports);
        second = extractPort (builtins.elemAt ports 1);
      in
      if first != null && second != null && first <= second then
        {
          from = first;
          to = second;
        }
      else
        null;

  groupPortsAndPortRanges =
    portList:
    let
      list = builtins.map (
        x:
        let
          port = extractPort x;
          portRange = extractPortRange x;
        in
        if port != null then
          port
        else if portRange != null then
          portRange
        else
          x
      ) portList;
      groups = lib.groupBy (
        x:
        if (builtins.typeOf x) == "int" then
          "port"
        else if (builtins.typeOf x) == "set" then
          "portRange"
        else
          "invalid"
      ) list;
    in
    if builtins.hasAttr "invalid" groups then
      throw "Invalid port(s) or port range(s) detected: ${lib.concatStringsSep ", " groups.invalid}"
    else
      {
        ports = if builtins.hasAttr "port" groups then groups.port else [ ];
        portRanges = if builtins.hasAttr "portRange" groups then groups.portRange else [ ];
      };
}
