local record dom
  record Element
  end

  record Document
  end

  interface Event
    target: Element
    type: string
  end

  query: function(selector: string): Element | nil
  create: function(tag: string): Element
  body: function(): Element

  append: function(parent: Element, child: Element)
  remove: function(element: Element)

  text: function(element: Element): string
  set_text: function(element: Element, text: string)

  html: function(element: Element): string
  set_html: function(element: Element, html: string)

  attr: function(element: Element, name: string): string | nil
  set_attr: function(element: Element, name: string, value: string)

  style: function(element: Element, name: string): string
  set_style: function(element: Element, name: string, value: string)

  value: function(element: Element): string
  set_value: function(element: Element, value: string)

  on: function(element: Element, event: string, listener: function(event: Event))
end
