# Be sure to restart your server when you modify this file.

Wripe::Application.config.session_store :cookie_store, {
  key: '_wripe_session',
  expire_after: 2.years
}
