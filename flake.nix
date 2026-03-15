{
  description = "nazozokc's Neovim configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, ... }:
        let
          # このリポジトリ自体を Nix store にコピーするパッケージ
          nvimConfig = pkgs.stdenv.mkDerivation {
            pname = "nazozokc-nvim-config";
            version = "0.1.0";
            src = ./.;
            installPhase = ''
              mkdir -p $out
              cp -r . $out/
            '';
          };

          # lazy.nvim を Nix store に固定（オフライン初回起動用）
          lazyNvim = pkgs.fetchFromGitHub {
            owner = "folke";
            repo = "lazy.nvim";
            # lazy-lock.json の commit に合わせる
            rev = "306a05526ada86a7b30af95c5cc81ffba93fef97";
            # 初回は空文字で nix build して表示される hash を貼る
            hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };

          # NVIM_APPNAME で隔離して起動する wrapped neovim
          # nix run github:nazozokc/nazozokc.nvim.config で使える
          nvim-nazozokc = pkgs.writeShellApplication {
            name = "nvim";
            runtimeInputs = [ pkgs.neovim ];
            text = ''
              export NVIM_APPNAME="nvim-nazozokc"
              CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/nvim-nazozokc"
              DATA_DIR="''${XDG_DATA_HOME:-$HOME/.local/share}/nvim-nazozokc"
              LAZY_DIR="$DATA_DIR/lazy/lazy.nvim"

              # 初回だけ config を展開する
              if [ ! -d "$CONFIG_DIR" ]; then
                echo "[nazozokc.nvim] Initializing config at $CONFIG_DIR ..."
                mkdir -p "$CONFIG_DIR"
                cp -r ${nvimConfig}/. "$CONFIG_DIR/"
                chmod -R u+w "$CONFIG_DIR"
              fi

              # lazy.nvim が未インストールなら Nix store から持ってくる
              if [ ! -d "$LAZY_DIR" ]; then
                echo "[nazozokc.nvim] Bootstrapping lazy.nvim ..."
                mkdir -p "$(dirname "$LAZY_DIR")"
                cp -r ${lazyNvim} "$LAZY_DIR"
                chmod -R u+w "$LAZY_DIR"
              fi

              exec neovim "$@"
            '';
          };

        in
        {
          packages = {
            # nix build → result/bin/nvim
            default = nvim-nazozokc;

            # nix build .#config → config ファイル一式
            config = nvimConfig;
          };

          apps.default = {
            type = "app";
            program = "${nvim-nazozokc}/bin/nvim";
          };

          # nix develop → LSP / formatter が揃った開発シェル
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              neovim

              # LSP
              lua-language-server
              nixd
              nodePackages.typescript-language-server

              # Formatter
              stylua
              nixfmt-rfc-style
              nodePackages.prettier
            ];

            shellHook = ''
              echo "nazozokc.nvim devShell"
              echo "  neovim : $(nvim --version | head -1)"
              echo "  lua-ls : $(lua-language-server --version 2>/dev/null || echo 'ok')"
            '';
          };
        };
    };
}
