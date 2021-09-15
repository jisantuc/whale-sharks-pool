with import <nixpkgs> {};

{ pkgs ? import <nixpkgs> {} }:
	pkgs.mkShell {
	  name = "whale-sharks-pool";
	  buildInputs = [ pkgs.spago
                          pkgs.purescript
                          pkgs.nodejs-14_x ];
}
