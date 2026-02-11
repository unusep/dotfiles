{ ... }: {
  programs.claude-code = {
    enable = true;
    settings = {
      permissions = {
        allow = [ "WebSearch" ];
        defaultMode = "default";
      };
      enabledPlugins = {
        "typescript-lsp@claude-plugins-official" = true;
        "lua-lsp@claude-plugins-official" = true;
        "pyright-lsp@claude-plugins-official" = true;
      };
      promptSuggestionEnabled = false;
      attribution = {
        commit = "";
        pr = "";
      };
    };
  };
}
