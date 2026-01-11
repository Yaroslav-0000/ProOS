print("Start-OS")

gpu = peripheral.find("tm_gpu")
local keyboard = peripheral.find("tm_keyboard")
if keyboard then
    keyboard.setFireNativeEvents(true)
end
gpu.refreshSize()
gpu.setSize(1)
gpu.fill(0x111111)
gpu.sync()

width, height = gpu.getSize()
print(width .. height .. "Size")

running = true

local url_os = "https://raw.githubusercontent.com/Yaroslav-0000/ProOS/main/os.lua"

local res_os = http.get(url_os)
if res_os then
    local new_content = res_os.readAll()
    res_os.close()

    local need_update = true  -- флаг, нужен ли апдейт

    if fs.exists("startup.lua") then
        local f = fs.open("startup.lua", "r")
        local old_content = f.readAll()
        f.close()

        if old_content == new_content then
            print("File is up-to-date, no download needed.")
            need_update = false
        end
    end

    if need_update then
        local f = fs.open("startup.lua", "w")
        f.write(new_content)
        f.close()
        print("Downloaded and updated!")
        os.sleep(1)
        os.reboot()
    end
else
    print("Error downloading OS")
end

desktop_renderer_fun_s = {}
drivers_updatede_fun_s = {}
desktop_see = false

FONT_5x8 = {
["A"]={"01110","10001","10001","11111","10001","10001","10001","00000"},
["B"]={"11110","10001","10001","11110","10001","10001","11110","00000"},
["C"]={"01110","10001","10000","10000","10000","10001","01110","00000"},
["D"]={"11110","10001","10001","10001","10001","10001","11110","00000"},
["E"]={"11111","10000","10000","11110","10000","10000","11111","00000"},
["F"]={"11111","10000","10000","11110","10000","10000","10000","00000"},
["G"]={"01110","10001","10000","10011","10001","10001","01110","00000"},
["H"]={"10001","10001","10001","11111","10001","10001","10001","00000"},
["I"]={"01110","00100","00100","00100","00100","00100","01110","00000"},
["J"]={"00111","00010","00010","00010","10010","10010","01100","00000"},
["K"]={"10001","10010","10100","11000","10100","10010","10001","00000"},
["L"]={"10000","10000","10000","10000","10000","10000","11111","00000"},
["M"]={"10001","11011","10101","10101","10001","10001","10001","00000"},
["N"]={"10001","10001","11001","10101","10011","10001","10001","00000"},
["O"]={"01110","10001","10001","10001","10001","10001","01110","00000"},
["P"]={"11110","10001","10001","11110","10000","10000","10000","00000"},
["Q"]={"01110","10001","10001","10001","10101","10010","01101","00000"},
["R"]={"11110","10001","10001","11110","10100","10010","10001","00000"},
["S"]={"01111","10000","10000","01110","00001","00001","11110","00000"},
["T"]={"11111","00100","00100","00100","00100","00100","00100","00000"},
["U"]={"10001","10001","10001","10001","10001","10001","01110","00000"},
["V"]={"10001","10001","10001","10001","10001","01010","00100","00000"},
["W"]={"10001","10001","10001","10101","10101","10101","01010","00000"},
["X"]={"10001","10001","01010","00100","01010","10001","10001","00000"},
["Y"]={"10001","10001","01010","00100","00100","00100","00100","00000"},
["Z"]={"11111","00001","00010","00100","01000","10000","11111","00000"}
}


local PIXEL_SCALE = 3  -- каждый “пиксель” символа будет 3×3 блок

function drawChar(x, y, char, color)
    local glyph = FONT_5x8[char]
    if not glyph then return end

    for row = 1, 8 do
        local line = glyph[row]
        for col = 1, 5 do
            if line:sub(col, col) == "1" then
                local px = x + (col-1)*PIXEL_SCALE
                local py = y + (row-1)*PIXEL_SCALE
                gpu.filledRectangle(px, py, px+PIXEL_SCALE-1, py+PIXEL_SCALE-1, color)
            end
        end
    end
end


function drawText(x, y, text, color)
    local cx = x
    for i = 1, #text do
        local ch = text:sub(i, i)
        drawChar(cx, y, ch, color)
        cx = cx + 6 -- 5 пикселей символ + 1 пробел
    end
end




function events_chek()
    local event, keyCode = os.pullEvent("key")
    local keyName = keys.getName(keyCode)
    print("Key name: ", keyName)
    if keyCode == keys.q then
        print("Exiting...")
        os.reboot()
    end
end
function screen_render()
    if desktop_see then
        for i, func in ipairs(desktop_renderer_fun_s) do
            func()
        end
    end
    drawText(10, 10, "PRO OS", 0x00FF00)
    gpu.sync()
end
function drivers_update()
    for i, func in ipairs(drivers_updatede_fun_s) do
        func()
    end
end
function UNLimitedFunS()
    screen_render()
    drivers_update()
end
function createUserMenu()
    
end
function ProOS()
    if not fs.exists("users") then
        fs.makeDir("users")
    end
    if #fs.list("users") == 0 then
        createUserMenu()
    else
        desktop_see = true
    end
    table.insert(drivers_updatede_fun_s, function()
            gpu = peripheral.find("tm_gpu")
end)

    table.insert(desktop_renderer_fun_s, function()
            
end)
    
    while running do
        parallel.waitForAny(events_chek, UNLimitedFunS)
    end
end

ProOS()
