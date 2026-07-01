local async = require("async")
local limp = require("limp")
local fs = require("fs")
local mathlib = require("math")

local type Pair = limp.Pair

local function point_to_index(x: integer, y: integer, w: integer): integer
    return y * w + x
end

local function index_to_point(index: integer, w: integer): Pair
    return { x = index % w, y = index // w }
end

local function gen_key(w: integer, h: integer): integer
    local n = w * h
    local key = mathlib.floor(n * 0.6180339887)
    while require("utils").gcd(key, n) ~= 1 or key == 1 or key == n - 1 do
        key = key + 1
    end
    return key
end

local function transform_index(index: integer, key: integer ,w: integer, h: integer): integer
    return (index * key) % (w * h)
end

local function encode_image(img: limp.Image): limp.Image
    local size = limp.get_size(img)
    local new_img = limp.create(size)
    local key = gen_key(size.x, size.y)
    for y = 0, size.y - 1 do
        for x = 0, size.x - 1 do
            local location = index_to_point(transform_index(point_to_index(x, y, size.x),  key, size.x, size.y), size.x)
            local old = point_to_index(x, y, size.x) << 2
            local new = point_to_index(location.x, location.y, size.x) << 2
            for i = 0, 3 do
                limp.set_pixel(new_img, new + i, limp.get_pixel(img, old + i))
            end
        end
    end
    return new_img
end

async.next(limp.read(fs.read_file("test.png")), function(img: limp.Image): nil
    local new_img = encode_image(img)
    async.next(limp.get_buffer(new_img, "image/png"), function(buffer: fs.Buffer): nil
        fs.write_file("test_encoded.png", buffer)
    end)
end)