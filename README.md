```
         ,'/
       ,' /
     ,'  /_____,
   .'____    ,'    "mkay"
        /  ,'      an opinionated m/v/route api framework for rapid development
       / ,'
      /,'
```

`mkay` is a framework that that allows you to develop complex backends quickly
by centralizing the bulk of your work inside of models and libraries and generating
everything it can for you.

## prod ready!
- deployed in sls on my professional projects, very high scale (10k+req/s)
- even without lambda or horizontal distribution, a single instance can handle a
  considerable amount of traffic depending on the box specs (running pm2 is probably
  the best for single-instance deployments)
- has served as the backbone to a custom ecom platform processing over 1m$ sales/daily
  - not only processing orders and subscriptions but also recording and analyzing all
    traffic analytics

## features
- node (iced)/express/mongoose
- supported persistence and cache through
  - mongodb
  - redis
  - memcached
- sls friendly
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
  - lean queries, field selection, reference population and pagination
- flexible
  - easily add custom routes
  - configure which models/methods/statics you want exposed and which path
    prefixes you want to use
- automatic recognize existence of `./static` and exposes it using
  `express-static`
- automatic recognize existence of `./views/*.hbs` and configures `res.render`
  with `swag.js` and other custom helper methods (`./lib/hbs_helpers`)
- cookie-sessions baked in, togglable with config option

## quick start

```bash
git clone https://github.com/tosadvisor/mkay
cd ./mkay
sudo npm i -g iced-coffee-script nodemon yarn
yarn
yarn dev
```

<p align="center">
  <img src="https://taky.s3.amazonaws.com/jJuWQEiDvNBcE73RWA3HgW.png" width="742">
</p>

### how to: generate a model

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

### how to: create a new "friend"

`http://localhost:10001/friends?method=post&name=John`

#### generated crud

- list
  - `/friends`
  - w/ pagination options `/friends?per_page=50&offset=0`
  - w/ mongodb query `/friends?filter.1={name:"John"}`
- view one `/friends/:_id`
- update one `/friends/:_id/?method=post&name=James`
- remove one `/friends/:_id/?method=delete`

<p>
  <img src="https://taky.s3.amazonaws.com/LSx4HjgHLFoxfnavUz3F4W.png" width="235">
</p>

### how to: create/expose a model instance method

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

now run it through the browser like this. it converts `req.query` (or `req.body`) into `opt`
and runs the instance method, returning the result to the browser

`http://localhost:10001/friends/:_id/change_name?method=post&name=Jose`

## global ns pollutants
- `db` mongojs instance
- `db.<Model>` (mongoose models loaded into `db`)
- `redis` ioredis instance
- `memcached` node-memcached instance
- `conf` configuration object
- `eve` eventemitter2 instance
- `log` winston instance
- `ll` alias for console.log
- `lp` alias for console.log pretty print (`JSON.stringify obj, null, 2`)

## auto-loaded
- models located in `./models`
- routes located in `./routes` are loaded using the base file name minus the
  extension as the path prefix
- files in `./cron` are automatically `required`, a bare-bones generator is
  provided
- if `./views` exists `.hbs` files are renderable via `res.render()` in custom routes
- if `./static` exists it is automatically served using express' static
  middleware

## command line generators
- `./crons/_create`
- `./models/_create`
- `./routes/_create`

#### contact me

taky@taky.com

```
#### License: MIT

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

