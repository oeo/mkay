describe '/{{lower}}', ->
  valid_item =
    active: yes
    name: 'George'

  valid_update =
    name: 'John'

  invalid_item = _.clone valid_item
  delete invalid_item.name

  it 'should allow a new document to be created', (done) ->
    await client.post '/{{lower}}', {}, valid_item, defer e,r
    if e then return done e
    done() if r._id

  it 'should validate the document properly', (done) ->
    await client.post '/{{lower}}', {}, invalid_item, defer e,r
    done() if e

  it 'should get a list of items', (done) ->
    await client.get '/{{lower}}', {}, defer e,r
    if e then return done e
    done() if r.items

  it 'should allow one document to be viewed', (done) ->
    await client.get '/{{lower}}', {}, defer e,r
    await client.get '/{{lower}}/' + _.first(r.items)._id, {}, defer e,r
    if e then return done e
    done() if r._id

  it 'should allow one document to be updated', (done) ->
    await client.get '/{{lower}}', {}, defer e,r
    await client.post '/{{lower}}/' + _.first(r.items)._id, {}, valid_update, defer e,r
    if e then return done e
    done() if r._id

  it 'should allow a document to be deleted', (done) ->
    await client.get '/{{lower}}', {}, defer e,list
    await client.delete '/{{lower}}/' + _.first(list.items)._id, {}, defer e,r
    if e then return done e
    await client.get '/{{lower}}/' + _.first(list.items)._id, {}, defer e,r
    done() if r is null

