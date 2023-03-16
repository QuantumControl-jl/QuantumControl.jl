using Test

using QuantumControl: @optimize_or_load, load_optimization, save_optimization, optimize
using QuantumControlTestUtils.DummyOptimization:
    dummy_control_problem, DummyOptimizationResult

@testset "metadata" begin

    problem = dummy_control_problem()
    outdir = mktempdir()
    outfile = joinpath(outdir, "optimization_with_metadata.jld2")
    println("")
    result = @optimize_or_load(
        outfile,
        problem;
        method=:dummymethod,
        metadata=Dict("testset" => "metadata", "method" => :dummymethod,)
    )
    @show outfile
    @test result.converged
    @test isfile(outfile)
    result_load, metadata = load_optimization(outfile; return_metadata=true)
    @test result_load isa DummyOptimizationResult
    @test result_load.message == "Reached maximum number of iterations"
    @test metadata["testset"] == "metadata"
    @test metadata["method"] == :dummymethod

    outfile2 = joinpath(outdir, "optimization_with_metadata2.jld2")
    save_optimization(outfile2, result_load; metadata)
    @test isfile(outfile2)
    result_load2, metadata2 = load_optimization(outfile2; return_metadata=true)
    @test result_load2 isa DummyOptimizationResult
    @test result_load2.message == "Reached maximum number of iterations"
    @test metadata2["testset"] == "metadata"
    @test metadata2["method"] == :dummymethod

end


@testset "continue_from" begin
    problem = dummy_control_problem()
    outdir = mktempdir()
    outfile = joinpath(outdir, "optimization_stage1.jld2")
    println("")
    result = @optimize_or_load(outfile, problem; iter_stop=5, method=:dummymethod)
    @test result.converged
    result1 = load_optimization(outfile)
    result2 = optimize(problem; method=:dummymethod, iter_stop=15, continue_from=result1)
    @test result2.iter == 15
end
