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

The `update-gogh.yml` workflow runs weekly, checks for new Gogh releases, and opens a PR with updated `Artifacts.toml` if there are changes.

## format/

Runs JuliaFormatter on the codebase.

```bash
julia --project=scripts/format scripts/format/format.jl
```
