local fs = require("fs")
local async = require("async")
local limp = require("limp")
local process = require("process")
local enimg = require("enimg")

local enum Operation
  "En"
  "De"
end
local operation: Operation = process.argv[1] == "en" and "En" or "De"
local input = process.argv[2]
local output = process.argv[3] or input .. "_decoded.png"

print(operation .. "coding image...")
async.next(limp.read(fs.read_file(input)), function(img: limp.Image): nil
    local new_img = operation == "En" and enimg.encode_image(img)  or enimg.decode_image(img)
    print("Saving image...")
    async.next(limp.get_buffer(new_img, "image/png"), function(buffer: fs.Buffer): nil
        fs.write_file(output, buffer)
        print("De" .. "coding complete!")
    end)
end)
