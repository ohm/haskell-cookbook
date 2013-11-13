#
# maintainer
#

name        'haskell'
maintainer  'Sebastian Ohm'
description 'Installs GHC, Haskell platform and cabal'
version     '0.1.0'
license     'MIT'

#
# supported platforms
#

supports 'debian'

#
# cookbook dependencies
#

depends 'build-essential'
