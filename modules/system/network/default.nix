{ config, lib, ... }:

let
  cfg = config.phoenix.system.network;

  cvtToPort =
    portStr:
    let
      match = builtins.match "^[[:space:]]*([1-9][0-9]{0,4})[[:space:]]*$" portStr;
      port = if match != null then lib.toInt (builtins.head match) else null;
    in
    if port != null && port < 65536 then port else null;

  cvtToPortRange =
    rangeStr:
    let
      ports = lib.splitString "-" rangeStr;
    in
    if (builtins.length ports) != 2 then
      null
    else
      let
        first = cvtToPort (builtins.head ports);
        second = cvtToPort (builtins.elemAt ports 1);
      in
      if first != null && second != null && first <= second then
        {
          from = first;
          to = second;
        }
      else
        null;

  groupPorts =
    portList:
    let
      list = builtins.map (
        x:
        let
          port = cvtToPort x;
          portRange = cvtToPortRange x;
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
in
{
  options.phoenix.system.network = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable networking";
      example = true;
    };
    firewall = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable firewall";
        example = false;
      };
      allowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Specify ports to open for incoming TCP traffic";
        example = [
          "80"
          "443"
          "1000-2000"
          "1-100"
        ];
      };
      allowedUDPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.int;
        default = [ ];
        description = "Specify ports to open for incoming UDP traffic";
        example = [
          "80"
          "443"
          "1000-2000"
          "1-100"
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;
    users.users = lib.genAttrs config.phoenix.user.usernames (name: {
      extraGroups = [ "networkmanager" ];
    });

    networking.firewall = lib.mkIf cfg.firewall.enable (
      let
        TCPPorts = groupPorts cfg.firewall.allowedTCPPorts;
        UDPPorts = groupPorts cfg.firewall.allowedUDPPorts;
      in
      {
        enable = true;
        allowedTCPPorts = TCPPorts.ports;
        allowedTCPPortRanges = TCPPorts.portRanges;
        allowedUDPPorts = UDPPorts.ports;
        allowedUDPPortRanges = UDPPorts.portRanges;
      }
    );
  };
}
