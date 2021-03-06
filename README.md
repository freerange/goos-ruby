## GOOS Ruby

This repository contains a history of me working through the example in the [GOOS book](http://www.growing-object-oriented-software.com/) using Ruby instead of Java.

### Prerequisites

- JRuby (tested with v1.6.7 installed via `rbenv`)
- [Openfire](http://www.igniterealtime.org/projects/openfire/) (tested with v3.7.1)
- Bundler (tested with v1.1.4)
- All only tested on Mac OSX v10.8.4

### Openfire XMPP server

Setup & configuration as per "Setting Up the Openfire Server" in chapter 11.

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
  - Create New User x 3
    - Username: sniper; Password: sniper
    - Username: auction-item-54321; Password: auction
    - Username: auction-item-65432; Password: auction
- Server
  - Server Settings
    - Resource Policy
      - Set Conflict Policy: Never kick (non-default)
