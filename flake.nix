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

			perSystem = { pkgs, system, config, ... }: {
				packages = let
					pa11y-attrs = import ./. { inherit pkgs system; };
					# inherit (pa11y-attrs) pa11y;
				in rec {
					pa11y = pa11y-attrs.pa11y.override {
						PUPPETEER_SKIP_DOWNLOAD = true;
						nativeBuildInputs = [ pkgs.makeWrapper ];
						makeWrapperArgs = ["--set PUPPETEER_EXECUTABLE_PATH ${pkgs.chromedriver}/bin/chromedriver"];
						postFixup = ''
							wrapProgram $out/bin/pa11y --set PUPPETEER_EXECUTABLE_PATH ${pkgs.chromedriver}/bin/chromedriver
						'';
					};
					default = pa11y;

					chrome-chromedriver = pkgs.runCommand
						"chromedriver-chrome"
						{ nativeBuildInputs = [pkgs.makeWrapper]; }
						''
							mkdir -p $out/bin
							ln -s ${pkgs.chromedriver}/bin/chromedriver $out/bin/chrome
							ln -s ${pkgs.chromedriver}/bin/chromedriver $out/bin/.local-chromium
						'';
				};

				devshells.default = {
					packages = [
						pkgs.nodePackages.node2nix

						config.packages.pa11y
						config.packages.chrome-chromedriver
					];
				};
			};
		};
}
