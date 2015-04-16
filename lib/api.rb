require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
require 'google/api_client/auth/storage'
require 'google/api_client/auth/storages/file_store'
require 'fileutils'

require 'api/free_busy'

class Api

  APPLICATION_NAME = 'meeting-rooms-madness'
  CLIENT_SECRETS_PATH = File.join(File.dirname(__FILE__), '..', 'config', 'client_secret.json')
  CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                               "calendar-api-quickstart.json")
  SCOPE = 'https://www.googleapis.com/auth/calendar'

  def self.client
    @@client ||= begin
      client = Google::APIClient.new(:application_name => APPLICATION_NAME)
      client.authorization = authorize
      client
    end
  end

  def self.calendar_api
    @@calendar_api ||= client.discovered_api('calendar', 'v3')
  end

  def self.authorize
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

    file_store = Google::APIClient::FileStore.new(CREDENTIALS_PATH)
    storage = Google::APIClient::Storage.new(file_store)
    auth = storage.authorize

    if auth.nil? || (auth.expired? && auth.refresh_token.nil?)
      app_info = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_PATH)
      flow = Google::APIClient::InstalledAppFlow.new({
        :client_id => app_info.client_id,
        :client_secret => app_info.client_secret,
        :scope => SCOPE})
      auth = flow.authorize(storage)
      puts "Credentials saved to #{CREDENTIALS_PATH}" unless auth.nil?
    end
    auth
  end

  private_class_method :authorize

end
