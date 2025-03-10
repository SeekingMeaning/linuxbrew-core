class Mavsdk < Formula
  desc "API and library for MAVLink compatible systems written in C++11"
  homepage "https://mavsdk.mavlink.io"
  url "https://github.com/mavlink/MAVSDK.git",
    tag:      "v0.30.0",
    revision: "4669ffd6f4dba83e2afc6c9dda473d51178410a9"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    cellar :any
    sha256 "69659eedaa707b1006eaa479ec6eccbae4911d4c9b1f2a43df463393c427db7f" => :catalina
    sha256 "f3c369403ca86c8c21cc3fc7190421f4af3023e89620b9b5961e3ea671f2a44e" => :mojave
    sha256 "e05484cd1386a4eaf75ce3c4186d26157d3d858131b7d4e9ed0760571c6bf143" => :high_sierra
    sha256 "e22226dd2c8b9b6a66614575aa4263154659de12169324184acf39e457fb1838" => :x86_64_linux
  end

  depends_on "cmake" => :build

  def install
    system "cmake", *std_cmake_args,
                    "-Bbuild/default",
                    "-DBUILD_BACKEND=ON",
                    "-H."
    system "cmake", "--build", "build/default", "--target", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <mavsdk/mavsdk.h>
      #include <mavsdk/plugins/info/info.h>
      int main() {
          mavsdk::Mavsdk mavsdk;
          mavsdk.version();
          mavsdk::System& system = mavsdk.system();
          auto info = std::make_shared<mavsdk::Info>(system);
          return 0;
      }
    EOS
    system ENV.cxx, "-std=c++11", testpath/"test.cpp", "-o", "test",
                  "-I#{include}/mavsdk",
                  "-L#{lib}",
                  "-lmavsdk",
                  "-lmavsdk_info"
    system "./test"

    assert_equal "Usage: backend_bin [-h | --help]",
                 shell_output("#{bin}/mavsdk_server --help").split("\n").first
  end
end
