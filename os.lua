print("Start-OS")

mon = term.current()

mon.clear()

mon.setBackgroundColor(colors.blue)

mon.setBackgroundColor(colors.red)

mon.setCursorBlink(false)



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
mon.clear()

desktop_renderer_fun_s = {}
drivers_updatede_fun_s = {}
desktop_see = false

screen_renderer = {}
events_renderer = {}

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
    for i, func in ipairs(events_renderer) do
        func(event, a)
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

current_user = nil

LoginUI = {
    mode = "list",
    users = {},
    selected = 1,
    input = "",
    error = false
}

function loadUsers()
    LoginUI.users = {}
    for _, u in ipairs(fs.list("users")) do
        if fs.isDir("users/" .. u) then
            table.insert(LoginUI.users, u)
        end
    end
end


function usersMenu()
     local width, height = mon.getSize()

    table.insert(screen_renderer, function()
    if desktop_see then return end

    local w, h = mon.getSize()
    local x = math.floor(w / 2) - 12
    local y = math.floor(h / 2) - 6

    mon.setBackgroundColor(colors.black)
    for i = 0, 11 do
        mon.setCursorPos(x, y + i)
        mon.write(string.rep(" ", 24))
    end

    mon.setCursorPos(x + 6, y)
    mon.write("LOGIN")

    loadUsers()
    if LoginUI.mode == "list" then
        for i, name in ipairs(LoginUI.users) do
            mon.setCursorPos(x + 2, y + i + 1)
            mon.setBackgroundColor(i == LoginUI.selected and colors.gray or colors.black)
            mon.write(name .. "   ")
        end
    end

    if LoginUI.mode == "password" then
        mon.setCursorPos(x + 2, y + 4)
        mon.setBackgroundColor(colors.black)
        mon.write("Password:")

        mon.setCursorPos(x + 2, y + 5)
        mon.write(string.rep("*", #LoginUI.input))

        if LoginUI.error then
            mon.setCursorPos(x + 2, y + 7)
            mon.setTextColor(colors.red)
            mon.write("Wrong password")
            mon.setTextColor(colors.white)
        end
    end
end)
table.insert(events_renderer, function(event, key)
    if desktop_see then return end

    if LoginUI.mode == "list" and event == "key" then
        if key == keys.up then
            LoginUI.selected = math.max(1, LoginUI.selected - 1)
        elseif key == keys.down then
            LoginUI.selected = math.min(#LoginUI.users, LoginUI.selected + 1)
        elseif key == keys.enter then
            LoginUI.mode = "password"
            LoginUI.input = ""
            LoginUI.error = false
        end
    end

    if LoginUI.mode == "password" then
        if event == "char" then
            LoginUI.input = LoginUI.input .. key
        elseif event == "key" then
            if key == keys.backspace then
                LoginUI.input = LoginUI.input:sub(1, -2)
            elseif key == keys.enter then
                local user = LoginUI.users[LoginUI.selected]
                local f = fs.open("users/" .. user .. "/qq.txt", "r")
                local pass = f and f.readLine() or ""
                if f then f.close() end

                if LoginUI.input == pass then
                    current_user = user
                    desktop_see = true
                else
                    LoginUI.input = ""
                    LoginUI.error = true
                end
            end
        end
    end
end)

end

function createUserMenu()
    local width, height = mon.getSize()
    local rectW, rectH = 30, 10
    local startX = math.floor((width - rectW) / 2) + 1
    local startY = math.floor((height - rectH) / 2) + 1

    -- Рамка меню
    table.insert(screen_renderer, function()
        local prevColor = mon.getBackgroundColor()
        mon.setBackgroundColor(colors.black)
        for y = 0, rectH - 1 do
            mon.setCursorPos(startX, startY + y)
            mon.write(string.rep(" ", rectW))
        end
        mon.setBackgroundColor(prevColor)
    end)

    -- Ввод имени и пароля
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
    os.sleep(2)
end
function ProOS()
    if not fs.exists("users") then
        fs.makeDir("users")
    end
    if #fs.list("users") == 0 then
        createUserMenu()
    else
        usersMenu()
    end

    table.insert(desktop_renderer_fun_s, function()
            
end)
    
    while running do
        parallel.waitForAny(events_chek, UNLimitedFunS)
    end
end

ProOS()
