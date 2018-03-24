#encoding: utf-8

require 'fileutils'
require 'json'
require 'pstore'
require 'securerandom'

EXIT_STATUS_NO_BASE_PATH_GIVEN = 4
EXIT_STATUS_NO_STATE_PATH_GIVEN = 6
EXIT_STATUS_NO_DESTINATION_GIVEN = 8
EXIT_STATUS_NOT_ENOUGH_FILES = 9

base_path = ENV['base_path']
if base_path.nil?
  exit EXIT_STATUS_NO_BASE_PATH_GIVEN
end

state_filename = ARGV.first
if (state_filename || '').empty?
  exit EXIT_STATUS_NO_STATE_PATH_GIVEN
end

state = PStore
  .new(state_filename)
  .transaction(true) { |pstore| pstore.fetch(:state, {}) }

destination_folder = state[:destination_folder] || ''
if destination_folder.empty?
  exit EXIT_STATUS_NO_DESTINATION_GIVEN
end

num_files_requested_by_type = if ENV['num_files_requested_by_type']
  JSON.parse(ENV['num_files_requested_by_type'])
else
  {}
end

files_by_type = Hash.new { |hash, key| hash[key] = [] }

$stdin.each.each_slice(3) do |metadata|
  md_item_content_type = metadata[0].chomp
  md_item_fs_name = metadata[1].chomp
  files_by_type[md_item_content_type] <<
    "#{base_path}/#{md_item_fs_name}"
end

files_picked = num_files_requested_by_type
  .flat_map do |md_item_content_type, number_of_files_requested|
  available_filenames = files_by_type[md_item_content_type]
  number_of_files_requested.times.map do |number_of_files_picked|
    if available_filenames.empty?
      warn [
        "Not enough files of type #{md_item_content_type}",
        "requested: #{number_of_files_requested}",
        "available: #{number_of_files_picked}",
      ].join('; ')
      exit EXIT_STATUS_NOT_ENOUGH_FILES
    end

    random_index =
      SecureRandom.random_number(available_filenames.size)
    available_filenames.delete_at(random_index)
  end
end

FileUtils.cp files_picked, destination_folder

noun = files_picked.size == 1 ? 'file' : 'files'
print "#{files_picked.size} #{noun} copied"
