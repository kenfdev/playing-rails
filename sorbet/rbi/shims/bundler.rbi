# typed: true

# Bundler vendors `connection_pool` (which provides ForkTracker), but tapioca
# does not generate a vendored RBI for it. Some gem RBIs (`sqlite3`, `ffi`)
# reference `::Bundler::ConnectionPool::ForkTracker` directly, which leaves
# Sorbet unable to resolve the constant. This shim declares the minimum
# surface so type-checking succeeds.
module Bundler
  module ConnectionPool
    module ForkTracker; end
  end
end
