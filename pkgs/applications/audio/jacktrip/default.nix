{ stdenv, mkDerivation, fetchFromGitHub, libjack2, qtbase }:

mkDerivation rec {
  version = "4e27b";
  pname = "jacktrip";

  src = fetchFromGitHub {
    owner = "jacktrip";
    repo = "jacktrip";
    rev = "4e27b441e299c826e3feb408f1646170eab0132d";
    sha256 = "1n9jyjzm0q2ydisvdl4v2956l35anca9bmjhc2sb9yc7sg8m84ni";
  };

  buildInputs = [
    libjack2
    qtbase
  ];

  configurePhase = ''
    cd src
    qmake -spec linux-g++ jacktrip.pro
  '';

  installPhase = ''
     mkdir -p $prefix/bin
     cp jacktrip $prefix/bin
  '';

  meta = with stdenv.lib; {
    description = "A Qt application to control the JACK sound server daemon";
    homepage = http://qjackctl.sourceforge.net/;
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.goibhniu ];
    platforms = platforms.linux;
  };
}

