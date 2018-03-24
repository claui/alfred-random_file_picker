#encoding: utf-8

require 'pstore'

EXIT_STATUS_NO_STATE_PATH_GIVEN = 6
EXIT_STATUS_NO_KEY_GIVEN = 7

state_filename, key, value = ARGV
if (state_filename || '').empty?
  exit EXIT_STATUS_NO_STATE_PATH_GIVEN
end
if (key || '').empty?
  exit EXIT_STATUS_NO_KEY_GIVEN
end

PStore.new(state_filename).transaction do |pstore|
  state = pstore.fetch(:state, {})
  if (value || '').empty?
    state.delete(key.to_sym)
  else
    state[key.to_sym] = value
  end
  pstore[:state] = state
end
