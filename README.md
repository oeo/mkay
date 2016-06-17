<p align="center">
  <img src="https://taky.s3.amazonaws.com/21h0irbz7y0l.png" width="429">
</p>

# mkay
iced/express/mongo/mongoose/redis/memcached/winston

build scalable apis really, really fast, mkay?

## dem goals
- to produce very fast development of complex backends by being super opinionated
- to inevitably break some rules, but as few as possible

## quick start
clone the repo

```bash
git clone https://github.com/tosadvisor/mkay
cd ./mkay
sudo npm install -g iced-coffee-script
sudo npm install --unsafe-perm
iced app.iced
```

## create a model

1. use the generator

  ```bash
  cd ./models
  ./_create --name friends > friends.iced
  ```

  - rest crud is automatically bound if `model.AUTO_EXPOSE` is exported
  - you can expose instance methods using `model.AUTO_EXPOSE.methods`
  - you can expose static methods using `model.AUTO_EXPOSE.statics`

1. create a new `friend` using http method override, like so

  `http://localhost:10001/friends?method=post&name=John`

  <img src="https://taky.s3.amazonaws.com/91gx71e555s1.png" width="250">

  you can view the document, edit it, delete it, etc using overrides

    - list: `/friends`
    - view: `/friends/:_id`
    - edit: `/friends/:_id/?method=post&name=James`
    - delete: `/friends/:_id/?method=delete`

2. extend the model with an instance method and expose it to http

  add a method to `FriendsSchema`. automatically exposed methods must always
  take an object as the first parameter, the second must always be a callback

  ```coffeescript
  FriendsSchema.methods.change_name = ((opt={},cb) ->
    if !opt.name then return cb new Error "`opt.name` required"
    @name = opt.name
    @save cb
  )
  ```

  add the function name to the `AUTO_EXPOSE.methods` array

  ```coffeescript
  model.AUTO_EXPOSE = {
    route: '/friends'
    methods: [
      'change_name'
    ]
  }
  ```

  <img src="https://taky.s3.amazonaws.com/41gx7dyd99km.png" width="250">

  now run it through the browser, it converts `req.query` into `opt`, runs the
  method and returns the result to the browser

  `http://localhost:10001/friends/:_id/change_name?method=post&name=Jose`

  <img src="https://taky.s3.amazonaws.com/81gx7f0decob.png" width="250">

## globals
- `log` winston instance
- `db` mongojs instance
- `db.<Model>` (mongoose models loaded into `db`)
- `redis` ioredis instance
- `memcached` node-memcached instance
- `conf` configuration object
- `eve` eventemitter2 instance

## autoloaded
- models located in `./models`
- routes located in `./routes` are loaded using the base file name as the path prefix (minus _.iced_)
- files in `./cron` are automatically `required`

all of these file types have generators in their respective folders

## chmod+x helpy helpers
- `./crons/_create`
- `./models/_create`
- `./routes/_create`

