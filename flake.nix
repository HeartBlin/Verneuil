{
  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    fluxgrow.url = "github:HeartBlin/FluxGrow";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.fluxgrow.mkFlake inputs ({ lib', ... }: {
    systems = [ "x86_64-linux" ];
    packages = { pkgs, ... }: lib'.inPackages ./packages pkgs;
    hydraJobs = { system, ... }: {
      own = inputs.self.packages;
      upstream = {
        lanzaboote = inputs.lanzaboote.packages.${system} or { };
        hjem = inputs.hjem.packages.${system} or { };
      };
    };
  });
}
