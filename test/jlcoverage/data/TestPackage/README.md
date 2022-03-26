<!---
    Copyright (c) 2022 Velexi Corporation

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
-->

This package is used to test the `jlcoverage` module. To regenerate the coverage data
used by the unit tests for `jlcoverage`, start `julia` in this directory and run
`Pkg.test(coverage=true)` in the Julia REPL:

    ```julia
    julia> import Pkg; Pkg.test(coverage=true)
    ```