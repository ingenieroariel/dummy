{ stdenv, lib, haskellPackages, haskell, removeReferencesTo, installShellFiles }:

let
  # Since pandoc 3.0 the pandoc binary resides in the pandoc-cli package.
  static = haskell.lib.compose.justStaticExecutables haskellPackages.pandoc-cli;

in
  (haskell.lib.compose.overrideCabal (drv: {
    # pandoc-cli's pandoc executable report the libraries version via --version, match that,
    inherit (static.scope.pandoc) version;
    # but prevent haskellPackages.mkDerivation from recomputing the src tarball based on that.
    inherit (static) src;
    # Make it possible to recover the cli version if necessary.
    passthru = drv.passthru or {} // {
      cliVersion = static.version;
    };

    configureFlags = drv.configureFlags or [] ++ ["-fembed_data_files"];
    buildDepends = drv.buildDepends or [] ++ [haskellPackages.file-embed];
    buildTools = (drv.buildTools or []) ++ [
      removeReferencesTo
      installShellFiles
    ];

    # Normally, the static linked executable shouldn't refer to any library or the compiler.
    # This is not always the case when the dependency has Paths_* module generated by Cabal,
    # where bindir, datadir, and libdir contain the path to the library, and thus make the
    # executable indirectly refer to GHC. However, most Haskell programs only use Paths_*.version for
    # getting the version at runtime, so it's safe to remove the references to them.
    # This is true so far for pandoc-types and warp.
    # For details see: https://github.com/NixOS/nixpkgs/issues/34376
    postInstall = drv.postInstall or "" + ''
      remove-references-to \
        -t ${haskellPackages.pandoc-types} \
        $out/bin/pandoc
      remove-references-to \
        -t ${haskellPackages.warp} \
        $out/bin/pandoc
      remove-references-to \
        -t ${haskellPackages.pandoc_3_1_11} \
        $out/bin/pandoc
    '' + lib.optionalString (stdenv.buildPlatform == stdenv.hostPlatform) ''
      mkdir -p $out/share/bash-completion/completions
      $out/bin/pandoc --bash-completion > $out/share/bash-completion/completions/pandoc
    '' + ''
      installManPage man/*
    '';
  }) static).overrideAttrs (drv: {
    # These libraries are still referenced, because they generate
    # a `Paths_*` module for figuring out their version.
    # The `Paths_*` module is generated by Cabal, and contains the
    # version, but also paths to e.g. the data directories, which
    # lead to a transitive runtime dependency on the whole GHC distribution.
    # This should ideally be fixed in haskellPackages (or even Cabal),
    # but a minimal pandoc is important enough to patch it manually.
    disallowedReferences = [ haskellPackages.pandoc-types haskellPackages.warp haskellPackages.pandoc_3_1_11 ];
  })