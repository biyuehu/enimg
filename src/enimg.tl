local limp = require("limp")
local mathlib = require("math")

local type Pair = limp.Pair

local function point_to_index(x: integer, y: integer, w: integer): integer
    return y * w + x
end

local function index_to_point(index: integer, w: integer): Pair
    return { x = index % w, y = index // w }
end

local function gen_key(n: integer): integer
    local key = mathlib.floor(n * 0.6180339887)
    while require("utils").gcd(key, n) ~= 1 or key == 1 or key == n - 1 do
        key = key + 1
    end
    return key
end

local function permute_index(index: integer, key: integer, n: integer): integer
    return (index * key) % n
end

local function mod_inverse(key: integer, n: integer): integer
    local t, new_t = 0, 1
    local r, new_r = n, key

    while new_r ~= 0 do
        local q = r // new_r

        t, new_t = new_t, t - q * new_t
        r, new_r = new_r, r - q * new_r
    end

    if r ~= 1 then
        error("inverse does not exist")
    end

    if t < 0 then
        t = t + n
    end

    return t
end

local function encode_image(img: limp.Image): limp.Image
    local size = limp.get_size(img)
    local new_img = limp.create(size)
    local n = size.x * size.y
    local key = gen_key(n)

    for y = 0, size.y - 1 do
        for x = 0, size.x - 1 do
            local location = index_to_point(permute_index(point_to_index(x, y, size.x),  key, n), size.x)
            local old = point_to_index(x, y, size.x) << 2
            local new = point_to_index(location.x, location.y, size.x) << 2
            for i = 0, 3 do
                limp.set_pixel(new_img, new + i, limp.get_pixel(img, old + i))
            end
        end
    end

    return new_img
end

local function decode_image(img: limp.Image): limp.Image
    local size = limp.get_size(img)
    local new_img = limp.create(size)
    local n = size.x * size.y
    local key = mod_inverse(gen_key(n), size.x * size.y)

    for y = 0, size.y - 1 do
        for x = 0, size.x - 1 do
            local location = index_to_point(permute_index(point_to_index(x, y, size.x), key, n), size.x)
            local old = point_to_index(x, y, size.x) << 2
            local new = point_to_index(location.x, location.y, size.x) << 2
            for i = 0, 3 do
                limp.set_pixel(new_img, new + i, limp.get_pixel(img, old + i))
            end
        end
    end

    return new_img
end

local enimg = {
    encode_image = encode_image,
    decode_image = decode_image,
}

return enimg
