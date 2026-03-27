# Discourse SSO Token Plugin

A Discourse plugin that captures a token from a query parameter and appends it to SSO requests.

## Features

- Captures a token from a configurable query parameter
- Stores the token in the user's session
- Automatically appends the token to SSO authentication requests
- Configurable through Discourse site settings

## Installation

1. Clone this repository into your Discourse plugins directory:
   ```bash
   cd /var/discourse/plugins
   git clone https://github.com/cyberjab/discourse-sso-token-plugin.git
   ```

2. Rebuild your Discourse container:
   ```bash
   cd /var/discourse
   ./launcher rebuild app
   ```

## Configuration

After installation, configure the plugin through the Discourse admin panel:

1. Go to **Admin > Site Settings**
2. Search for "sso_token"
3. Configure the following settings:

| Setting | Default | Description |
|---------|---------|-------------|
| `sso_token_enabled` | `true` | Enable or disable the SSO token capture and forwarding |
| `sso_token_param_name` | `token` | Name of the query parameter to capture the token from |
| `sso_token_session_key` | `sso_token` | Session key used to store the token |

## Usage

### Capturing a Token

To capture a token, simply include the token parameter in any URL to your Discourse site:

```
https://your-discourse-site.com?token=your-token-value
```

The token will be automatically captured and stored in the user's session when they visit any page with the token parameter. You can also redirect users to specific pages:

```
https://your-discourse-site.com/latest?token=your-token-value
https://your-discourse-site.com/categories?token=your-token-value
```

### SSO Integration

When a user authenticates via SSO, the captured token will be automatically appended to the SSO URL as a query parameter:

```
https://your-sso-provider.com/sso?sso=...&sig=...&token=your-token-value
```

## How It Works

1. **Token Capture**: When a user visits any page on your Discourse site with the token parameter in the URL (e.g., `?token=your-token-value`), the plugin automatically captures the token and stores it in the user's session.

2. **Token Storage**: The token is stored in the session using the configured session key (`sso_token` by default).

3. **Token Forwarding**: When the user authenticates via SSO, the plugin hooks into the SSO process and appends the token to the SSO URL.

## Development

### File Structure

```
discourse-sso-token-plugin/
├── plugin.rb                          # Main plugin file
├── config/
│   ├── settings.yml                   # Site settings
│   └── locales/
│       └── client.en.yml              # English translations
├── lib/
│   └── sso_token_modifier.rb          # SSO URL modifier
└── README.md                          # This file
```

### Key Components

- **ApplicationController before_action**: Captures token from any page URL and stores in session
- **SSOTokenModifier**: Modifies the SSO URL to include the captured token
- **Settings**: Configurable site settings for the plugin

## License

This plugin is released under the MIT License.

## Author

CyberJab

## Support

For issues and feature requests, please open an issue on the [GitHub repository](https://github.com/cyberjab/discourse-sso-token-plugin/issues).
# discourse-sso-token-plugin
