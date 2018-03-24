#encoding: utf-8

require 'json'

base_path = ENV['base_path']
md_item_content_type = ENV['md_item_content_type']
md_item_fs_name_example = ENV['md_item_fs_name_example']
md_item_kind = ENV['md_item_kind']

quantities_json = ENV['quantities_json']
quantities = quantities_json ? JSON.parse(quantities_json) : {}
quantity = quantities.fetch(md_item_content_type, 0).to_i

new_quantity = ENV['new_quantity'].to_i

command_discard = {
  title: 'Discard changes',
  subtitle: "and keep previous quantity of #{quantity}",
}

if new_quantity == 0
  title = 'Enter a quantity'
  subtitle = "for the file type #{md_item_kind}"
else
  title = "#{md_item_kind} × #{new_quantity}"
  subtitle = [
    new_quantity,
    'random files of this type will be picked',
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
    quantities_json: quantities
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
