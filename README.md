# OmniAuth::Zoom

[![Test](https://github.com/koshilife/omniauth-zoom/workflows/Test/badge.svg)](https://github.com/koshilife/omniauth-zoom/actions?query=workflow%3ATest)
[![codecov](https://codecov.io/gh/koshilife/omniauth-zoom/branch/master/graph/badge.svg)](https://codecov.io/gh/koshilife/omniauth-zoom)
[![Gem Version](https://badge.fury.io/rb/omniauth-zoom.svg)](http://badge.fury.io/rb/omniauth-zoom)
[![license](https://img.shields.io/github/license/koshilife/omniauth-zoom)](https://github.com/koshilife/omniauth-zoom/blob/master/LICENSE.txt)

This gem contains the [zoom.us](https://zoom.us/) strategy for OmniAuth.

## Before You Begin

You should have already installed OmniAuth into your app; if not, read the [OmniAuth README](https://github.com/intridea/omniauth) to get started.

Now sign into the [zoom App Marketplace](https://marketplace.zoom.us/docs/guides) and create an application. Take note of your API keys.

## Using This Strategy

First start by adding this gem to your Gemfile:

```ruby
gem 'omniauth-zoom'
```

If you need to use the latest HEAD version, you can do so with:

```ruby
gem 'omniauth-zoom', :github => 'koshilife/omniauth-zoom'
```

Next, tell OmniAuth about this provider. For a Rails app, your `config/initializers/omniauth.rb` file should look like this:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  zoom_scopes = %i[user:read meeting:read meeting:write]
  provider :zoom, zoom_client_id, zoom_client_secret, :scope => zoom_scopes.join(',')
end
```

Replace `"API_KEY"` and `"API_SECRET"` with the appropriate values you obtained [earlier](https://marketplace.zoom.us/user/build).

## Auth Hash Example

The auth hash `request.env['omniauth.auth']` would look like this:

```js
{
    "result": {
        "provider": "zoom",
        "uid": "KdYKjnimT4KPd8FFgQt9FQ",
        "info": {},
        "credentials": {
            "token": "ACCESS_TOKEN",
            "refresh_token": "REFRESH_TOKEN",
            "expires_at": 1594035991,
            "expires": true
        },
        "extra": {
            "raw_info": {
                "id": "KdYKjnimT4KPd8FFgQt9FQ",
                "first_name": "Jane",
                "last_name": "Dev",
                "email": "jane.dev@email.com",
                "type": 2,
                "role_name": "Owner",
                "pmi": 1234567890,
                "use_pmi": false,
                "vanity_url": "https://janedevinc.zoom.us/my/janedev",
                "personal_meeting_url": "https://janedevinc.zoom.us/j/1234567890",
                "timezone": "America/Denver",
                "verified": 1,
                "dept": "",
                "created_at": "2019-04-05T15:24:32Z",
                "last_login_time": "2019-12-16T18:02:48Z",
                "last_client_version": "4.6.12611.1124(mac)",
                "pic_url": "https://janedev.zoom.us/p/KdYKjnimFR5Td8KKdQt9FQ/19f6430f-ca72-4154-8998-ede6be4542c7-837",
                "host_key": "533895",
                "jid": "kdykjnimt4kpd8kkdqt9fq@xmpp.zoom.us",
                "group_ids": [],
                "im_group_ids": [
                    "3NXCD9VFTCOUH8LD-QciGw"
                ],
                "account_id": "gVcjZnYYRLDbb_MfgHuaxg",
                "language": "en-US",
                "phone_country": "US",
                "phone_number": "+1 1234567891",
                "status": "active"
            }
        }
    }
}
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/koshilife/omniauth-zoom). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the omniauth-zoom project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/koshilife/omniauth-zoom/blob/master/CODE_OF_CONDUCT.md).
