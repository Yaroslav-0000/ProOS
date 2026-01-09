-- ============================
-- GUI OS for CC: Tweaked
-- ============================

-- Подключаем GPU (как в Морском бое)
local gpu = peripheral.find("tm_gpu")
if not gpu then
    gpu = peripheral.find("gpu")
    if not gpu then
        print("No GPU found! Using terminal...")
        shell.execute()
        return
    end
end

-- Подключаем монитор
local monitor = peripheral.find("tm_monitor") or peripheral.find("monitor")
if monitor then
    gpu.bind(monitor)
end

-- Инициализация GPU (как в твоем коде)
gpu.sync()
gpu.refreshSize()
local width, height = gpu.getSize()

-- Системные переменные
local running = true
local apps = {}
local windows = {}
local selectedApp = nil

-- Цвета (как в Морском бое)
local colors = {
    background = 0x000000,
    taskbar = 0x333333,
    window = 0x222222,
    text = 0xFFFFFF,
    button = 0x444444,
    close = 0xFF0000,
    title = 0x007ACC
}

-- ============================
-- ФУНКЦИИ РИСОВАНИЯ
-- ============================

function clearScreen()
    gpu.fill(colors.background)
    gpu.sync()
end

function drawTaskbar()
    gpu.filledRectangle(1, height-1, width, 1, colors.taskbar)
    gpu.drawText(2, height, "Start", colors.text, colors.taskbar, 1, 0)
    gpu.sync()
end

function drawDesktop()
    local x, y = 3, 3
    for i, app in ipairs(apps) do
        gpu.drawText(x, y, app.icon, colors.text, colors.background, 1, 0)
        gpu.drawText(x-1, y+1, app.name, colors.text, colors.background, 1, 0)
        y = y + 4
        if y > height - 5 then
            y = 3
            x = x + 12
        end
    end
end

function drawWindow(id)
    local win = windows[id]
    if not win or not win.active then return end
    
    -- Фон окна
    gpu.filledRectangle(win.x, win.y, win.width, win.height, colors.window)
    
    -- Заголовок
    gpu.filledRectangle(win.x, win.y, win.width, 1, colors.title)
    gpu.drawText(win.x+1, win.y, win.title, colors.text, colors.title, 1, 0)
    
    -- Кнопка закрытия
    gpu.set(win.x + win.width - 1, win.y, "X", colors.close, colors.title)
    
    -- Содержимое
    if type(win.content) == "function" then
        local oldX, oldY = gpu.get()
        gpu.set(win.x+2, win.y+2)
        win.content()
        gpu.set(oldX, oldY)
    elseif win.content then
        gpu.drawText(win.x+2, win.y+2, win.content, colors.text, colors.window, 1, 0)
    end
    
    gpu.sync()
end

-- ============================
-- УСТАНОВЩИК ПАКЕТОВ
-- ============================

function showInstaller()
    local winId = #windows + 1
    windows[winId] = {
        title = "Package Installer",
        x = 10, y = 5,
        width = 40, height = 15,
        active = true,
        content = function()
            gpu.drawText(2, 2, "Available packages:", colors.text, colors.window, 1, 0)
            gpu.drawText(2, 4, "1. File Manager", colors.text, colors.window, 1, 0)
            gpu.drawText(2, 5, "2. Text Editor", colors.text, colors.window, 1, 0)
            gpu.drawText(2, 6, "3. Browser", colors.text, colors.window, 1, 0)
            gpu.drawText(2, 8, "Select (1-3):", colors.text, colors.window, 1, 0)
        end
    }
end

function installPackage(pkgNum)
    local packages = {
        {name = "File Manager", icon = "[FM]"},
        {name = "Text Editor", icon = "[TE]"},
        {name = "Browser", icon = "[BR]"}
    }
    
    if pkgNum >= 1 and pkgNum <= 3 then
        local pkg = packages[pkgNum]
        table.insert(apps, {
            name = pkg.name,
            icon = pkg.icon,
            run = function()
                createAppWindow(pkg.name)
            end
        })
        return true
    end
    return false
end

function createAppWindow(title)
    local winId = #windows + 1
    windows[winId] = {
        title = title,
        x = 15, y = 10,
        width = 30, height = 10,
        active = true,
        content = "This is " .. title .. "\nWindow content here"
    }
end

-- ============================
-- СИСТЕМНЫЕ ПРИЛОЖЕНИЯ
-- ============================

-- Добавляем базовые приложения
table.insert(apps, {
    name = "Terminal",
    icon = "[TERM]",
    run = function()
        clearScreen()
        gpu.set(1, 1, "=== Terminal ===", colors.text, colors.background, 1, 0)
        shell.execute()
    end
})

table.insert(apps, {
    name = "Installer",
    icon = "[INS]",
    run = showInstaller
})

table.insert(apps, {
    name = "Files",
    icon = "[FLS]",
    run = function()
        local winId = #windows + 1
        windows[winId] = {
            title = "File Manager",
            x = 10, y = 8,
            width = 50, height = 12,
            active = true,
            content = function()
                local fs = require("filesystem")
                gpu.drawText(2, 2, "Directory: /", colors.text, colors.window, 1, 0)
                local y = 4
                for file in fs.list("/") do
                    gpu.drawText(3, y, file, colors.text, colors.window, 1, 0)
                    y = y + 1
                end
            end
        }
    end
})

-- ============================
-- ОБРАБОТКА СОБЫТИЙ
-- ============================

function handleTouch(x, y)
    -- Проверяем панель задач
    if y == height then
        if x >= 2 and x <= 7 then
            -- Start menu
            showStartMenu()
        end
        return
    end
    
    -- Проверяем иконки приложений
    local iconX, iconY = 3, 3
    for i, app in ipairs(apps) do
        if x >= iconX-1 and x <= iconX + #app.name and
           y >= iconY and y <= iconY + 2 then
            app.run()
            return
        end
        iconY = iconY + 4
        if iconY > height - 5 then
            iconY = 3
            iconX = iconX + 12
        end
    end
    
    -- Проверяем окна
    for id, win in pairs(windows) do
        if win.active then
            -- Кнопка закрытия
            if x == win.x + win.width - 1 and y == win.y then
                win.active = false
                return
            end
            
            -- Содержимое окна
            if x >= win.x and x <= win.x + win.width and
               y >= win.y and y <= win.y + win.height then
                -- Можно добавить обработку кликов внутри окна
                return
            end
        end
    end
end

function showStartMenu()
    local menuHeight = 8
    gpu.filledRectangle(2, height - menuHeight - 1, 15, menuHeight, colors.window)
    gpu.rectangle(2, height - menuHeight - 1, 15, menuHeight, colors.title)
    
    local items = {"Terminal", "Files", "Installer", "Exit"}
    for i, item in ipairs(items) do
        gpu.drawText(3, height - menuHeight + i - 1, item, colors.text, colors.window, 1, 0)
    end
    gpu.sync()
end

-- ============================
-- ГЛАВНЫЙ ЦИКЛ
-- ============================

function main()
    clearScreen()
    drawDesktop()
    drawTaskbar()
    gpu.sync()
    
    print("GUI OS Started. Screen: " .. width .. "x" .. height)
    
    while running do
        local event, p, x, y, isShift = os.pullEvent()
        
        if event == "tm_monitor_touch" or event == "monitor_touch" then
            handleTouch(x, y)
            
            -- Перерисовываем
            clearScreen()
            drawDesktop()
            drawTaskbar()
            
            -- Рисуем активные окна
            for id, win in pairs(windows) do
                if win.active then
                    drawWindow(id)
                end
            end
            gpu.sync()
            
        elseif event == "key" then
            if p == 1 then -- Escape
                running = false
            elseif p == 28 then -- Enter
                showInstaller()
            end
        elseif event == "terminate" then
            running = false
        end
    end
    
    -- Завершение работы
    clearScreen()
    gpu.set(1, 1, "Goodbye!", colors.text, colors.background, 1, 0)
    gpu.sync()
    os.sleep(1)
    clearScreen()
end

-- ============================
-- ЗАПУСК СИСТЕМЫ
-- ============================

-- Запускаем GUI если есть экран, иначе терминал
if width > 0 and height > 0 then
    main()
else
    print("Starting terminal mode...")
    shell.execute()
end
