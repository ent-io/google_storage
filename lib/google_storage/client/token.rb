module GoogleStorage
  class Client

    def authorization_url(scope)
      scope_url = case scope
        when :read_only
          'https://www.googleapis.com/auth/devstorage.read_only'
        when :read_write
          'https://www.googleapis.com/auth/devstorage.read_write'
        when :full_control
          'https://www.googleapis.com/auth/devstorage.full_control'
        else
          'https://www.google.com/m8/feeds/'
        end

      auth_url = "https://accounts.google.com/o/oauth2/auth?"
      auth_url += "client_id=#{@config.client_id}&"
      auth_url += "redirect_uri=#{@config.redirect_uri}&"
      auth_url += "scope=#{scope_url}&"
      auth_url += "response_type=code&"
      auth_url += "access_type=offline&"
      auth_url += "approval_prompt=force"

      return auth_url
    end

    def acquire_refresh_token(token, options={})
      options['grant_type'] = 'authorization_code'
      response = post_request('accounts.google.com', '/o/oauth2/token', token, options)
      return response["refresh_token"] if response["refresh_token"]
      "Failed to acquire a refresh token. Something went wrong. Try getting a new Auth code."
    end

    def refresh_access_token(options={})
      options['grant_type'] = 'refresh_token'
      response = post_request(
        'accounts.google.com', '/o/oauth2/token', @config.refresh_token, options
      )
      after_refresh_access_token(response)
      response
    end

    protected

    def after_refresh_access_token(response)
      # placeholder monkeypatched by test suite
    end

  end
end
