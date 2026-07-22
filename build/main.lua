local async = require("async")
local limp = require("limp")
local mikoto = require("mikoto")
local web = require("web")
local utils = require("utils")

local function el(tag, class)
   local e = web.create(tag)
   if class ~= nil then
      web.set_attr(e, "class", class)
   end
   return e
end

local function el_id(tag, id, class)
   local e = el(tag, class)
   web.set_attr(e, "id", id)
   return e
end

local function button(id, label)
   local b = el_id("button", id, nil)
   web.set_attr(b, "type", "button")
   web.set_text(b, label)
   return b
end

local entry = web.query("#teal-entry")
if entry == nil then
   web.console(" #teal-entry")
   return
end

local container = el("div", "container")
local loading = el_id("div", "loading", "loading hidden")
local spinner = el("div", "spinner")
web.append(loading, spinner)
local loading_text = el("div", "text")
web.set_text(loading_text, "Processing...")
web.append(loading, loading_text)
web.append(container, loading)

local preview_wrap = el("div", "preview")
local img = el_id("img", "preview", nil)
web.set_attr(img, "alt", "preview")
web.append(preview_wrap, img)

local placeholder = el_id("div", "placeholder", nil)
local icon = el("div", "icon")
web.set_text(icon, utils.icon)
web.append(placeholder, icon)
local placeholder_text = el("div", "text")
web.set_text(placeholder_text, "No image uploaded yet.")
web.append(placeholder, placeholder_text)
web.append(preview_wrap, placeholder)
web.append(container, preview_wrap)

local actions = el("div", "actions")
web.append(actions, button("upload", "Upload"))
web.append(actions, button("encode", "Encode"))
web.append(actions, button("decode", "Decode"))
web.append(actions, button("download", "Download"))
web.append(container, actions)
web.append(entry, container)

local file_input = el_id("input", "file", nil)
web.set_attr(file_input, "type", "file")
web.set_attr(file_input, "accept", "image/*")
web.append(entry, file_input)

local footer = el("footer", "app-footer")
local footer_line1 = el("div", "footer-line footer-line-teal")
local footer_link = el("a", "footer-line-teal")
web.set_attr(footer_link, "href", "https://github.com/biyuehu/mikoto")
web.set_attr(footer_link, "target", "_blank")
web.set_attr(footer_link, "rel", "noopener noreferrer")
web.set_text(footer_link, "mikoto")
web.append(footer_line1, footer_link)
web.append(footer, footer_line1)
local footer_line2 = el("div", "footer-line footer-line-sub")
web.set_text(footer_line2, "By Arimura Sena | Teal + Vite + Bun")
web.append(footer, footer_line2)
web.append(entry, footer)

local preview = web.query("#preview")
local buffer = nil
local preview_url = nil

local function show_image(blob)
   if preview_url ~= nil then
      web.revoke_object_url(preview_url)
   end

   preview_url = web.create_object_url(blob)

   web.set_attr(preview, "src", preview_url)
   web.set_style(preview, "display", "block")
   web.set_style(placeholder, "display", "none")
end

web.on(web.query("#upload"), "click", function()
   web.console(file_input, web.get_prop(file_input, "click"))
   web.click(file_input)
end)

web.on(file_input, "change", function()
   local file = web.get_prop(web.get_prop(file_input, "files"), 0)
   if file == nil then
      return
   end
   utils.set_loading(true)
   async.next(web.array_buffer(file), function(data)
      buffer = data
      show_image(file)
      utils.set_loading(false)
   end)
end)

web.on(web.query("#encode"), "click", function()
   if buffer == nil then
      return
   end
   utils.set_loading(true)
   web.set_timeout(function()
      async.next(limp.read(buffer), function(image)
         async.next(limp.write(mikoto.encode_image(image)), function(data)
            buffer = data
            show_image(web.new_blob(buffer))
            utils.set_loading(false)
         end)
      end)
   end, 500)
end)

web.on(web.query("#decode"), "click", function()
   if buffer == nil then
      return
   end
   utils.set_loading(true)
   web.set_timeout(function()
      async.next(limp.read(buffer), function(image)
         async.next(limp.write(mikoto.decode_image(image)), function(data)
            buffer = data
            show_image(web.new_blob(buffer))
            utils.set_loading(false)
         end)
      end)
   end, 500)

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
