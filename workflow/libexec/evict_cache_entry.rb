#encoding: utf-8

require 'pstore'

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

PStore.new(pstore_path).transaction do |pstore|
  pstore.delete(base_path)
end
