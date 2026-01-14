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

current_user = nil

LoginUI = {
    mode = "list",
    users = {},
    selected = 1,
    input = "",
    error = false
}

-- Ввод текста
function inputString(x, y, length, password)
    local str = ""
    mon.setCursorPos(x, y)
    while true do
        local event, key = os.pullEvent()
        if event == "key" then
            if key == keys.enter then
                break
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
        elseif event == "char" then
            if #key == 1 and #str < length then
                str = str .. key
                mon.write(password and "*" or key)
            end
        end
    end
    return str
end

-- Загрузка пользователей
function loadUsers()
    LoginUI.users = {}
    for _, u in ipairs(fs.list("users")) do
        if fs.isDir("users/" .. u) then
            table.insert(LoginUI.users, u)
        end
    end
end

-- Меню пользователей с сенсорами
function usersMenu()
    loadUsers()
    local w, h = mon.getSize()
    local x = math.floor(w / 2) - 12
    local y = math.floor(h / 2) - 6

    table.insert(screen_renderer, function()
        if desktop_see then return end

        -- Рамка
        mon.setBackgroundColor(colors.black)
        for i = 0, 11 do
            mon.setCursorPos(x, y + i)
            mon.write(string.rep(" ", 24))
        end

        mon.setCursorPos(x + 6, y)
        mon.write("LOGIN")

        -- Пользователи
        for i, name in ipairs(LoginUI.users) do
            mon.setCursorPos(x + 2, y + i + 1)
            mon.setBackgroundColor(i == LoginUI.selected and colors.gray or colors.black)
            mon.write(name .. string.rep(" ", 20 - #name))
        end

        -- Кнопка Create USER
        mon.setCursorPos(x + 2, y + #LoginUI.users + 3)
        mon.setBackgroundColor(LoginUI.selected == #LoginUI.users + 1 and colors.gray or colors.black)
        mon.write("Create USER" .. string.rep(" ", 10))
    end)

    table.insert(events_renderer, function(event, key)
        if desktop_see then return end

        -- Навигация
        if event == "key" then
            if key == keys.up then
                LoginUI.selected = math.max(1, LoginUI.selected - 1)
            elseif key == keys.down then
                LoginUI.selected = math.min(#LoginUI.users + 1, LoginUI.selected + 1)
            elseif key == keys.enter then
                if LoginUI.selected <= #LoginUI.users then
                    -- Пользователь выбран
                    LoginUI.mode = "password"
                    LoginUI.input = ""
                    LoginUI.error = false
                else
                    -- Создание нового пользователя
                    LoginUI.mode = "createUser"
                end
            end
        end

        -- Ввод пароля
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

        -- Создание пользователя
        if LoginUI.mode == "createUser" then
            mon.setBackgroundColor(colors.black)
            mon.setCursorPos(1, 1)
            mon.clear()
            mon.setCursorPos(2, 2)
            mon.write("New Username: ")
            local username = inputString(16, 2, 20, false)
            mon.setCursorPos(2, 4)
            mon.write("Password: ")
            local password = inputString(12, 4, 20, true)

            if not fs.exists("users/"..username) then
                fs.makeDir("users/"..username)
            end
            local f = fs.open("users/"..username.."/qq.txt", "w")
            f.writeLine(password)
            f.close()

            LoginUI.mode = "list"
            LoginUI.selected = 1
            LoginUI.input = ""
            LoginUI.error = false
        end
    end)
end

-- Создание первого пользователя
function createUserMenu()
    mon.setBackgroundColor(colors.black)
    mon.clear()
    mon.setCursorPos(2,2)
    mon.write("No users found. Create first user.")
    mon.setCursorPos(2,4)
    local username = inputString(2, 4, 20, false)
    mon.setCursorPos(2,6)
    local password = inputString(2, 6, 20, true)
    if not fs.exists("users/"..username) then
        fs.makeDir("users/"..username)
    end
    local f = fs.open("users/"..username.."/qq.txt", "w")
    f.writeLine(password)
    f.close()
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