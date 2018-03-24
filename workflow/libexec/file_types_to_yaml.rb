#encoding: utf-8

require 'yaml'

CACHE_TTL_MINUTES = 3

base_path = ENV['base_path']

file_types_map =
  ARGF.each.each_slice(3).reduce({}) do |hash, metadata|
  md_item_content_type = metadata[0].chomp

  unless hash.has_key?(md_item_content_type)
    hash[md_item_content_type] = {
      md_item_content_type:    md_item_content_type,
      md_item_fs_name_example: metadata[1].chomp,
      md_item_kind:            metadata[2].chomp,
    }
  end

  hash
end

file_type_cache = {
  base_path: base_path,
  file_types: file_types_map
    .values
    .sort_by { |file_type| file_type[:md_item_kind] },
  expire_date: Time.now + CACHE_TTL_MINUTES * 60
}

print YAML.dump(file_type_cache)
