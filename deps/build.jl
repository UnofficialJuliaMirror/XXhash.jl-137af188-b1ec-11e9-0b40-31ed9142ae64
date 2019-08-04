using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libxxhash"], :libxxhash),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/hros/XXhashBuilder/releases/download/0.7"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/xxhash.v0.7.0.aarch64-linux-gnu.tar.gz", "f7c5bfca65d540d048e15ac44eb0c2d55c1195db0b3b7b58df0ede6cb71f30bd"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/xxhash.v0.7.0.aarch64-linux-musl.tar.gz", "7de04962cda7f4bdc26e919d639e2bf8da091879eb72e6234120e47fa13722e3"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/xxhash.v0.7.0.arm-linux-gnueabihf.tar.gz", "74181cef69573a5a3d66a30f35236acedebe3073bba66383341aafdd8858f0da"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/xxhash.v0.7.0.arm-linux-musleabihf.tar.gz", "9952c94f47792913b8b1e88858c591ec063ba7cfd8067545f8f916933ab14265"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/xxhash.v0.7.0.i686-linux-gnu.tar.gz", "8944e31f43a131d26ce9a00d8ba41d7c50bcb3404b2cdf987a051c7c930ab923"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/xxhash.v0.7.0.i686-linux-musl.tar.gz", "e056f8b32d23ea55c519e7f81664503917e9ecfb90fb203bcdf9e88b8305eea6"),
    Windows(:i686) => ("$bin_prefix/xxhash.v0.7.0.i686-w64-mingw32.tar.gz", "5c51e8dc8cf570a453171b305ae9da9fa9a861700690f3f08195c35c75fb4c34"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/xxhash.v0.7.0.powerpc64le-linux-gnu.tar.gz", "19a707fd789c609e045bce732b3d5eaf2c3a161bc6564b223295bb7a7ba2e626"),
    MacOS(:x86_64) => ("$bin_prefix/xxhash.v0.7.0.x86_64-apple-darwin14.tar.gz", "dc128e4f34dfaf332945470cf11b50280e09a4eba56f5d330d41dbd036392fc6"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/xxhash.v0.7.0.x86_64-linux-gnu.tar.gz", "abf5d619f9a497c510f23758eebd4a7f8800e5ae7a3aa576623d724075902cdc"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/xxhash.v0.7.0.x86_64-linux-musl.tar.gz", "7cd7cc7f25149ba212f2bf43e85bd7ab8bcc44c6937258e5db3bb165cda1d3c9"),
    FreeBSD(:x86_64) => ("$bin_prefix/xxhash.v0.7.0.x86_64-unknown-freebsd11.1.tar.gz", "f78c6ff06f86a63d37be2f46f7a0fc61bc8b6c9937d5ef891df87126b054e07f"),
    Windows(:x86_64) => ("$bin_prefix/xxhash.v0.7.0.x86_64-w64-mingw32.tar.gz", "8cf2278f06995cc1c85aaf7391ff35036c1c01fc83b935b5cb707ca1f6f26fc0"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)