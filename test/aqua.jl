using Aqua, Fides

@testset "Aqua" begin
    Aqua.test_ambiguities(Fides, recursive = false)
    Aqua.test_undefined_exports(Fides)
    Aqua.test_unbound_args(Fides)
    Aqua.test_stale_deps(Fides)
    Aqua.test_deps_compat(Fides)
    Aqua.find_persistent_tasks_deps(Fides)
    Aqua.test_piracies(Fides)
    Aqua.test_project_extras(Fides)
end
