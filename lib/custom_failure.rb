class CustomFailure < Devise::FailureApp
  # As per https://github.com/plataformatec/devise/wiki/
  # How-To:-Redirect-to-a-specific-page-when-the-user-can-not-be-authenticated

  def redirect_url
    new_user_session_url#(subdomain: 'secure')
  end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
