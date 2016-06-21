<p align="xcenter">
  <img src="https://taky.s3.amazonaws.com/41h59xjd1rkk.png" width="250">
</p>

_build scalable rest apis really fast, mkay?_

# mkay framework
- iced/express/mongoose/winston
- mongodb/redis/memcached
- generate everything, produce complex apis rapidly
- cluster supported

# quick start

```bash
git clone https://github.com/tosadvisor/mkay
cd ./mkay
sudo npm i -g iced-coffee-script
npm i --unsafe-perm
iced app.iced
```

### generate a model

```bash
cd ./models
./_create --name friends > friends.iced
```

- crud is automatically exposed if `model.AUTO_EXPOSE` is exported
- expose instance methods using `model.AUTO_EXPOSE.methods=[]`
- expose static methods using `model.AUTO_EXPOSE.statics=[]`

### create a new friend

`http://localhost:10001/friends?method=post&name=John`

- list `/friends`
- view `/friends/:_id`
- edit `/friends/:_id/?method=post&name=James`
- delete `/friends/:_id/?method=delete`

### create and expose a model's instance method

add a method to `FriendsSchema`- auto-exposed methods must always
take an object as the first parameter and a callback as the second

```coffeescript
FriendsSchema.methods.change_name = ((opt={},cb) ->
  if !opt.name then return cb new Error "`opt.name` required"
  @name = opt.name
  @save cb
)
```

now add the function name to the `model.AUTO_EXPOSE.methods` array

```coffeescript
model.AUTO_EXPOSE = {
  route: '/friends'
  methods: [
    'change_name'
  ]
}
```

now run it through the browser, it converts `req.query` into `opt`, runs the
method and returns the result to the browser

`http://localhost:10001/friends/:_id/change_name?method=post&name=Jose`

---

## global ns
- `log` winston instance
- `db` mongojs instance
- `db.<Model>` (mongoose models loaded into `db`)
- `redis` ioredis instance
- `memcached` node-memcached instance
- `conf` configuration object
- `eve` eventemitter2 instance

## auto-loaded
- models located in `./models`
- routes located in `./routes` are loaded using the base file name minus the
  extension as the path prefix
- files in `./cron` are automatically `required`

## chmod +x
- `./crons/_create`
- `./models/_create`
- `./routes/_create`

