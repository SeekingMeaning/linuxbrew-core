class Adoptopenjdk < Formula
  desc "Prebuilt binaries produced from OpenJDK class libraries"
  homepage "https://adoptopenjdk.net/"
  url "https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u265-b01/OpenJDK8U-jdk_x64_linux_hotspot_8u265b01.tar.gz"
  version "1.8.0.265"
  sha256 "1285da6278f2d38a790a21148d7e683f20de0799c44b937043830ef6b57f58c4"

  bottle :unneeded

  depends_on "alsa-lib"
  depends_on :linux
  depends_on "linuxbrew/xorg/libx11"
  depends_on "linuxbrew/xorg/libxext"
  depends_on "linuxbrew/xorg/libxi"
  depends_on "linuxbrew/xorg/libxrender"
  depends_on "linuxbrew/xorg/libxtst"
  depends_on "zlib"

  def install
    share.install "man"
    libexec.install Dir["*"]
    bin.install_symlink Dir["#{libexec}/bin/*"]
    include.install_symlink Dir["#{libexec}/include/*.h"]
    include.install_symlink Dir["#{libexec}/include/linux/*.h"]
    lib.install_symlink Dir["#{libexec}/jre/lib/amd64/*"]

    libexec_lib = libexec/"lib/amd64"
    jre_lib = libexec/"jre/lib/amd64"

    libs = [
      jre_lib/"server/libjvm.so",
      Formula["linuxbrew/xorg/libx11"].opt_lib/"libX11.so.6",
      Formula["linuxbrew/xorg/libxext"].opt_lib/"libXext.so.6",
      Formula["linuxbrew/xorg/libxi"].opt_lib/"libXi.so.6",
      Formula["linuxbrew/xorg/libxrender"].opt_lib/"libXrender.so.1",
      Formula["linuxbrew/xorg/libxtst"].opt_lib/"libXtst.so.6",
    ]

    libexec_lib.install_symlink libs
    libexec_lib.install_symlink jre_lib/"libawt.so"
    libexec_lib.install_symlink jre_lib/"libawt_xawt.so"
    libexec_lib.install_symlink jre_lib/"libjava.so"
    libexec_lib.install_symlink jre_lib/"libverify.so"

    jre_lib.install_symlink libs
    jre_lib.install_symlink Formula["alsa-lib"].opt_lib/"libasound.so.2"

    (jre_lib/"libfreetype.so.6").patch! rpath: jre_lib
    jre_lib.install_symlink Formula["zlib"].opt_lib/"libz.so.1"
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
