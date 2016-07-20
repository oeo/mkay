module.exports = conf = {
  mongo: 'localhost/mkay-api'
  redis: 'localhost'
  memcached: 'localhost'

  cluster: off

  api: {
    port: 10001
    url: 'http://127.0.0.1:10001'
    auth: null
  }

  allow_http_method_override: on
  allow_model_exposure: on

  developer:
    show_error_stack: on
    debug_ip: '107.181.69.70'
}

