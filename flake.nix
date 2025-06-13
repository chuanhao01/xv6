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
      # Pulling lib into outputs
      inherit (nixpkgs) lib;
      # Use Python 3.12 from nixpkgs
      python = pkgs.python312;
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
            python
            uv
          ];

          env =
            {
              # Prevent uv from managing Python downloads
              UV_PYTHON_DOWNLOADS = "never";
              # Force uv to use nixpkgs Python interpreter
              UV_PYTHON = python.interpreter;
            }
            // lib.optionalAttrs pkgs.stdenv.isLinux {
              # Python libraries often load native shared objects using dlopen(3).
              # Setting LD_LIBRARY_PATH makes the dynamic library loader aware of libraries without using RPATH for lookup.
              LD_LIBRARY_PATH = lib.makeLibraryPath pkgs.pythonManylinuxPackages.manylinux1;
            };

          # Optional: set environment variables if your build system expects them
          shellHook = ''
            unset PYTHONPATH
            echo "Entering RISC-V cross-compilation dev shell."
          '';

        };
      };
    };
}
