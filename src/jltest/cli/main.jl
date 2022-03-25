#   Copyright (c) 2022 Velexi Corporation
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
main.jl contains the main program for the `jltest` CLI.
"""

# --- Imports

using TestTools: TestTools, jltest

# --- Main program

# Parse CLI arguments
args = jltest.cli.parse_args()

# Handle --version option
if args["version"]
    println(
        "$(basename(PROGRAM_FILE)) $(TestTools.VERSION) " *
        "(from $(dirname(PROGRAM_FILE)))",
    )
    exit(0)
end

# Run main program
jltest.cli.run(
    args["tests"];
    fail_fast=args["fail-fast"],
    use_wrapper=!args["no-wrapper"],
    recursive=!args["no-recursion"],
    verbose=args["verbose"],
)
