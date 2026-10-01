{
  lib,
  buildGoModule,
  fetchFromGitea,
}:

buildGoModule rec {
  pname = "ncmdump-go";
  version = "1.7.5";

  src = fetchFromGitea {
    domain = "git.taurusxin.com";
    owner = "taurusxin";
    repo = "ncmdump-go";
    rev = "v${version}";
    hash = "sha256-WqQYnb5URntk96xRISWARrfBrX4k/uF+HgRSknnCqzY=";
  };

  vendorHash = "sha256-SgbD6KfTxnUFmfr6Ngko0I5bDTp1a411DV9uGs0YQ58=";

  preBuild = ''
    export GOPROXY="https://goproxy.cn,direct"
    export GOSUMDB="off"
  '';
  meta = {
    description = "转换网易云音乐 ncm 到 mp3 / flac (Go 版)";
    homepage = "https://git.taurusxin.com/taurusxin/ncmdump-go";
    license = lib.licenses.mit;
    mainProgram = "ncmdump-go";
    maintainers = [ "IRendy" ];
    platforms = lib.platforms.all;
  };
}
