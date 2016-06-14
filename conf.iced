module.exports = conf = {
  mongo: 'localhost/basic-api'
  redis: 'localhost'
  memcached: 'localhost'

  cluster: off

  api: {
    port: 10001
    url: 'http://127.0.0.1:10001/v1'
    auth: null
  }

  allow_http_method_override: on

  developer:
    show_error_stack: on
}

