local fs = require("fs")
local async = require("async")
local limp = require("limp")
local process = require("process")
local mikoto = require("mikoto")





local operation = process.argv[1] == "e" and "En" or "De"
local input = process.argv[2]
local output = process.argv[3] or input .. "_decoded.png"

print(operation .. "coding image...")
async.next(limp.read(fs.read_file(input)), function(img)
   local new_img = operation == "En" and mikoto.encode_image(img) or mikoto.decode_image(img)
   print("Saving image...")
   async.next(limp.write(new_img), function(buffer)
      fs.write_file(output, buffer)
      print(operation .. "coding complete!")
   end)
end)
