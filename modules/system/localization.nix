{
  config,
  lib,
  ...
}:
let
  cfg = config.phoenix.system.localization;
in
{
  options.phoenix.system.localization = {
    locale = lib.mkOption {
      type = lib.types.strMatching "^[a-z]{2}_[A-Z]{2}\.UTF-8$";
      default = "en_US.UTF-8";
      description = "Define the locale";
      example = "bn_IN.UTF-8";
    };
    timeZone = lib.mkOption {
      type = lib.types.strMatching "^[A-Za-z]+(/[A-Za-z_]+)+$";
      default = "Asia/Kolkata";
      description = "Set the timezone";
      example = "America/Chicago";
    };
  };

  config = {
    time.timeZone = cfg.timeZone;

    i18n.defaultLocale = cfg.locale;
    i18n.extraLocaleSettings = {
      LC_ADDRESS = cfg.locale;
      LC_IDENTIFICATION = cfg.locale;
      LC_MEASUREMENT = cfg.locale;
      LC_MONETARY = cfg.locale;
      LC_NAME = cfg.locale;
      LC_NUMERIC = cfg.locale;
      LC_PAPER = cfg.locale;
      LC_TELEPHONE = cfg.locale;
      LC_TIME = cfg.locale;
    };
  };
}
