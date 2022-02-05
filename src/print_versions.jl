using Pkg
using UUIDs

"""Print the versions of the packages constituting QuantumControl."""
function print_versions()
    project_toml = Pkg.TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))
    version = project_toml["version"]
    direct_deps = project_toml["deps"]
    deps = Pkg.dependencies()
    pkg_names = [name for name in keys(direct_deps) if name ∉ ["Pkg", "UUIDs"]]
    col_width = maximum([length(name) for name in pkg_names])
    for name in reverse(pkg_names)
        pkginfo = deps[UUIDs.UUID(direct_deps[name])]
        if pkginfo.is_tracking_path
            println("$(rpad(name, col_width)): $(pkginfo.version) ($(pkginfo.source))")
        else
            println("$(rpad(name, col_width)): $(pkginfo.version)")
        end
    end
    println("$(rpad("QuantumControl", col_width)): $version")
end
