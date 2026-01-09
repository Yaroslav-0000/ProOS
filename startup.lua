-- GUI OS for CC: Tweaked with toms-peripherals
-- Подключаем GPU из toms-peripherals
local gpu = peripheral.find("tm_gpu")

if not gpu then
    -- Пробуем найти обычный GPU из CC
    gpu = peripheral.find("gpu")
end

if not gpu then
    print("No GPU found! Starting CLI...")
    local shell = require("shell")
    shell.execute()
    return
end

-- Получаем монитор
local monitor = peripheral.find("monitor") or peripheral.find("tm_monitor")

if monitor then
    -- Подключаем GPU к монитору
    gpu.bind(monitor)
end

-- Устанавливаем разрешение
local maxW, maxH = gpu.maxResolution()
if maxW >= 80 and maxH >= 25 then
    gpu.setResolution(80, 25)
else
    gpu.setResolution(maxW, maxH)
end

local w, h = gpu.getResolution()

-- Системные переменные
local running = true
local apps = {}
local windows = {}
local currentPath = "/"

-- Цвета
local colors = {
    bg = 0x000000,
    taskbar = 0x1E1E1E,
    window = 0x2D2D30,
    text = 0xFFFFFF,
    button = 0x0E70C4,
    close = 0xFF0000
}

-- ============================
-- ФУНКЦИИ GUI
-- ============================

function clearScreen()
    gpu.setBackground(colors.bg)
    gpu.fill(1, 1, w, h, " ")
end

function drawTaskbar()
    gpu.setBackground(colors.taskbar)
    gpu.fill(1, h, w, 1, " ")
    gpu.setForeground(colors.text)
    gpu.set(2, h, "START")
end

function drawDesktop()
    -- Рисуем иконки приложений
    local x, y = 2, 2
    for i, app in ipairs(apps) do
        gpu.setForeground(colors.text)
        gpu.set(x, y, app.icon or "APP")
        gpu.set(x, y + 1, app.name)
        y = y + 3
        if y > h - 5 then
            y = 2
            x = x + 15
        end
    end
end

function createWindow(title, content, x, y, width, height)
    local window = {
        id = #windows + 1,
        title = title,
        content = content,
        x = x or 5,
        y = y or 3,
        width = width or 50,
        height = height or 15,
        active = true
    }
    
    windows[window.id] = window
    return window.id
end

function drawWindow(id)
    local win = windows[id]
    if not win then return end
    
    -- Фон окна
    gpu.setBackground(colors.window)
    gpu.fill(win.x, win.y, win.width, win.height, " ")
    
    -- Заголовок
    gpu.setBackground(colors.button)
    gpu.fill(win.x, win.y, win.width, 1, " ")
    gpu.setForeground(colors.text)
    gpu.set(win.x + 1, win.y, win.title)
    
    -- Кнопка закрытия
    gpu.setBackground(colors.close)
    gpu.set(win.x + win.width - 1, win.y, "X")
    
    -- Содержимое
    if type(win.content) == "function" then
        -- Сохраняем текущую позицию курсора
        local oldX, oldY = gpu.get()
        gpu.set(win.x + 2, win.y + 2)
        win.content()
        gpu.set(oldX, oldY)
    elseif type(win.content) == "string" then
        gpu.set(win.x + 2, win.y + 2, win.content)
    end
end

-- ============================
-- ДРАЙВЕРА И УСТАНОВЩИК
-- ============================

function detectDrivers()
    local drivers = {}
    
    -- Ищем драйвера toms-peripherals
    local peripherals = peripheral.getNames()
    
    for _, name in ipairs(peripherals) do
        local pType = peripheral.getType(name)
        if pType:find("tm_") then
            table.insert(drivers, {
                name = name,
                type = pType,
                vendor = "toms-peripherals"
            })
        elseif pType == "monitor" or pType == "gpu" then
            table.insert(drivers, {
                name = name,
                type = pType,
                vendor = "CC:Tweaked"
            })
        end
    end
    
    return drivers
end

function installerApp()
    clearScreen()
    
    local packages = {
        {name = "File Manager", id = "fm", desc = "Manage files"},
        {name = "Text Editor", id = "te", desc = "Edit text files"},
        {name = "Browser", id = "br", desc = "Web browser"},
        {name = "Settings", id = "st", desc = "System settings"}
    }
    
    print("=== Package Installer ===")
    print("Available packages:")
    
    for i, pkg in ipairs(packages) do
        print(i .. ". " .. pkg.name .. " - " .. pkg.desc)
    end
    
    print("\nSelect package to install (1-" .. #packages .. "):")
    
    local choice = tonumber(io.read())
    if choice and packages[choice] then
        local pkg = packages[choice]
        
        -- "Устанавливаем" пакет
        table.insert(apps, {
            name = pkg.name,
            icon = "[" .. pkg.id:upper() .. "]",
            run = function()
                createWindow(pkg.name, "This is " .. pkg.name, 10, 5, 40, 10)
            end
        })
        
        print("Installed: " .. pkg.name)
    else
        print("Invalid choice!")
    end
    
    os.sleep(2)
end

-- ============================
-- СИСТЕМНЫЕ ПРИЛОЖЕНИЯ
-- ============================

-- Добавляем системные приложения
table.insert(apps, {
    name = "Terminal",
    icon = "[TERM]",
    run = function()
        local term = require("term")
        term.clear()
        shell.execute()
    end
})

table.insert(apps, {
    name = "Installer",
    icon = "[INST]",
    run = installerApp
})

table.insert(apps, {
    name = "Drivers",
    icon = "[DRV]",
    run = function()
        local drivers = detectDrivers()
        local winId = createWindow("Drivers", "", 10, 5, 40, 15)
        
        local content = "Detected drivers:\n\n"
        for _, drv in ipairs(drivers) do
            content = content .. drv.type .. ": " .. drv.name .. "\n"
        end
        
        windows[winId].content = content
    end
})

table.insert(apps, {
    name = "Files",
    icon = "[FILE]",
    run = function()
        local fs = require("filesystem")
        local list = fs.list(currentPath)
        
        local content = "Path: " .. currentPath .. "\n\n"
        for item in list do
            content = content .. item .. "\n"
        end
        
        createWindow("File Manager", content, 10, 5, 40, 15)
    end
})

-- ============================
-- ГЛАВНЫЙ ЦИКЛ
-- ============================

function main()
    while running do
        clearScreen()
        drawDesktop()
        drawTaskbar()
        
        -- Рисуем все окна
        for id, win in pairs(windows) do
            drawWindow(id)
        end
        
        gpu.flush()
        
        -- Обработка событий (упрощенная)
        local event = {os.pullEvent()}
        
        if event[1] == "key" then
            local key = event[2]
            
            if key == 1 then -- Escape
                running = false
            elseif key == 28 then -- Enter
                -- Открываем меню
                createWindow("System Menu", "1. Shutdown\n2. Reboot\n3. Apps", 5, 5, 30, 8)
            end
        elseif event[1] == "terminate" then
            running = false
        end
        
        os.sleep(0.1)
    end
    
    -- Завершение работы
    clearScreen()
    gpu.setForeground(colors.text)
    gpu.set(1, 1, "Goodbye!")
end

-- ============================
-- ЗАПУСК
-- ============================

print("Starting GUI OS...")
os.sleep(1)
main()
