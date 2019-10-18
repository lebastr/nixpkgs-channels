{ stdenv, fetchurl, pkgconfig, gtk2, gtkmm2, libjack2, alsaLib }:

stdenv.mkDerivation rec {
    name = "amsynth-${version}";
    version = "1.6.4";

    src = fetchurl {
      url = "https://github.com/amsynth/amsynth/releases/download/release-1.6.4/${name}.tar.bz2";
      sha256 = "07dp9dl38g9krjqxxh89l2z42z08yzrl57cx95b1l67xnxwjp5k3";
    };

    buildInputs = [ pkgconfig gtk2 gtkmm2 libjack2 alsaLib ];

    meta = with stdenv.lib; {
      homepage = http://amsynth.github.io/;
      description = "amsynth is an easy-to-use software synth with a classic subtractive synthesizer topology";
      license = licenses.gpl2;
      maintainers = [ maintainers.lebastr ];
      platforms = platforms.linux;
    };
}
