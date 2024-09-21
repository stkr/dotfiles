local hexstr = {}
local utils = require("utils")

local function last_hexchar_pos(str, pos)
    local i_end = str:find("[^%x]", pos)
    if i_end == nil then
        return str:len()
    end
    return i_end - 1
end

-- The pos must be on a valid hexstring or on a prefix to a hexstring (0x).
-- Search from the pos to the left and to the right until a character that
-- is no valid hex character is found (ignoring a prefix).
-- Returns the position in the string of the first character that is part
-- of the hexstring (after a potential prefix) and of the last character
-- that is part of the hexstring. Also, checks that the number of
-- characters in the hexstring is divisible by two (or it is not consideres a
-- valid hexstring.
--
-- In case no valid hexstring is found around the pos, it returns 0,0
function hexstr.find_around(str, pos)
    if pos > 1 then
        local prefix_pos = str:find("0[xX]", pos - 1)
        if prefix_pos ~= nil and prefix_pos <= pos then
            pos = prefix_pos + 2
        end
    end

    if str:find("%x", pos) ~= pos then
        utils.warn("No valid hexstr in [" .. str .. "] at pos " .. pos .. ".")
        return 0, 0
    end
    local i_end = last_hexchar_pos(str, pos)

    local rev = str:reverse()
    local rev_pos = str:len() - pos + 1
    local rev_end = last_hexchar_pos(rev, rev_pos)
    local i_start = str:len() - rev_end + 1

    local len = i_end - i_start + 1
    if (len % 2) ~= 0 then
        utils.warn("The hexstring in [" .. str .. "] at pos " .. pos .. " has an odd number of digits.")
        return 0, 0
    end

    return i_start, i_end
end

-- function hexstr.find_around_tests()
--     local testdata = {
--         { "test", 1, 0, 0, "" },
--         { "01020304", 1, 1, 8, "01020304" },
--         { "0x01020304", 3, 3, 10, "01020304" },
--         { "word 0x01020304, asdfas", 10, 8, 15, "01020304" },
--         { "word 0x01020304, asdfas", 6, 8, 15, "01020304" },
--         { "word 0x01020304, asdfas", 7, 8, 15, "01020304" },
--     }

--     for i, t in ipairs(testdata) do
--         local str, pos, ex_start, ex_end = table.unpack(t)
--         io.write("### testing for [" .. str .. "]" .. "(" .. pos .. ")\n")
--         local found_start, found_end = hexstr.find_around(str, pos)
--         if ex_start ~= found_start or ex_end ~= found_end then
--             io.write("fail for [" .. str .. "]" .. "(" .. pos .. "): start: " ..
--                 found_start .. ", " .. ex_start .. "; end: " .. found_end ..
--                 ", " .. ex_end .. "\n")
--         end
--     end
-- end

function hexstr.swap(str, width)
    if width ~= 2 and width ~= 4 and width ~= 8 then
        utils.warn("Invalid width " .. width .. ".")
        return str
    end
    if (str:len() % width) ~= 0 then
        utils.warn("Hexstr [" .. str .. "] has length " .. str:len() .. ", which is no multiple of " .. width .. ".")
        return str
    end

    local result = ""
    local pos = 1
    while pos < str:len() do
        for byte_nr = 1, width do
            local byte_idx = pos + 2 * (width - byte_nr)
            result = result .. str:sub(byte_idx, byte_idx + 1)
        end
        pos = pos + 2 * width
    end
    return result
end

-- function hexstr.swap_tests()
--     local testdata = {
--         { "0102", 2, "0201" },
--         { "01020304", 2, "02010403" },
--         { "01020304", 4, "04030201" },
--         { "0102030411121314", 4, "0403020114131211" },
--         { "0102030411121314", 8, "1413121104030201" },
--     }

--     for i, t in ipairs(testdata) do
--         local str, width, ex_swapped = table.unpack(t)
--         io.write("### testing for [" .. str .. "]" .. "(" .. width .. ")\n")
--         local swapped = hexstr.swap(str, width)
--         if ex_swapped ~= swapped then
--             io.write("fail for [" .. str .. "]" .. "(" .. width .. "): swapped: " ..
--                 swapped .. ", but expected: " .. ex_swapped .. "\n")
--         end
--     end
-- end

return hexstr
