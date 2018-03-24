#encoding: utf-8

require 'json'

base_path = ENV['base_path']
md_item_content_type = ENV['md_item_content_type']
md_item_fs_name_example = ENV['md_item_fs_name_example']
md_item_kind = ENV['md_item_kind']

num_files_requested_by_type = if ENV['num_files_requested_by_type']
  JSON.parse(ENV['num_files_requested_by_type'])
else
  {}
end

num_files_available = ENV['num_files_available']
num_files_requested = num_files_requested_by_type
  .fetch(md_item_content_type, 0)
  .to_i

new_quantity = ENV['new_quantity'].to_i

command_discard = {
  title: 'Discard changes',
  subtitle: "and keep previous quantity of #{num_files_requested}",
}

if new_quantity == 0
  noun_available = num_files_available == 1 ? 'file' : 'files'
  title = 'Enter a quantity'
  subtitle = [
    "for the file type #{md_item_kind}",
    "ca. #{num_files_available} available",
  ].join('; ')
else
  noun_requested = new_quantity == 1 ? 'file' : 'files'
  title = "#{md_item_kind} × #{new_quantity}"
  subtitle = [
    new_quantity,
    "random #{noun_requested} will be picked",
    "out of ca. #{num_files_available}",
  ].join(' ')
end

quantity_editor = {
  mods: {
    alt: {
      valid: false,
      subtitle: "Example: #{md_item_fs_name_example}",
    },
    cmd: {
      arg: "#{base_path}/#{md_item_fs_name_example}",
      subtitle: [
        "Reveal example in Finder:",
        md_item_fs_name_example,
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
  icon: {
    path: md_item_content_type,
    type: :filetype,
  },
  subtitle: subtitle,
  title: title,
  variables: {
    num_files_requested_by_type: num_files_requested_by_type
      .merge(Hash[md_item_content_type, new_quantity])
      .to_json,
  },
}

script_filter_message = {
  items: [
    quantity_editor,
    command_discard,
  ],
  variables: {
    action: :list_file_types,
  },
}

print script_filter_message.to_json
