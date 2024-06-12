{ lib, nodejs-18_x, makeWrapper, stdenv, fetchurl }:

let
  nodejs = nodejs-18_x;
in

stdenv.mkDerivation rec {

  pname = "code-server";
  version = "4.90.0";
  nativeBuildInputs = [ makeWrapper nodejs ];
  propagatedBuildInputs = [ nodejs ];
  propagatedNativeBuildInputs = [ ];

  src = (
    fetchurl {
      url = "https://github.com/coder/code-server/releases/download/v${version}/code-server-${version}-linux-amd64.tar.gz";
      sha256 = "sha256-zb4L9qgEB9Qfq0HT0MyYGG7597yg91AEGbXtklnb8z8=";
      # if this fails, use the "got" output from error message"
    }
  );

  installPhase = ''
    mkdir -p $out/bin
    tar -xzf ${src} -C $out --strip-components=1
    rm -rf $out/lib/node

    ln -s ${nodejs}/bin/node $out/lib/node
    ln -s ${nodejs}/bin/node $out/lib/vscode/node

    makeWrapper "${nodejs}/bin/node" "$out/bin/code-server" --add-flags "$out/out/node/entry.js"
  '';

  passthru = {
    executable = pname;
  };

  meta = with lib; {
    description = "VS Code in the browser";
    longDescription = "Run VS Code on any machine anywhere and access it in the browser.";
    homepage = "https://github.com/coder/code-server";
    platforms = platforms.all;
    license = licenses.mit;
    maintainers = [ maintainers.offline ];
  };
}
