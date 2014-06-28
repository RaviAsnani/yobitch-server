RailsAdmin.config do |config|

  config.authenticate_with do
    config.authorize_with do
      authenticate_or_request_with_http_basic('Site Message') do |username, password|
        username == 'yobitch' && password == 'rumlabs@2014'
      end
    end
  end

  config.actions do
    dashboard
    index
    new
    export
    bulk_delete
    show
    edit
    delete
    # show_in_app
  end

end
