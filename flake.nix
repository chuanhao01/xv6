{
  description = "xv6";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOS/nixpkgs/063f43f2dbdef86376cc29ad646c45c46e93234c";
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux"; # Your native system
      pkgs = import nixpkgs {
        inherit system;
      };
      riscvPkgs = import nixpkgs {
        inherit system;
        crossSystem = {
          system = "riscv64-linux"; # The target system
        };
      };
    in
    {
      devShells.${system} = {
        default = riscvPkgs.mkShell {
          buildInputs = with riscvPkgs; [
            gcc
            binutils
            man-pages
          ];

          nativeBuildInputs = with pkgs; [
            cmake
            gnumake
            nasm
            binutils
            man-pages
            qemu
            gcc # We need original gcc?
          ];

          # Optional: set environment variables if your build system expects them
          shellHook = ''
            echo "Entering RISC-V cross-compilation dev shell."
          '';

        };
      };
    };
}
