{
  description = "Stateless captcha telegram bot";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    let
      all = flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend poetry2nix.overlays.default;
          tg-captcha = pkgs.callPackage ./package.nix { };
        in {
          packages = {
            inherit tg-captcha;
            default = tg-captcha;
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = [ tg-captcha ];
            packages = [ pkgs.poetry ];
          };
        });
    in {
      nixosModules.tg-captcha = import ./module.nix;
      nixosModules.default = self.nixosModules.tg-captcha;

      overlays.tg-captcha = (final: prev: { tg-captcha = all.packages.${prev.system}.default; });
      overlays.default = self.overlays.tg-captcha;
    } // all;
}
