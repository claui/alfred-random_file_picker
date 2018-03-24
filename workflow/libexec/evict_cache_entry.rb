#encoding: utf-8

require 'pstore'

EXIT_STATUS_NO_BASE_PATH_GIVEN = 4
EXIT_STATUS_NO_PSTORE_PATH_GIVEN = 5

cache_filename = ARGV.first
if (cache_filename || '').empty?
  exit EXIT_STATUS_NO_PSTORE_PATH_GIVEN
end

base_path = ENV['base_path']
if base_path.nil?
  exit EXIT_STATUS_NO_BASE_PATH_GIVEN
end

PStore.new(cache_filename).transaction do |pstore|
  pstore.delete(base_path)
end
