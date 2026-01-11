print("Start-OS")

mon = term.current()

mon.clear()

mon.setBackgroundColor(colors.blue)

mon.setBackgroundColor(colors.red)



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
        os.sleep(0.2)
        os.reboot()
    end
else
    print("Error downloading OS")
end

desktop_renderer_fun_s = {}
drivers_updatede_fun_s = {}
desktop_see = false

screen_renderer = {}

function inputString(x, y, length, password)
    local str = ""
    local mon = term.current()
    mon.setCursorPos(x, y)
    while true do
        local event, key = os.pullEvent()
        if event == "key" then
            if key == keys.enter then
                break
            elseif key == keys.backspace then
                if #str > 0 then
                    str = str:sub(1, #str-1)
                    mon.setCursorPos(x + #str, y)
                    mon.write(" ")
                    mon.setCursorPos(x + #str, y)
                end
            else
                local char = keys.getName(key)
                if #char == 1 and #str < length then
                    str = str .. char
                    mon.write(password and "*" or char)
                end
            end
        end
    end
    return str
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
function getMonitor()
    local mon = term
    return mon
end
function screen_render()
    mon.clear()
    if desktop_see then
        for i, func in ipairs(desktop_renderer_fun_s) do
            func()
        end
    end
    for i, func in ipairs(screen_renderer) do
        func()
    end
end
function drivers_update()
    for i, func in ipairs(drivers_updatede_fun_s) do
        func()
    end
end
function UNLimitedFunS()
    screen_render()
    drivers_update()
    os.sleep(0.1)
end
function createUserMenu()
    mon.setBackgroundColor(colors.blue)
    local width, height = mon.getSize()
    local rectW = 10
    local rectH = 6

    local startX = math.floor((width - rectW) / 2) + 1
    local startY = math.floor((height - rectH) / 2) + 1

    table.insert(screen_renderer, function()
        for y = 0, rectH - 1 do
            mon.setCursorPos(startX, startY + y)
            mon.setBackgroundColor(colors.black)
            mon.write(string.rep(" ", rectW))
            mon.setBackgroundColor(colors.blue)
        end
    end)
    mon.setCursorPos(startX + 2, startY + 2)
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
    mon.write("Username: ")
    local username = inputString(startX + 12, startY + 2, 20, false)

    mon.setCursorPos(startX + 2, startY + 4)
    mon.write("Password: ")
    local password = inputString(startX + 12, startY + 4, 20, true)

    -- Создание папки пользователя
    if not fs.exists("users/"..username) then
        fs.makeDir("users/"..username)
    end

    -- Создание файла qq.txt с паролем
    local f = fs.open("users/"..username.."/qq.txt", "w")
    f.writeLine(password)
    f.close()

    mon.setCursorPos(startX + 2, startY + 6)
    mon.write("User created!")
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

    table.insert(desktop_renderer_fun_s, function()
            
end)
    
    while running do
        parallel.waitForAny(events_chek, UNLimitedFunS)
    end
end

ProOS()
