<p align="center">
  <img src="https://taky.s3.amazonaws.com/11nckfunnxkm.svg" width="245">
</p>

`mkay` is a framework that that allows you to develop complex backends quickly
by centralizing the bulk of your work inside of models and libraries.

---

# glancing
- iced/express/mongoose/winston
- mongodb/redis/memcached
- cluster support
- generate everything, produce complex apis rapidly
  - chmod +x bin generators for all significant application files (models,
    crons, routes) in respective folders
- output middleware (`res.respond()`)
  - json/pretty (`?format=json&pretty=1`)
  - jsonp
  - xml
- crud/rest doesn't need to be generated, it's just exposed via model export
  - method override allows for easy testing using the browser (`?method=post`)
  - coffeescript json query filters and sort selectors
  - lean queries and field selection
  - pagination (`?limit=&page=`)
- flexible
  - add custom routes
  - append auto-exposed model crud routes, make cache layers over mongo,
    whatever
  - configure which models/methods/statics you want exposed and which path
    prefixes you want to use
- automatic recognize existence of `./static` and exposes it using
  `express-static`
- automatic recognize existence of `./views/*.hbs` and configures `res.render`
  with `swag.js` and other custom helper methods (`./lib/hbs_helpers`)
- cookie-sessions baked, togglable with config option

# quick start

```bash
git clone https://github.com/tosadvisor/mkay
cd ./mkay
sudo npm i -g iced-coffee-script
npm i
iced app.iced
```

<img src="https://taky.s3.amazonaws.com/81hnpkj7468m.png" width="2046">

### generate a model

```bash
cd ./models
./_create --name friends > friends.iced
```

now you have a rest api and don't have to write routes that wrap the model
methods, the methods can just be exposed directly.

- crud is automatically exposed if `model.AUTO_EXPOSE` is exported
- expose instance methods using `model.AUTO_EXPOSE.methods=[]`
- expose static methods using `model.AUTO_EXPOSE.statics=[]`
- select the path by setting `model.AUTO_EXPOSE.route`, otherwise it will use
  the filename

### create a new "friend"

`http://localhost:10001/friends?method=post&name=John`

- list `/friends`
- view `/friends/:_id`
- edit `/friends/:_id/?method=post&name=James`
- delete `/friends/:_id/?method=delete`

### create/expose a model instance method

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
  statics: []
}
```

now run it through the browser, it converts `req.query` into `opt`, runs the
method and returns the result to the browser

`http://localhost:10001/friends/:_id/change_name?method=post&name=Jose`

---

# global ns pollutants
- `db` mongojs instance
- `db.<Model>` (mongoose models loaded into `db`)
- `redis` ioredis instance
- `memcached` node-memcached instance
- `conf` configuration object
- `eve` eventemitter2 instance
- `log` winston instance
- `ll` alias for console.log
- `lp` alias for console.log pretty print (`JSON.stringify obj, null, 2`)

# auto-loaded
- models located in `./models`
- routes located in `./routes` are loaded using the base file name minus the
  extension as the path prefix
- files in `./cron` are automatically `required`, a bare-bones generator is
  provided
- if `./views` exists `.hbs` files are renderable via `res.render()`
- if `./static` exists it is automatically served using express' static
  middleware

# chmod +x generators
- `./crons/_create`
- `./models/_create`
- `./routes/_create`

