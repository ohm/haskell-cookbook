module Haskell
  module Config
    class GHC
      attr_reader :version

      def initialize(path, machine, mirror, version)
        @path, @machine, @mirror, @version = path, machine, mirror, version
      end

      def bin
        File.join(prefix, 'bin')
      end

      def ghc
        File.join(bin, 'ghc')
      end

      def prefix
        File.join(@path, @version)
      end

      def source
        "#{@mirror}/#{@version}/#{tar}"
      end

      def tar
        'ghc-%s-%s-unknown-linux.tar.bz2' % [ @version, arch ]
      end

      private

      def arch
        @machine =~ /x86_64/ ? 'x86_64' : 'i386'
      end
    end

    class Platform
      attr_reader :version

      def initialize(ghc, mirror, version)
        @ghc, @mirror, @version = ghc, mirror, version
      end

      def bin
        File.join(prefix, 'bin')
      end

      def cabal
        File.join(bin, 'cabal')
      end

      def prefix
        File.join(@ghc.prefix, "haskell-platform-#{@version}")
      end

      def source
        "#{@mirror}/#{@version}/#{tar}"
      end

      def tar
        "haskell-platform-#{@version}.tar.gz"
      end
    end
  end
end
