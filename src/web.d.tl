local fs = require("fs")
local async = require("async")

local record web
  record Element
  end
  record Document
  end
  record Blob
  end
  record Object
  end
  interface Event
    target: Element
    type: string
  end

  console: function(...: any)
  query: function(selector: string): Element | nil
  create: function(tag: string): Element
  body: function(): Element
  append: function(parent: Element, child: Element)
  remove: function(parent: Element, child: Element)
  get_text: function(element: Element): string
  set_text: function(element: Element, text: string)
  get_html: function(element: Element): string
  set_html: function(element: Element, html: string)
  get_attr: function(element: Element, name: string): string | nil
  set_attr: function(element: Element, name: string, value: string)
  get_style: function(element: Element, name: string): string
  set_style: function(element: Element, name: string, value: string)
  get_value: function(element: Element): string
  set_value: function(element: Element, value: string)
  get_prop: function(object: Object, name: string | integer): any | function(x: any)
  set_prop: function(object: Object, name: string | integer, value: any)
  on: function(element: Element, event: string, listener: function(event: Event))
  off: function(element: Element, event: string, listener: function(event: Event))
  once: function(element: Element, event: string, listener: function(event: Event))
  revoke_object_url: function(url: string)
  create_object_url: function(blob: Blob): string
  new_blob: function(data: Object): Blob
  set_timeout: function(callback: function(), delay: integer)
  array_buffer: function(data: Blob): async.Aff<fs.Buffer>
  click: function(element: Element)
end

return web