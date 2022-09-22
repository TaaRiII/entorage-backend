class API < Grape::API
  include Defaults
  mount Devices
  mount Groups
  mount GroupStatuses
  mount Friendships
  mount Matches
  mount Notifications
  mount Photos
  mount Settings
  mount Users
  add_swagger_documentation(
    api_version: 'v1',
    hide_documentation_path: true,
    hide_format: true
  )
end
