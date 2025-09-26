#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq

set -euo pipefail

# https://stackoverflow.com/a/246128
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

pkgsRepo=https://github.com/nixos/nixpkgs
darwinRepo=https://github.com/lnl7/nix-darwin
pkgsBranch=nixpkgs-25.05-darwin
darwinBranch=nix-darwin-25.05
pkgsFile=$SCRIPT_DIR/pinned-nixpkgs.json
darwinFile=$SCRIPT_DIR/pinned-nixpkgs-darwin.json

defaultPkgsRev=$(git ls-remote "$pkgsRepo" refs/heads/"$pkgsBranch" | cut -f1)
defaultDarwinRev=$(git ls-remote "$darwinRepo" refs/heads/"$darwinBranch" | cut -f1)
revPkgs=${1:-$defaultPkgsRev}
revDarwin=${1:-$defaultDarwinRev}
sha256Pkgs=$(nix-prefetch-url --unpack "$pkgsRepo/archive/$revPkgs.tar.gz" --name source)
sha256Darwin=$(nix-prefetch-url --unpack "$darwinRepo/archive/$revDarwin.tar.gz" --name source)

jq -n --arg rev "$revPkgs" --arg sha256 "$sha256Pkgs" '$ARGS.named' | tee /dev/stderr > $pkgsFile
jq -n --arg rev "$revDarwin" --arg sha256 "$sha256Darwin" '$ARGS.named' | tee /dev/stderr > $darwinFile