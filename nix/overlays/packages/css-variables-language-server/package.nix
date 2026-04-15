{
  buildNpmPackage,
  fetchzip,
  makeWrapper,
  nodejs,
}:

buildNpmPackage rec {
  pname = "css-variables-language-server";
  version = "2.8.4";

  src = fetchzip {
    url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-pTxKEcj3yBhuQ1gwRdFvo5GU3tTIapavLYWxjnwfC40=";
  };

  npmDepsHash = "sha256-LKDexLpsA6tOBwp1A/ZNMjlgKmoYfP6Nkck/SiWUE7I=";

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/${pname}
    cp -r dist bin node_modules package.json $out/lib/node_modules/${pname}/

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/${pname} \
      --add-flags $out/lib/node_modules/${pname}/bin/index.js

    runHook postInstall
  '';

  meta = {
    meta.homepage = "https://github.com/vunguyentuan/vscode-css-variables";
  };
}
