#encoding: utf-8

require 'json'
require 'pstore'

EXIT_STATUS_STALE_CACHE_ENTRY = 2
EXIT_STATUS_NO_CACHE_ENTRY_PRESENT = 3
EXIT_STATUS_NO_BASE_PATH_GIVEN = 4
EXIT_STATUS_NO_CACHE_PATH_GIVEN = 5
EXIT_STATUS_NO_STATE_PATH_GIVEN = 6

REJECT = [
  'com.apple.application-bundle',
  'public.folder',
  'public.volume',
]

cache_filename, state_filename = ARGV
if (cache_filename || '').empty?
  exit EXIT_STATUS_NO_CACHE_PATH_GIVEN
end
if (state_filename || '').empty?
  exit EXIT_STATUS_NO_STATE_PATH_GIVEN
end

base_path = ENV['base_path']
if base_path.nil?
  exit EXIT_STATUS_NO_BASE_PATH_GIVEN
end

file_type_cache = PStore
  .new(cache_filename)
  .transaction(true) { |pstore| pstore.fetch(base_path, nil) }

if file_type_cache.nil?
  exit EXIT_STATUS_NO_CACHE_ENTRY_PRESENT
end

if file_type_cache.fetch(:expire_date) < Time.now
  exit EXIT_STATUS_STALE_CACHE_ENTRY
end

state = PStore
  .new(state_filename)
  .transaction(true) { |pstore| pstore.fetch(:state, {}) }

destination_folder = state[:destination_folder] || ''
has_destination = !destination_folder.empty?

num_files_requested_by_type = if ENV['num_files_requested_by_type']
  JSON.parse(ENV['num_files_requested_by_type'])
else
  {}
end

file_type_map_with_quantities =
  file_type_cache[:file_types].map do |hash|
    hash.merge Hash[
      :num_files_requested,
      num_files_requested_by_type
        .fetch(hash[:md_item_content_type], 0)
        .to_i
    ]
end

script_filter_items = file_type_map_with_quantities
  .reject { |hash| REJECT.include?(hash[:md_item_content_type]) }
  .sort_by { |hash| -(hash[:num_files_requested]) }
  .map do |hash|
  num_files_available = hash[:num_files_available]
  num_files_requested = hash[:num_files_requested]

  if num_files_requested.zero?
    noun_available = num_files_available == 1 ? 'file' : 'files'
    title = hash[:md_item_kind]
    subtitle = [
      "ca. #{num_files_available} #{noun_available} available",
      'press Enter to select quantity'
    ].join('; ')
  else
    noun_requested = num_files_requested == 1 ? 'file' : 'files'
    title = "#{hash[:md_item_kind]} × #{num_files_requested}"
    subtitle = [
      num_files_requested,
      "random #{noun_requested} will be picked",
      "out of ca. #{num_files_available}",
    ].join(' ')
  end

  {
    arg: (num_files_requested.zero? ? '' : num_files_requested),
    autocomplete: hash[:md_item_kind],
    icon: {
      path: hash[:md_item_content_type],
      type: :filetype,
    },
    match: hash[:md_item_kind],
    mods: {
      alt: {
        valid: false,
        subtitle: "Example: #{hash[:md_item_fs_name_example]}",
      },
      cmd: {
        arg: "#{base_path}/#{hash[:md_item_fs_name_example]}",
        subtitle: [
          "Reveal example in Finder:",
          hash[:md_item_fs_name_example]
        ].join(' '),
        variables: {
          action: :reveal,
        },
      },
      ctrl: {
        valid: false,
        subtitle: "Content type: #{hash[:md_item_content_type]}",
      },
    },
    subtitle: subtitle,
    title: title,
    variables: {
      action: :edit_quantity,
      md_item_content_type: hash[:md_item_content_type],
      md_item_fs_name_example: hash[:md_item_fs_name_example],
      md_item_kind: hash[:md_item_kind],
      num_files_available: hash[:num_files_available],
    },
  }
end

has_files_requested = file_type_map_with_quantities.any? do |hash|
  hash[:num_files_requested].nonzero?
end

command_submit = {
  mods: {
    alt: {
      valid: false,
      subtitle: '',
    },
    ctrl: {
      valid: false,
      subtitle: '',
    },
  },
  title: 'Submit and copy random files',
  variables: {
    action: :submit,
  },
}

command_select_folder = {
  mods: {
    alt: {
      valid: false,
      subtitle: '',
    },
    cmd: {
      arg: destination_folder,
      subtitle: 'Reveal folder in Finder',
      valid: has_destination,
      variables: {
        action: :reveal,
      },
    },
    ctrl: {
      valid: false,
      subtitle: '',
    },
  },
  subtitle:
    if has_destination
      'Press Enter to select a different folder'
    else
      'Random files will be copied to this location'
    end,
  title:
    if has_destination
      "Destination: #{destination_folder}"
    else
      'Select destination folder'
    end,
  variables: {
    action: 'choose_destination',
  },
}

command_refresh = {
  mods: {
    alt: {
      valid: false,
      subtitle: '',
    },
    ctrl: {
      valid: false,
      subtitle: '',
    },
  },
  title: 'Refresh file types',
  variables: {
    action: :refresh,
  },
}

script_filter_message = {
  items: [
    (command_submit if has_files_requested && has_destination),
    command_select_folder,
    *script_filter_items,
    command_refresh,
  ].compact,
  variables: {
    action: nil,
    md_item_content_type: nil,
    num_files_requested_by_type:
      num_files_requested_by_type.to_json,
  }
}

print script_filter_message.to_json
