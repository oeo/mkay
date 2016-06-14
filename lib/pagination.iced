# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
_ = require('wegweg')({
  globals: off
})

module.exports = pagination = (opts={}) ->
  opts.total ?= 0
  opts.cur_page ?= 0
  opts.per_page ?= 10
  opts.num_buttons ?= 2
  opts.show_first ?= yes
  opts.show_last ?= yes
  opts.arrow_mode ?= no

  if _.type(opts.cur_page) is 'string'
    try opts.cur_page = parseInt opts.cur_page

  pages_total = opts.total/opts.per_page
  pages_total = Math.ceil(pages_total) - 1

  pages = []

  cur_offset = (opts.per_page * opts.cur_page)

  for x in [0..pages_total]
    tmp = [
      (opts.per_page * x)
      (opts.per_page * (x + 1))
    ]

    if tmp[1] >= opts.total
      tmp[1] = opts.total

    tmp_obj = {
      page_num: x
      label: x + 1
      min_offset: tmp[0]
      max_offset: tmp[1]
    }

    if tmp_obj.page_num is 0
      tmp_obj.first = yes

    if tmp_obj.page_num is pages_total
      tmp_obj.last = yes

    pages.push tmp_obj

  result =
    label_index_min: (do ->
      min = opts.per_page * opts.cur_page
      if min is 0
        min = 1
      min
    )
    label_index_max: (do ->
      max = (opts.cur_page + 1) * opts.per_page
      if max > opts.total
        max = opts.total
      max
    )
    offset: (opts.per_page * opts.cur_page)
    page: opts.cur_page
    page_label: opts.cur_page + 1
    page_total_label: pages_total + 1
    total: opts.total
    links: []

  used = []
  links = []

  active_page_index = null

  i = 0
  for x in pages
    if x.page_num is opts.cur_page
      active_page_index = i
      break
    ++ i

  active_page = _.clone pages[active_page_index]
  active_page.active = yes

  used.push 'first' if active_page.first
  used.push 'last' if active_page.last

  try delete active_page.first
  try delete active_page.last

  links.push active_page
  used.push active_page_index

  for x in [1..opts.num_buttons]
    tmp_index = (active_page_index) - x

    if pages[tmp_index] and tmp_index !in used
      page_clone = _.clone pages[tmp_index]
      try delete page_clone.first
      try delete page_clone.last
      links.push page_clone
      used.push 'last' if pages[tmp_index].last
      used.push 'first' if pages[tmp_index].first
      used.push tmp_index

    tmp_index = (active_page_index) + x

    if pages[tmp_index] and tmp_index !in used
      page_clone = _.clone pages[tmp_index]
      try delete page_clone.first
      try delete page_clone.last
      links.push page_clone
      used.push 'last' if pages[tmp_index].last
      used.push 'first' if pages[tmp_index].first
      used.push tmp_index

  if opts.show_first and 'first' !in used
    if !_.find(links,first:yes)
      links.push(_.find(pages,first:yes))

  if opts.show_last and 'last' !in used
    if !_.find(links,last:yes)
      links.push(_.find(pages,last:yes))

  result.links = _.sortBy links, (item) -> item.page_num
  result.links = [] if result.links.length is 1

  # only previous and next arrows
  delete result.links if result.links.length is 1

  if opts.arrow_mode and result.links
    new_links = []

    i = 0

    for x in result.links
      if !x.active
        ++ i
      else
        break

    if result.links[i - 1]
      tmp_item = _.clone result.links[i - 1]
      tmp_item.prev = yes
      new_links.push tmp_item

    if result.links[i + 1]
      tmp_item = _.clone result.links[i + 1]
      tmp_item.next = yes
      new_links.push tmp_item

    result.links = new_links

  if result.total is 0
    result.links = []
    result.page_total_label = 1
    result.has_items = no
  else
    result.has_items = yes

  result

###
opts = {
  total: 70
  cur_page: 6
  per_page: 10
  num_buttons: 1
  show_first: yes
  show_last: yes
}

lp pagination opts

{
  "offset": 60,
  "page": 6,
  "page_label": 7,
  "page_total_label": 7,
  "total": 70,
  "links": [
    {
      "page_num": 0,
      "label": 1,
      "min_offset": 0,
      "max_offset": 10,
      "first": true
    },
    {
      "page_num": 5,
      "label": 6,
      "min_offset": 50,
      "max_offset": 60
    },
    {
      "page_num": 6,
      "label": 7,
      "min_offset": 60,
      "max_offset": 70,
      "active": true
    }
  ]
}
###

