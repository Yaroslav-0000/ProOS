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

    local need_update = true
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

current_user = nil
LoginUI = { mode = "list", users = {}, selected = 1, input = "", error = false }

function inputString(x, y, length, password)
    local str = ""
    local mon = term.current()
    mon.setCursorPos(x, y)
    while true do
        local event, key = os.pullEvent()
        if event == "key" then
            if key == keys.enter then break
            elseif key == keys.backspace then
                if #str > 0 then
                    str = str:sub(1, -2)
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
    local event, a, b, c = os.pullEvent()
    if event == "key" and a == keys.q then
        os.reboot()
    end
    for i, func in ipairs(events_renderer) do
        func(event, a, b, c)
    end
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

function loadUsers()
    LoginUI.users = {}
    for _, u in ipairs(fs.list("users")) do
        if fs.isDir("users/" .. u) then
            table.insert(LoginUI.users, u)
        end
    end
end

function usersMenu()
    loadUsers()
    local width, height = mon.getSize()
    local rectW, rectH = 30, 12
    local startX = math.floor((width - rectW) / 2) + 1
    local startY = math.floor((height - rectH) / 2) + 1

    table.insert(screen_renderer, function()
        if desktop_see then return end
        -- рамка
        mon.setBackgroundColor(colors.black)
        for y = 0, rectH - 1 do
            mon.setCursorPos(startX, startY + y)
            mon.write(string.rep(" ", rectW))
        end
        -- заголовок
        mon.setCursorPos(startX + 10, startY)
        mon.write("LOGIN")
        -- список пользователей
        for i, name in ipairs(LoginUI.users) do
            mon.setCursorPos(startX + 2, startY + i + 1)
            mon.setBackgroundColor(i == LoginUI.selected and colors.gray or colors.black)
            mon.write(name .. string.rep(" ", rectW - #name - 2))
        end
        -- кнопка "Create USER"
        local createY = startY + #LoginUI.users + 3
        mon.setCursorPos(startX + 5, createY)
        mon.setBackgroundColor(colors.blue)
        mon.write(" Create USER ")
        mon.setBackgroundColor(colors.black)
        -- ввод пароля
        if LoginUI.mode == "password" then
            mon.setCursorPos(startX + 2, startY + 4)
            mon.write("Password:")
            mon.setCursorPos(startX + 2, startY + 5)
            mon.write(string.rep("*", #LoginUI.input))
            if LoginUI.error then
                mon.setTextColor(colors.red)
                mon.setCursorPos(startX + 2, startY + 7)
                mon.write("Wrong password")
                mon.setTextColor(colors.white)
            end
        end
    end)

    -- сенсорные клики и клавиши
    table.insert(events_renderer, function(event, a, b, c)
        if desktop_see then return end
        local mx, my = b, c
        local w, h = mon.getSize()
        local rectW, rectH = 30, 12
        local startX = math.floor((w - rectW) / 2) + 1
        local startY = math.floor((h - rectH) / 2) + 1
        local createY = startY + #LoginUI.users + 3

        if event == "mouse_click" then
            -- клик на пользователе
            for i, _ in ipairs(LoginUI.users) do
                if mx >= startX + 2 and mx <= startX + rectW - 2 and my == startY + i + 1 then
                    LoginUI.selected = i
                    LoginUI.mode = "password"
                    LoginUI.input = ""
                    LoginUI.error = false
                end
            end
            -- клик на Create USER
            if mx >= startX + 5 and mx <= startX + 17 and my == createY then
                createUserMenu()
            end
        elseif event == "key" then
            if LoginUI.mode == "list" then
                if a == keys.up then
                    LoginUI.selected = math.max(1, LoginUI.selected - 1)
                elseif a == keys.down then
                    LoginUI.selected = math.min(#LoginUI.users, LoginUI.selected + 1)
                elseif a == keys.enter then
                    LoginUI.mode = "password"
                    LoginUI.input = ""
                    LoginUI.error = false
                end
            elseif LoginUI.mode == "password" then
                if a == keys.backspace then
                    LoginUI.input = LoginUI.input:sub(1, -2)
                elseif a == keys.enter then
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
        elseif event == "char" and LoginUI.mode == "password" then
            LoginUI.input = LoginUI.input .. a
        end
    end)
end

function createUserMenu()
    local width, height = mon.getSize()
    local rectW, rectH = 30, 10
    local startX = math.floor((width - rectW) / 2) + 1
    local startY = math.floor((height - rectH) / 2) + 1

    mon.setBackgroundColor(colors.black)
    for y = 0, rectH - 1 do
        mon.setCursorPos(startX, startY + y)
        mon.write(string.rep(" ", rectW))
    end

    mon.setCursorPos(startX + 2, startY + 2)
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(colors.white)
    mon.write("Username: ")
    local username = inputString(startX + 12, startY + 2, 20, false)

    mon.setCursorPos(startX + 2, startY + 4)
    mon.write("Password: ")
    local password = inputString(startX + 12, startY + 4, 20, true)

    if not fs.exists("users/"..username) then
        fs.makeDir("users/"..username)
    end
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

    table.insert(desktop_renderer_fun_s, function() end)

    while running do
        parallel.waitForAny(events_chek, UNLimitedFunS)
    end
end

ProOS()