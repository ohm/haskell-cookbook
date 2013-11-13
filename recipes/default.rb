#
# dependencies
#

include_recipe 'build-essential'

#
# ghc
#

ghc =
  Haskell::Config::GHC.new(
    '/opt/haskell',
    node['kernel']['machine'],
    node['haskell']['ghc']['mirror'],
    node['haskell']['ghc']['version']
  )

ghc_tar_cached = File.join(Chef::Config[:file_cache_path], ghc.tar)

remote_file ghc_tar_cached do
  action :create_if_missing
  source ghc.source
end

bash 'Build and install GHC' do
  creates ghc.ghc
  code <<-CODE
    tar -xf #{ghc_tar_cached}
    cd ghc-#{ghc.version}
    ./configure --prefix=#{ghc.prefix}
    make
    make install
  CODE
  cwd '/tmp'
  not_if "#{ghc.ghc} --version | grep #{ghc.version}"
end

#
# haskell platform
#

platform =
  Haskell::Config::Platform.new(
    ghc,
    node['haskell']['platform']['mirror'],
    node['haskell']['platform']['version']
  )

%w(freeglut3-dev libgmp3-dev zlib1g-dev).each do |pkg|
  package pkg do
    action :install
  end
end

platform_tar_cached = File.join(Chef::Config[:file_cache_path], platform.tar)

remote_file platform_tar_cached do
  action :create_if_missing
  source platform.source
end

bash 'Build and install Haskell Platform' do
  creates platform.cabal
  code <<-CODE
    tar -xf #{platform_tar_cached}
    cd haskell-platform-#{platform.version}
    export PATH=#{ghc.bin}:$PATH
    ./configure --prefix=#{platform.prefix}
    make
    make install
  CODE
  cwd '/tmp'
end

file '/etc/profile.d/haskell.sh' do
  content "export PATH=#{platform.bin}:#{ghc.bin}:$PATH"
  owner 'root'
  group 'root'
  mode '0777'
end

#
# cabal
#

cabal_version = node['haskell']['cabal']['version']

bash 'Build and install Cabal' do
  code <<-CODE
    export PATH=#{ghc.bin}:$PATH
    #{platform.cabal} update
    #{platform.cabal} install --global \
      --prefix #{platform.prefix} cabal-install-#{cabal_version}
  CODE
  not_if "#{platform.cabal} --version | grep #{cabal_version}"
end
