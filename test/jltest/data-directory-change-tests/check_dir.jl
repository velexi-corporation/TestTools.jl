#   Copyright 2022 Velexi Corporation
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

"""
Unit tests to test methods in `jltest/utils.jl`
"""

# --- Imports

using Test

# --- Tests

@testset "check directory" begin
    expected_contents = Set(["change_dir.jl", "check_dir.jl", "subdir"])
    contents = Set(filter(x -> !startswith(x, "."), readdir()))
    @test contents == expected_contents
end
