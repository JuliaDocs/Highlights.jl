# Scripts

## gogh/

Updates Gogh themes artifact to latest release.

### Usage

```bash
# Local: set up worktree for artifacts branch
git worktree add ../highlights-artifacts artifacts

# Run update
julia --project=scripts/gogh scripts/gogh/gogh.jl ../highlights-artifacts
```

### CI

The `update-data.yml` workflow runs weekly. It checks for new Gogh releases and regenerates the language list, then opens a PR if `Artifacts.toml` or `src/language_jlls.jl` changed.

## languages/

Regenerates `src/language_jlls.jl`, the list of `tree_sitter_*_jll` packages registered in General.

```bash
julia scripts/languages/languages.jl
```

## format/

Runs JuliaFormatter on the codebase.

```bash
julia --project=scripts/format scripts/format/format.jl
```
