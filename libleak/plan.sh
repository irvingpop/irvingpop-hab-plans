pkg_name=libleak
pkg_origin=irvingpop
pkg_version="0.3.1"
pkg_upstream_url="https://github.com/WuBingzheng/libleak.git"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=("GPLv2")
pkg_shasum="9909e0852855f99b52f2943874386cc9963b8ba08871905e402cc9f9942c1f37"
pkg_dirname="${pkg_name}-${pkg_version}"
pkg_deps=(core/glibc)
pkg_build_deps=(core/make core/gcc core/git)
pkg_lib_dirs=(lib)

# # automatically inject LD_PRELOAD, so that all running services will get it
# do_setup_environment() {
#   push_runtime_env LD_PRELOAD "${pkg_prefix}/lib/libleak.so"
#   push_buildtime_env LD_PRELOAD ""
# }

do_build() {
  workdir="${HAB_CACHE_SRC_PATH}/${pkg_dirname}"
  rm -rf ${workdir}
  mkdir -p ${workdir}
  pushd ${workdir}
  git clone $pkg_upstream_url .
  git reset --hard "v${pkg_version}"
  git submodule init libwuya
  git pull --recurse-submodules
  make --jobs=$(nproc) || attach
  popd
}

do_install() {
  mkdir -p "${pkg_prefix}/lib"
  install "${HAB_CACHE_SRC_PATH}/${pkg_dirname}/libleak.so" "${pkg_prefix}/lib/"
}
