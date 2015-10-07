class Rcs < Formula
  desc "GNU revision control system"
  homepage "https://www.gnu.org/software/rcs/"
  url "http://ftpmirror.gnu.org/rcs/rcs-5.9.4.tar.xz"
  mirror "https://ftp.gnu.org/gnu/rcs/rcs-5.9.4.tar.xz"
  sha256 "063d5a0d7da1821754b80c639cdae2c82b535c8ff4131f75dc7bbf0cd63a5dff"

  bottle do
    cellar :any
    sha1 "c1b9165adefc09d0ec1ed38ba7d25a47d61617b6" => :yosemite
    sha1 "f3b9ff862830ecc7d84451b82a22d8b6db7ff9eb" => :mavericks
    sha1 "f47df6b50e9d48d06a72b03e9425cf4bf4fbc429" => :mountain_lion
  end

  head do
    url "git://git.savannah.gnu.org/rcs.git", :branch => 'next'

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "texinfo" => :build

    resource "gnulib" do
      url "git://git.savannah.gnu.org/gnulib.git"
    end

    resource "gnulib_patch" do
      url "https://gist.githubusercontent.com/zchee/034fea97ac9bfbb55280/raw/e37971626f5c2bf6f3fbbe4cfec474e39e6d2dc0/gnulib-path_max.patch"
    end

  end

  def install

    if build.head?

      gnulib_path = buildpath/"gnulib"
      gnulib_path.install resource("gnulib")
      
      # gnulib head configure broken on macosx atm
      # temp fix thanks to @zchee...
      Dir.chdir "gnulib"
      (Pathname.pwd).install resource("gnulib_patch")
      system "patch", "-p1", "-i", "gnulib-path_max.patch"

      system "ln", "-s", "/sbin/md5", "md5sum"
      ENV["PATH"] += ":" + Pathname.pwd

      Dir.chdir buildpath

      # TODO: How do we figure out the latest installed version?
      ENV["PATH"] = "/usr/local/Cellar/texinfo/6.0/bin:" + ENV["PATH"]

      system "sh", "autogen.sh"
    end

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"

end

  test do
    system bin/"merge", "--version"
  end
end
