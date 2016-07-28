module.exports = conf = {

  # storage
  mongo: 'localhost/mkay-api'
  redis: 'localhost'
  memcached: 'localhost'

  # cluster
  cluster: off

  # api
  api: {
    port: 10001
    auth: null
  }

  cookie_session: {
    enabled: yes
    secret_key: 'MY_UNIQUE_ENCRYPTION_KEY'
  }

  # global settings
  allow_http_method_override: on
  allow_model_exposure: on

  # developer settings
  developer:
    show_error_stack: on
    debug_ip: '107.181.69.70'

}

