{ ... }: {
  programs.git = {
    enable = true;
    userName = "Deshun Cai";
    userEmail = "unusep@gmail.com";
    ignores = [ "**/.claude/settings.local.json" ];
  };
}
