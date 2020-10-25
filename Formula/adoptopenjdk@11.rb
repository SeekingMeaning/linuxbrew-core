class AdoptopenjdkAT11 < Formula
  desc "Prebuilt binaries produced from OpenJDK class libraries"
  homepage "https://adoptopenjdk.net/"
  url "https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.8%2B10/OpenJDK11U-jdk_x64_linux_hotspot_11.0.8_10.tar.gz"
  version "11.0.8.10"
  sha256 "6e4cead158037cb7747ca47416474d4f408c9126be5b96f9befd532e0a762b47"

  livecheck do
    url "https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/latest"
    regex(%r{href=.*?/tag/.*?>jdk-(\d+(?:\.\d+)+\+\d*)[_<]}i)
  end

  bottle :unneeded

  depends_on "alsa-lib"
  depends_on "libx11"
  depends_on "libxext"
  depends_on "libxi"
  depends_on "libxrender"
  depends_on "libxtst"
  depends_on :linux
  depends_on "zlib"

  def add_to_rpath(files, rpaths)
    rpaths = Array(rpaths)
    files.each do |file|
      file = Pathname(file)
      file.patch!(rpath: "#{file.rpath}:#{rpaths.join(":")}")
    end
  end

  def install
    libexec.install Dir["*"]
    share.install libexec/"man"
    bin.install_symlink Dir["#{libexec}/bin/*"]
    lib.install_symlink Dir["#{libexec}/lib/*.so"]
    include.install_symlink Dir["#{libexec}/include/*.h"]
    include.install_symlink Dir["#{libexec}/include/linux/*.h"]

    opt_libs = deps.map { |dep| dep.to_formula.opt_lib }
    add_to_rpath(Dir[libexec/"bin/*"], opt_libs)
    add_to_rpath(Dir[libexec/"lib/**/*.so"], opt_libs)
    add_to_rpath(Dir[libexec/"lib/*.so"], "$ORIGIN/server")
  end

  test do
    (testpath/"Hello.java").write <<~EOS
      class Hello
      {
        public static void main(String[] args)
        {
          System.out.println("Hello Homebrew");
        }
      }
    EOS
    system bin/"javac", "Hello.java"
    assert_predicate testpath/"Hello.class", :exist?, "Failed to compile Java program!"
    assert_equal "Hello Homebrew\n", shell_output("#{bin}/java Hello")
  end
end
