print("Start-OS")

mon = term
local keyboard = peripheral.find("tm_keyboard")
if keyboard then
    keyboard.setFireNativeEvents(true)
end

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
    mon.setBackgroundColor(colors.blue)
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
            mon = getMonitor()
end)

    table.insert(desktop_renderer_fun_s, function()
            
end)
    
    while running do
        parallel.waitForAny(events_chek, UNLimitedFunS)
    end
end

ProOS()
