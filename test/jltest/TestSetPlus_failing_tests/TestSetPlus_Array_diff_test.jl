"""
Failing TestSetPlus test: check behavior for failed Array comparison

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
# --- Imports

# Standard library
using Test

# Local modules
using TestTools.jltest

# --- Tests

@testset TestSetPlus "TestSetPlus: Array diff test" begin
    @test [3, 5, 6, 1, 6, 8] == [3, 5, 6, 1, 9, 8]
end
