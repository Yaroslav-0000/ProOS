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
    os.sleep(0.1)
end
function createUserMenu()
    mon.setBackgroundColor(colors.blue)
    local width, height = mon.getSize()
    local rectW = 10
    local rectH = 6

    local startX = math.floor((width - rectW) / 2) + 1
    local startY = math.floor((height - rectH) / 2) + 1

    for y = 0, rectH - 1 do
        mon.setCursorPos(startX, startY + y)
        mon.setBackgroundColor(colors.black)
        mon.write(string.rep(" ", rectW))
    end
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
