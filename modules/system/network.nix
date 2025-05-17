{
  config,
  lib,
  phoenix-lib,
  ...
}:
let
  cfg = config.phoenix.system.network;
in
{
  options.phoenix.system.network = {
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
        type = lib.types.listOf lib.types.str;
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

  config = {
    networking.networkmanager.enable = true;
    users.users = lib.genAttrs config.phoenix.identity.usernames (name: {
      extraGroups = [ "networkmanager" ];
    });

    networking.firewall = lib.mkIf cfg.firewall.enable (
      let
        TCPPorts = phoenix-lib.ports.groupPortsAndPortRanges cfg.firewall.allowedTCPPorts;
        UDPPorts = phoenix-lib.ports.groupPortsAndPortRanges cfg.firewall.allowedUDPPorts;
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
