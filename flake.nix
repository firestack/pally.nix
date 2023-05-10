{
	description = "virtual environments";

	inputs.devshell.url = "github:numtide/devshell";
	inputs.flake-parts.url = "github:hercules-ci/flake-parts";

	outputs = inputs@{ self, flake-parts, devshell, nixpkgs }:
		flake-parts.lib.mkFlake { inherit inputs; } {
			imports = [
				devshell.flakeModule
			];

			systems = [
				"aarch64-darwin"
				"aarch64-linux"
				"i686-linux"
				"x86_64-darwin"
				"x86_64-linux"
			];

			perSystem = { pkgs, system, ... }: {
				packages = let
					pa11y-attrs = import ./. { inherit pkgs system; };
				in rec {
					inherit (pa11y-attrs) pa11y;
					default = pa11y;
				};

				devshells.default = { };
			};
		};
}
