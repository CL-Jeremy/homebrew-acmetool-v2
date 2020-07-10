class Acmetool < Formula
  desc "Automatic certificate acquisition tool for ACME (Let's Encrypt) v2"
  homepage "https://github.com/hlandau/acmetool"
  url "https://github.com/hlandau/acmetool.git",
      :tag      => "v0.2.1",
      :revision => "f68b275d0a0ca526525b1d11e58be9b7e995251f"
  head "https://github.com/hlandau/acmetool.git"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "859ddcc717399c6724283beece51c0a93497e00be685d3f1cfb7153506cbd9bb" => :macos
  end

  depends_on "go" => :build
  depends_on "libcap" unless OS.mac?

  patch do
    url "https://sources.debian.org/data/main/a/acmetool/0.2.1-2/debian/patches/fix-undefined-status-code-in-redirector-test.patch"
    sha256 "85b99219c3ecdae15d52b25e646aed2abd0df137812a66dce926f5febae3af26"
  end

  patch do
    url "https://sources.debian.org/data/main/a/acmetool/0.2.1-2/debian/patches/substitute-github-gofrs-uuid-for-github-satori-go-uuid.patch"
    sha256 "b97be01395d18e46a3d211c43b32c4b731f6363885bc4177d4a067a6ff8b1b43"
  end

  patch do
    url "https://github.com/CL-Jeremy/acmetool/commit/6f20873a3a15ac48ceca779dde245caf9bc9682d.patch?full_index=1"
    sha256 "2b77d1cf92dd54cce3b12c408dca81ace0428101f4704ccc4eec2f340cf59be8"
  end

  def install
    # https://github.com/hlandau/acmetool/blob/HEAD/_doc/PACKAGING-PATHS.md
    buildinfo = Utils.safe_popen_read("(echo acmetool Homebrew version #{version} \\($(uname -mrs)\\);
                                      go list -m all | sed '1d') | base64 | tr -d '\\n'")
    ldflags = %W[
      -X github.com/hlandau/acmetool/storage.RecommendedPath=#{var}/lib/acmetool
      -X github.com/hlandau/acmetool/hooks.DefaultPath=#{lib}/hooks
      -X github.com/hlandau/acmetool/responder.StandardWebrootPath=#{var}/run/acmetool/acme-challenge
      -X github.com/hlandau/buildinfo.RawBuildInfo=#{buildinfo}
    ]
    system "go", "build", "-ldflags", ldflags.join(" "), "-o", bin/"acmetool", buildpath/"cmd/acmetool"

    (man8/"acmetool.8").write Utils.safe_popen_read(bin/"acmetool", "--help-man")

    doc.install Dir["_doc/*"]
  end

  def post_install
    (var/"lib/acmetool").mkpath
    (var/"run/acmetool").mkpath
  end

  def caveats
    <<~EOS
      Follow \x1B[4mhttps://github.com/hlandau/acmetool/issues/322\x1B[0m for instructions to
      upgrade to ACMEv2 and discussion on the future of acmetool.
    EOS
  end

  test do
    assert_match Regexp.new(version.to_s.gsub(/.*-/, "acmetool .*-")), shell_output("#{bin}/acmetool --version", 2)
  end
end
