module.exports = conf = {
  cluster: off
  port: 10001

  mongo: 'localhost/mkay-api'
  redis: 'localhost'
  memcached: 'localhost'

  cookie_session: {
    enabled: yes
    secret_key: 'MY_UNIQUE_ENCRYPTION_KEY'
  }

  allow_http_method_override: on
  allow_model_exposure: on
  allow_underscore_routes: on

  developer: {
    show_error_stack: on
    debug_ip: '107.181.69.70'
  }
}

