{ stdenv, fetchurl, cups_filters, udev, ghostscript, groff, vim, cups }:

let 
  sourceInfo = rec {
    baseName="foo2zjs";
    version="20150803";
    name="${baseName}-${version}";
    url="http://www.loegria.net/mirrors/foo2zjs/${name}.tar.gz";
    sha256="12qf014yc40cw0iik9whwg5xh55vl7zjfxlfyh8wa3p743yhk9bb";
  };
  
		  
in stdenv.mkDerivation {
  src = fetchurl {
    inherit (sourceInfo) url sha256;
  };

  inherit (sourceInfo) name version;

  buildInputs = [cups_filters ghostscript groff vim];

  phases = ["unpackPhase" "patchPhase" "buildPhase" "installPhase"];
  # phaseNames = ["doPatch" "fixHardcodedPaths" "doMakeDirs" "doMakeInstall" "deployGetWeb"];

  patches = [ ./hplj1000_patch.diff ./hplj10xx.rules_patch.diff ];

  postPatch = ''
    touch all-test
    sed -e "/BASENAME=/iPATH=$out/bin:$PATH" -i *-wrapper *-wrapper.in
    sed -e "s@PREFIX=/usr@PREFIX=$out@" -i *-wrapper{,.in}
    sed -e "s@/usr/share@$out/share@" -i hplj10xx_gui.tcl
    sed -e "s@\[.*-x.*/usr/bin/logger.*\]@type logger >/dev/null 2>\&1@" -i *wrapper{,.in}
    sed -e '/install-usermap/d' -i Makefile
    sed -e "s@/etc/hotplug/usb@$out&@" -i *rules*
    sed -e "s@/usr@$out@g" -i hplj1020.desktop
    sed -e "/PRINTERID=/s@=.*@=$out/bin/usb_printerid@" -i hplj1000
    sed -e "s@USB_BACKEND=/usr/lib/cups/backend/usb@USB_BACKEND=${cups}/lib/cups/backend/usb@" -i hplj1000
    sed -e "s@FOO2ZJS_DATADIR=/usr/share@FOO2ZJS_DATADIR=$out/share@" -i hplj1000
    '';
   
  makeFlags = [
      ''PREFIX=$(out)''
      ''APPL=$(out)/share/applications''
      ''PIXMAPS=$(out)/share/pixmaps''
      ''UDEVBIN=$(out)/bin''
      ''UDEVDIR=$(out)/etc/udev/rules.d''
      ''UDEVD=${udev}/sbin/udevd''
      ''LIBUDEVDIR=$(out)/lib/udev/rules.d''
      ''USBDIR=$(out)/etc/hotplug/usb''
      ''FOODB=$(out)/share/foomatic/db/source''
      ''MODEL=$(out)/share/cups/model''
  ];

  installFlags = [ "install-hotplug" ];

  copy_firmwares = map fetchurl 
                   [ { url = http://foo2zjs.rkkda.com/firmware/sihp1018.tar.gz; sha256 = "10pc60cg0r5api9964al3a8pqnlsfy2jdxc74fca28crbjmsh90w"; }
		     { url = http://foo2zjs.rkkda.com/firmware/sihp1000.tar.gz; sha256 = "1xjm75ahgwx4k35ysamxlsz0h1k1inxsfwc97i79lx79jjgsr931"; }
                     { url = http://foo2zjs.rkkda.com/firmware/sihp1005.tar.gz; sha256 = "1cz7riaavrkh58g9zfjin2lm3cnwjl2m595qqd52g2lr9mhspmj2"; }
		     { url = http://foo2zjs.rkkda.com/firmware/sihp1020.tar.gz; sha256 = "0rpri6pdyjx86gsh8jsh6304k55w3dpv06xpmv7v6bacf336aipc"; }
		     { url = http://foo2zjs.rkkda.com/firmware/sihpP1005.tar.gz; sha256 = "183jx1fvzq509glb1hyby0kb3q0ayls7h39jiai9k2s119aln3m2"; }
		     { url = http://foo2zjs.rkkda.com/firmware/sihpP1006.tar.gz; sha256 = "13ygbg71mxp3228k0c2lla07rs0kmfnzhplbn5wcbjn4dy9fdvxr"; }
		     { url = http://foo2zjs.rkkda.com/firmware/sihpP1505.tar.gz; sha256 = "12z5b4vbwchfrq4bwymwscdrl8j4zrc1hjp3ljlr7dpb05nr2017"; } ];


  preInstall = ''
    mkdir -pv $out/{etc/udev/rules.d,lib/udev/rules.d,etc/hotplug/usb}
    mkdir -pv $out/share/foomatic/db/source/{opt,printer,driver}
    mkdir -pv $out/share/cups/model
    mkdir -pv $out/share/{applications,pixmaps}
    for frm in $copy_firmwares; do cp $frm ./ && tar zxf $frm; done
  '';

  # postInstall = ''
  #   wrapProgram "$out/etc/hotplug/usb/hplj1018" --set FOO2ZJS_DATADIR "$out/share"
  # '';
    

  # deployGetWeb = a.fullDepEntry ''
  #   mkdir -pv "$out/bin"
  #   cp -v getweb arm2hpdl "$out/bin"
  # '' ["minInit"];
      
  meta = {
    description = "ZjStream printer drivers. This package tested only with HP Laser Jet 1018 with cups";
    maintainers = with stdenv.lib.maintainers;
    [
      raskin urkud "Alexander Lebedev <lebastr@gmail.com>"
    ];
    platforms = stdenv.lib.platforms.linux;
    license = stdenv.lib.licenses.gpl2Plus;
  };
}
