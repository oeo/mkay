<img src="https://taky.s3.amazonaws.com/31gx7jor0psu.png" width="150">

# mkay
- iced
- express
- mongo/mongoose
- redis/memcached
- winston

## dem goals
- to produce very fast development of complex backends by being super opinionated
- to inevitably break some rules, but as few as possible

## quick start
- clone the repo

```bash
cd ./mkay
sudo npm install -g iced-coffee-script
sudo npm install --unsafe-perm
iced app.iced`
```

## create your first model

1. generate the model

  ```bash
  cd ./models
  ./_create --name friends > friends.iced
  ```

  - rest crud is automatically bound if `model.AUTO_EXPOSE` is set
  - you can expose instance methods using `model.AUTO_EXPOSE` as well

1. create a new `friend` using method override, like so

  `http://localhost:10001/friends?method=post&name=John`

  <img src="https://taky.s3.amazonaws.com/91gx71e555s1.png" width="500">

  you can view the document, edit it, delete it, etc using overrides

    - view one: `/friends/:_id`
    - delete: `/friends/:_id/?method=delete`
    - edit: `/friends/:_id/?method=post&name=James`

2. extend the model with custom instance methods and expose them

  add a method to `FriendsSchema`. auto-exposed instance methods must always
  take an object as the first parameter, the second must always be a callback

  ```coffeescript
  FriendsSchema.methods.change_name = ((opt={},cb) ->
    if !opt.name then return cb new Error "`opt.name` required"
    @name = opt.name
    @save cb
  )
  ```

  add the function to the `AUTO_EXPOSE.methods` array at the bottom of the
  file before the export

  ```coffeescript
  model.AUTO_EXPOSE = {
    route: '/friends'
    methods: [
      'change_name'
    ]
  }
  ```

  <img src="https://taky.s3.amazonaws.com/41gx7dyd99km.png" width="500">

  now run it through the browser, it converts `req.query` into `opt`, runs the
  method and returns the result to the browser

  `http://localhost:10001/friends/:_id/change_name?method=post&name=Jose`

  <img src="https://taky.s3.amazonaws.com/81gx7f0decob.png" width="500">

## globals
- `root.log` winston instance
- `root.db` mongojs instance
- `root.db.<Model>` (mongoose models loaded into `db`)
- `root.redis` ioredis instance
- `root.memcached` node-memcached instance
- `root.conf` configuration object
- `root.env` eventemitter2 instance

## autoloaded
- models located in `./models`
- routes located in `./routes` are loaded using the base file name as the route (minus _.iced_)
- files in `./cron` are automatically `required`

all of these file types have generators in their respective folders

## generators
- `./crons/_create`
- `./models/_create`
- `./routes/_create`

