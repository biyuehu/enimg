local fs = require("fs")
local async = require("async")
local limp = require("limp")
local enimg = require("enimg")

async.next(limp.read(fs.read_file("test_encoded.png")), function(img: limp.Image): nil
    local new_img = enimg.decode_image(img)
    async.next(limp.get_buffer(new_img, "image/png"), function(buffer: fs.Buffer): nil
        fs.write_file("test_decoded.png", buffer)
    end)
end)
