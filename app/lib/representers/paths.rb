module Representers
  class Paths
    include Rails.application.routes.url_helpers

    def self.call(options={})
      new(options).()
    end

    def initialize(options={})
      @options = options
    end

    def call
      build_paths
    end

    private

    def build_paths
      {
        loginPath: login_path,
        logoutPath: logout_path
      }
    end
  end
end
