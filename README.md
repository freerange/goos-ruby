## Gosling

Attempt at translating GOOS book worked example into Ruby.

### Prerequisites

- JRuby (tested with v1.6.7 installed via `rbenv`)
- [Openfire](http://www.igniterealtime.org/projects/openfire/) (tested with v3.7.1)
- Bundler (tested with v1.1.4)
- All only tested on Mac OSX v10.7.4

### Openfire XMPP server

#### Setup (via web wizard)

- Language Selection: English (default)
- Server Settings
  - Domain: localhost (non-default)
  - Admin Console Port: 9090 (default)
  - Secure Admin Console Port: 9091 (default)
- Database Settings: Embedded Database (non-default)
- Profile Settings: Default (default)
- Administrator Account
  - Admin Email Address: admin@example.com (default)
  - Password: admin
  - Confirm password: admin

#### Configure (via web admin console)

- Login credentials
  - Username: admin
  - Password: admin
- User/Groups
  - Create New User # as per "Setting Up the Openfire Server" in chapter 11
    - Username: sniper; Password: sniper
    - Username: auction-item-54321; Password: auction
    - Username: auction-item-65432; Password: auction

