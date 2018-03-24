function __caching__load_cache_filename {
  cache_dir="${alfred_workflow_cache?}/base_paths"
  mkdir -p "${cache_dir}"
  base_path_hashed="$(
    tr -d '\n' <<< "${base_path?}" \
      | /usr/bin/shasum \
      | awk '{ print $1 }'
  )"
  cache_filename="${cache_dir}/${base_path_hashed}.yaml"
}

export -f __caching__load_cache_filename
