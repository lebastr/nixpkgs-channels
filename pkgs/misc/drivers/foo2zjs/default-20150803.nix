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
                   [ { url = http://foo2zjs.rkkda.com/firmware/sihp1000.tar.gz; md5 = "eb7f6e1edfec313e6ca23abd27a0d1c2"; }
                     { url = http://foo2zjs.rkkda.com/firmware/sihp1005.tar.gz; md5 = "04f7bd2eec09131371e27403626f38b5"; }
		     { url = http://foo2zjs.rkkda.com/firmware/sihp1018.tar.gz; md5 = "bf61f2ce504b233f999bc358f5a79499"; }
		     { url = http://foo2zjs.rkkda.com/firmware/sihp1020.tar.gz; md5 = "1d408fa44fb43f2f5f8c8f7eabcc70c6"; }
		     { url = http://foo2zjs.rkkda.com/firmware/sihpP1005.tar.gz; md5 = "aea4d27086db3d84b94c3fae8d98085c"; }
		     { url = http://foo2zjs.rkkda.com/firmware/sihpP1006.tar.gz; md5 = "df4b0b84c6feb0d45f64d7fc219895a5"; }
		     { url = http://foo2zjs.rkkda.com/firmware/sihpP1505.tar.gz; md5 = "6022a2fd13c7c77df4320d3b912610c9"; } ];


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
