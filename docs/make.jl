using Fides
using Documenter

DocMeta.setdocmeta!(Fides, :DocTestSetup, :(using Fides); recursive = true)

format = Documenter.HTML(;prettyurls = get(ENV, "CI", "false") == "true",
                         assets = String["assets/custom_theme.css"],
                         repolink = "https://github.com/sebapersson/Fides.jl",
                         edit_link = "main")

makedocs(; modules = [Fides],
         repo = "https://github.com/sebapersson/Fides.jl/blob/{commit}{path}#{line}",
         checkdocs = :exports,
         warnonly = false,
         format = format,
         sitename = "Fides.jl",
         pages = [
             "Home" => "index.md",
             "Tutorial" => "tutorial.md",
             "API" => "API.md",
         ],)

deploydocs(; repo = "github.com/sebapersson/Fides.jl.git",
           devbranch = "main",)
