{ stdenv, fetchurl, mesa, freetype, glib, libSM, libICE
, libXrender, libXext, libX11, zlib, fontconfig, makeWrapper }:

stdenv.mkDerivation (rec {
  name = "googleearth-7.1.7.2606";

  src = ../../../../binaries/google-earth-stable_current_amd64.deb;
  
  buildInputs = [
    makeWrapper
  ];

  ldLibraryPath = stdenv.lib.makeLibraryPath [
    stdenv.cc.cc
    glib
    libSM 
    libICE 
    mesa
    libXrender 
    freetype 
    libXext 
    libX11 
    zlib
    fontconfig
  ];

  phases = "unpackPhase installPhase";
  
  unpackPhase = ''
    ar vx $src
    xz -d data.tar.xz
    tar -xf data.tar
  '';
  
  installPhase =''
    mkdir -p $out/{opt/googleearth/,bin}
    cp -rv opt/google/earth/free/* $out/opt/googleearth
    patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/opt/googleearth/googleearth-bin

    wrapProgram $out/opt/googleearth/googleearth --prefix LD_LIBRARY_PATH : $ldLibraryPath \
        --prefix GOOGLEEARTH_DATA_PATH : $out/opt/googleearth

    ln -s $out/opt/googleearth/googleearth $out/bin/googleearth
  '';

  meta = {
    description = "A world sphere viewer";
    homepage = http://earth.google.com;
    license = stdenv.lib.licenses.unfree;
    maintainers = [ stdenv.lib.maintainers.viric ];
  };
})
