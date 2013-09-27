# CanvasOauth

CanvasOauth is a mountable engine for handling the oauth workflow with canvas
and making api calls from your rails app.  This is tested with Rails 3.2, we'll
be looking at verifying with Rails 4 soon.

## Installation

Add the gem to your `Gemfile` with the following line, and then `bundle install`

```
gem 'canvas_oauth'
```

Then, mount the engine to your app by adding this line to your `routes.rb` file

```
mount CanvasOauth::Engine => "/canvas_oauth"
```

Next, include the engine in your `ApplicationController`

```
class ApplicationController < ActionController::Base
  include CanvasOauth::CanvasApplication
  
  ...
end
```

After that, create an `canvas.yml` file in your `config/` folder that looks something
like this:

```
default: &default
  key: your_key
  secret: your_secret

development:
  <<: *default

test:
  <<: *default

production:
  <<: *default
```

The values of key and secret should be set from the developer key that you
generate in the canvas application.

Finally, run migrations:

```
bundle exec rake db:migrate
```

This will create the `canvas_oauth_authorizations` table which stores
successful oauth tokens for later use, so the user does not have to accept the
oauth login each time they use the app.

## Usage

The engine only uses one url, whatever it is mounted to, to serve as the
`redirect_url` in the oauth workflow.

The engine sets up a global `before_filter`, which checks for a valid oauth
token, and if one does not exist, starts the oauth login flow.  It handles
posting the oauth request, verifying the result and redirecting to the
application root. It exposes the following methods to your controllers:

  * `canvas`
  * `canvas_token`

The first is an instance of HTTParty ready to make api requests to your canvas
application.  The second is if you need access to the oauth token directly.

## Configuring the Tool Consumer

You will a developer key and secret from canvas, which should be entered into
you `canvas.yml` file.

## Example

You can see and interact with an example of an app using this engine by looking
at `spec/dummy`.  This is a full rails app which integrates the gem and has
a simple index page that says 'Hello Oauth' if the app is launched and the
oauth flow is successful.

## About Oauth

TODO...

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
