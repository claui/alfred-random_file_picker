#encoding: utf-8

require 'pstore'

CACHE_TTL_MINUTES = 3
EXIT_STATUS_NO_BASE_PATH_GIVEN = 4
EXIT_STATUS_NO_PSTORE_PATH_GIVEN = 5

pstore_path = ARGV.first
if pstore_path.nil? || pstore_path.empty?
  exit EXIT_STATUS_NO_PSTORE_PATH_GIVEN
end

base_path = ENV['base_path']
if base_path.nil?
  exit EXIT_STATUS_NO_BASE_PATH_GIVEN
end

file_types_map =
  $stdin.each.each_slice(3).reduce({}) do |hash, metadata|
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

PStore.new(pstore_path).transaction do |pstore|
  pstore[base_path] = file_type_cache
end
