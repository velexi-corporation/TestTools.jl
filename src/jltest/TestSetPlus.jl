"""
jltest/TestSetPlus.jl extend the types and methods that support unit testing.

Acknowledgements
----------------
* Much of the core functionality of the `TestSetPlus` type (and associated methods) were
  taken directly from the TestSetExtensions package developed by Spencer Russell and
  his collaborators (https://github.com/ssfrr/TestSetExtensions.jl). `TestSetPlus` builds
  upon the foundation of `ExtendedTestSet` to add support for "fail fast" functionality.

-------------------------------------------------------------------------------------------
COPYRIGHT/LICENSE. This file is part of the TestTools.jl package. It is subject to the
license terms in the LICENSE file found in the root directory of this distribution. No
part of the TestTools.jl package, including this file, may be copied, modified, propagated,
or distributed except according to the terms contained in the LICENSE file.
-------------------------------------------------------------------------------------------
"""
# --- Exports

export TestSetPlus, TestSetPlusException

# --- Imports

# Standard library
using Test: Test
using Test: AbstractTestSet, DefaultTestSet, FallbackTestSet
using Test: Result, Fail, Error, Pass

# External Packages
using DeepDiffs
using Distributed

# --- Types

struct TestSetPlus{T<:AbstractTestSet} <: AbstractTestSet
    wrapped::T

    """
    Two inner constructors

    * one for subtypes of AbstractTestSet that possess a constructor with a `desc` argument

    * one for subtypes of AbstractTestSet that do not possess a constructor with a `desc`
      argument
    """
    TestSetPlus{T}(desc) where {T} = new(T(desc))

    TestSetPlus{FallbackTestSet}(desc) = new(FallbackTestSet())
end

struct TestSetPlusException <: Exception
    msg::String
end

# --- Functions/Methods

function TestSetPlus(desc; wrap=DefaultTestSet)
    return TestSetPlus{wrap}(desc)
end

function Test.record(ts::TestSetPlus{T}, res::Fail) where {T}
    println("\n=====================================================")
    Test.record(ts.wrapped, res)
    println("=====================================================")
    return nothing
end

function Test.record(ts::TestSetPlus{DefaultTestSet}, res::Fail)
    if Distributed.myid() == 1
        println("\n=====================================================")
        printstyled(ts.wrapped.description, ": "; color=:white)

        if res.test_type === :test
            try
                test_expr = if isa(res.data, Expr)
                    res.data
                elseif isa(res.data, String)
                    Meta.parse(res.data)
                end

                if test_expr.head === :call && test_expr.args[1] === Symbol("==")
                    test_expr_diff =
                        if isa(test_expr.args[2], String) && isa(test_expr.args[3], String)
                            deepdiff(test_expr.args[2], test_expr.args[3])
                        elseif test_expr.args[2].head === :vect &&
                            test_expr.args[3].head === :vect
                            deepdiff(test_expr.args[2].args, test_expr.args[3].args)
                        elseif test_expr.args[2].head === :call &&
                            test_expr.args[3].head === :call &&
                            test_expr.args[2].args[1].head === :curly &&
                            test_expr.args[3].args[1].head === :curly
                            deepdiff(
                                Base.eval(test_expr.args[2].args),
                                Base.eval(test_expr.args[3].args),
                            )
                        end

                    if !isa(test_expr_diff, DeepDiffs.SimpleDiff)
                        # The test was an comparison between things we can diff,
                        # so display the diff
                        printstyled("Test Failed\n"; bold=true, color=Base.error_color())
                        println("  Expression: ", res.orig_expr)
                        printstyled("\n  Diff:\n"; color=Base.info_color())
                        println(test_expr_diff)
                        println()
                    else
                        # Fallback to the default printing if we don't have a pretty diff
                        print(res)
                    end
                end
            catch ex
                print(res)
            end
        else
            # fallback to the default printing for non-comparisons
            print(res)
        end

        Base.show_backtrace(stdout, Test.scrub_backtrace(backtrace()))
        println("\n=====================================================")
    end
    push!(ts.wrapped.results, res)
    return res, backtrace()
end

function Test.record(ts::TestSetPlus{T}, res::Error) where {T}
    # Ignore errors generated from failed FallbackTestSet
    if occursin(r"^Test.FallbackTestSetException", res.value) || (
        occursin(r"^TestSetExtensions.TestSetPlusException", res.value) &&
        occursin("FallbackTestSetException occurred", res.value)
    )
        throw(TestSetPlusException("FallbackTestSetException occurred"))
    end

    println("\n=====================================================")
    Test.record(ts.wrapped, res)
    println("=====================================================")
    return nothing
end

function Test.record(ts::TestSetPlus{T}, res::Pass) where {T}
    printstyled("."; color=:green)
    Test.record(ts.wrapped, res)
    return res
end

Test.record(ts::TestSetPlus{T}, res) where {T} = Test.record(ts.wrapped, res)

# When recording DefaultTestSet results to an TestSetPlus{FallbackTestSet},
# throw an exception if there are any failures or errors in the DefaultTestSet.
#
# Note: this method is only needed for backward compatibility with Julia<=1.3
function Test.record(ts::TestSetPlus{FallbackTestSet}, res::DefaultTestSet)
    # Check for failures and errors
    passes, fails, errors, broken, _, _, _, _ = Test.get_test_counts(res)
    if (fails > 0) || (errors > 0)
        throw(
            TestSetPlusException(
                "Failure or error occurred in DefaultTestSet nested within FallbackTestSet."
            ),
        )
    end

    return res
end

function Test.finish(ts::TestSetPlus{T}) where {T}
    Test.get_testset_depth() == 0 && print("\n\n")
    Test.finish(ts.wrapped)
    return nothing
end
