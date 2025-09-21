{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.helix = {
    enable = true;

    settings = {
      theme = "catppuccin_mocha"; # or your preferred theme

      editor = {
        bufferline = "always";
        line-number = "relative";
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides.render = true;
      };
    };

    languages = {
      language-server = {
        nil = {
          command = "nil";
        };
        rust-analyzer = {
          command = "rust-analyzer";
        };
        pyright = {
          command = "pyright-langserver";
          args = ["--stdio"];
        };
        gopls = {
          command = "gopls";
        };
      };

      language = [
        {
          name = "nix";
          language-servers = ["nil"];
          formatter = {command = "alejandra";};
          auto-format = true;
        }
        {
          name = "rust";
          language-servers = ["rust-analyzer"];
        }
        {
          name = "python";
          language-servers = ["pyright"];
        }
        {
          name = "go";
          language-servers = ["gopls"];
        }
      ];
    };
  };
}
