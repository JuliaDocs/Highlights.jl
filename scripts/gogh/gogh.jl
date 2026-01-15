# Update Gogh themes artifact to the latest release.
#
# Downloads themes from Gogh-Co/Gogh, creates an artifact tarball,
# pushes to the artifacts branch, and updates Artifacts.toml.
#
# Usage:
#     julia --project=scripts/gogh scripts/gogh/gogh.jl [artifacts_dir]

import Pkg
import Pkg.Artifacts: create_artifact, archive_artifact
import Downloads
import SHA
import JSON

const GOGH_REPO = "Gogh-Co/Gogh"
const ARTIFACT_REPO = "JuliaDocs/Highlights.jl"
const ARTIFACT_BRANCH = "artifacts"

function get_artifacts_dir()
    for arg in ARGS
        startswith(arg, "-") && continue
        return arg
    end
    return joinpath(@__DIR__, "..", "..", "artifacts")
end

function should_force()
    return "--force" in ARGS || "-f" in ARGS
end

function gh_api(endpoint::String)
    output = read(`gh api $endpoint`, String)
    return JSON.parse(output)
end

function get_latest_release()
    data = gh_api("repos/$GOGH_REPO/releases/latest")
    return data["tag_name"]
end

function get_current_version()
    artifacts_path = joinpath(@__DIR__, "..", "..", "Artifacts.toml")
    isfile(artifacts_path) || return nothing
    content = read(artifacts_path, String)
    m = match(r"gogh-(v\d+)\.tar\.gz", content)
    return m === nothing ? nothing : m.captures[1]
end

function create_tarball(tag::String)
    url = "https://github.com/$GOGH_REPO/archive/refs/tags/$tag.tar.gz"

    println("Downloading $url...")
    temp_tarball = tempname() * ".tar.gz"
    Downloads.download(url, temp_tarball)

    println("Creating artifact...")
    tree_hash = create_artifact() do dir
        # Extract only data/json/, strip 2 components to get json/* directly
        run(`tar -xzf $temp_tarball -C $dir --strip-components=2 --include='*/data/json/*'`)
        # Rename json/ to data/json/ to match expected path
        mkpath(joinpath(dir, "data"))
        mv(joinpath(dir, "json"), joinpath(dir, "data", "json"))
    end

    # Archive using Julia's method for correct hash
    tarball_name = "gogh-$tag.tar.gz"
    tarball_path = joinpath(tempdir(), tarball_name)
    archive_artifact(tree_hash, tarball_path)

    # Compute SHA256
    sha256 = bytes2hex(open(SHA.sha256, tarball_path))
    git_tree_sha1 = bytes2hex(tree_hash.bytes)

    rm(temp_tarball)

    return (
        path = tarball_path,
        name = tarball_name,
        sha256 = sha256,
        git_tree_sha1 = git_tree_sha1,
    )
end

function update_artifacts_branch(tarball, tag::String, artifact_dir::String)
    if !isdir(artifact_dir)
        error("Artifacts directory not found: $artifact_dir")
    end

    cd(artifact_dir) do
        # Delete all existing tarballs
        for f in readdir()
            if endswith(f, ".tar.gz")
                println("Removing old tarball: $f")
                rm(f)
            end
        end

        # Copy new tarball
        cp(tarball.path, tarball.name)

        # Commit and push
        run(`git add -A`)
        run(`git commit -m "gogh $tag"`)
        run(`git push origin $ARTIFACT_BRANCH`)

        # Get commit SHA
        commit = strip(read(`git rev-parse HEAD`, String))
        return commit
    end
end

function update_artifacts_toml(tag, commit, tarball)
    url = "https://raw.githubusercontent.com/$ARTIFACT_REPO/$commit/$(tarball.name)"

    content = """
    [Gogh]
    git-tree-sha1 = "$(tarball.git_tree_sha1)"

    [[Gogh.download]]
    url = "$url"
    sha256 = "$(tarball.sha256)"
    """

    artifacts_path = joinpath(@__DIR__, "..", "..", "Artifacts.toml")
    write(artifacts_path, content)
    println("Updated Artifacts.toml")
end

function main()
    artifact_dir = get_artifacts_dir()
    println("Artifacts directory: $artifact_dir")

    println("Fetching latest release...")
    tag = get_latest_release()
    println("Latest release: $tag")

    current = get_current_version()
    if current == tag && !should_force()
        println("Already at $tag, nothing to update. Use --force to rebuild.")
        return
    end

    println("Creating tarball...")
    tarball = create_tarball(tag)
    println("git-tree-sha1: $(tarball.git_tree_sha1)")
    println("sha256: $(tarball.sha256)")

    println("Updating artifacts branch...")
    commit = update_artifacts_branch(tarball, tag, artifact_dir)
    println("Commit: $commit")

    update_artifacts_toml(tag, commit, tarball)

    # Cleanup temp tarball
    rm(tarball.path)

    println("Done!")
end

main()
