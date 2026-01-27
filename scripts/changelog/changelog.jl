import Changelog

cd(dirname(dirname(@__DIR__))) do
    Changelog.generate(
        Changelog.CommonMark(),
        "CHANGELOG.md";
        repo = "JuliaDocs/Highlights.jl",
    )
end
