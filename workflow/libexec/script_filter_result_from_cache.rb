#encoding: utf-8

require 'json'
require 'pstore'

EXIT_STATUS_STALE_CACHE_ENTRY = 2
EXIT_STATUS_NO_CACHE_ENTRY_PRESENT = 3
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

file_type_cache =
  PStore.new(pstore_path).transaction(true) do |pstore|
  pstore.fetch(base_path, nil)
end

if file_type_cache.nil?
  exit EXIT_STATUS_NO_CACHE_ENTRY_PRESENT
end

if file_type_cache.fetch(:expire_date) < Time.now
  exit EXIT_STATUS_STALE_CACHE_ENTRY
end

quantities_json = ENV['quantities_json']
quantities = quantities_json ? JSON.parse(quantities_json) : {}

file_type_map_with_quantities =
  file_type_cache[:file_types].map do |hash|
    hash.merge Hash[
      :quantity,
      quantities
        .fetch(hash[:md_item_content_type], 0)
        .to_i
    ]
end

script_filter_items = file_type_map_with_quantities
  .sort_by { |hash| -(hash[:quantity]) }
  .map do |hash|
  quantity = hash[:quantity]

  if quantity.zero?
    title = hash[:md_item_kind]
    subtitle = 'Press Enter to select quantity'
  else
    title = "#{hash[:md_item_kind]} × #{quantity}"
    subtitle = [
      quantity,
      'random files of this type will be picked',
    ].join(' ')
  end

  {
    arg: (quantity.zero? ? '' : quantity),
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
        subtitle: '',
      },
    },
    subtitle: subtitle,
    title: title,
    variables: {
      action: :edit_quantity,
      md_item_content_type: hash[:md_item_content_type],
      md_item_fs_name_example: hash[:md_item_fs_name_example],
      md_item_kind: hash[:md_item_kind],
    },
  }
end

has_quantity = file_type_map_with_quantities.any? do |hash|
  hash[:quantity].nonzero? 
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
    (command_submit if has_quantity),
    *script_filter_items,
    command_refresh,
  ].compact,
  variables: {
    action: nil,
    md_item_content_type: nil,
    quantities_json: quantities.to_json
  }
}

print script_filter_message.to_json
