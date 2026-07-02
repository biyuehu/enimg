local async = require("async")
local limp = require("limp")
local enimg = require("enimg")
local web = require("web")

local preview = web.query("#preview")
local placeholder = web.query("#placeholder")
local file_input = web.query("#file")
local loading = web.query("#loading")

local buffer: web.Object | nil = nil
local preview_url: string | nil = nil

local function set_loading(v: boolean)
  if v then
    web.set_attr(loading, "class", "loading")
  else
    web.set_attr(loading, "class", "loading hidden")
  end
end

local function show_image(blob: web.Blob)
  if preview_url ~= nil then
    web.revoke_object_url(preview_url)
  end

  preview_url = web.create_object_url(blob)

  web.set_attr(preview, "src", preview_url)
  web.set_style(preview, "display", "block")
  web.set_style(placeholder, "display", "none")
end

web.on(web.query("#upload"), "click", function()
  web.console(file_input, web.get_prop(file_input as web.Object, "click"))
  web.click(file_input)
end)

web.on(file_input, "change", function()
  local file = web.get_prop(web.get_prop(file_input as web.Object, "files") as web.Object, 0) as web.Object | nil
  if file == nil then
    return
  end
  set_loading(true)
  async.next(web.array_buffer(file as web.Blob), function(data: any): nil
    buffer = data as web.Object
    show_image(file as web.Blob)
    set_loading(false)
  end)
end)

web.on(web.query("#encode"), "click", function()
  if buffer == nil then
    return
  end
  set_loading(true)
  async.next(limp.read(buffer), function(img: limp.Image): nil
    async.next(limp.write(enimg.encode_image(img)), function(data: any): nil
      buffer = data as web.Object
      show_image(web.new_blob(buffer))
      set_loading(false)
    end)
  end)

end)

web.on(web.query("#decode"), "click", function()
  if buffer == nil then
    return
  end
  async.next(limp.read(buffer), function(img: limp.Image): nil
    async.next(limp.write(enimg.decode_image(img)), function(data: any): nil
      buffer = data as web.Object
      show_image(web.new_blob(buffer))
    end)
  end)
end)

web.on(web.query("#download"), "click", function()
  if buffer == nil then
    return
  end
  local blob = web.new_blob(buffer)
  local url = web.create_object_url(blob)
  local a = web.create("a")
  web.set_attr(a, "href", url)
  web.set_attr(a, "download", "image.png")
  web.append(web.body(), a)
  web.click(a)
  web.remove(web.body(), a)
  web.set_timeout(function()
    web.revoke_object_url(url)
  end, 1000)
end)
