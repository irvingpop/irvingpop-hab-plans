pkg_name=pgpool-II
pkg_origin=jeremymv2
pkg_version=4.0.2
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_description="Middleware that works between PostgreSQL servers and a PostgreSQL database client"
pkg_upstream_url="https://www.pgpool.net"
pkg_license=('BSD')
pkg_source=http://www.pgpool.net/download.php?f=${pkg_name}-${pkg_version}.tar.gz
pkg_shasum=a9324dc84e63961476cd32e74e66b6fdebc5ec593942f8710a688eb88e50dcc1
pkg_deps=(
  core/glibc
  core/postgresql-client
)
pkg_build_deps=(
  core/gcc
  core/make
)
pkg_bin_dirs=(bin)
pkg_lib_dirs=(lib)
pkg_binds=(
  [database]="port"
)
pkg_exports=()
pkg_exposes=()

do_setup_environment() {
   push_runtime_env LD_LIBRARY_PATH "$(pkg_path_for postgresql-client)/lib"
}
