-- ============================
-- GUI OS for CC: Tweaked
-- ============================

-- Core components
local event = require("event")
local term = require("term")
local gpu = component.gpu
local computer = require("computer")
local filesystem = require("filesystem")
local shell = require("shell")

-- Configuration
local config = {
    osName = "GraphOS",
    version = "1.0",
    theme = "dark",
    resolution = {gpu.getResolution()}
}

-- System variables
local running = true
local windows = {}
local activeWindow = nil
local desktop = {}
local taskbar = {height = 2}
local menuOpen = false
local currentPath = "/home"

-- Colors
local colors = {
    background = 0x1E1E1E,
    window = 0x2D2D30,
    title = 0x007ACC,
    button = 0x0E70C4,
    text = 0xFFFFFF,
    success = 0x00AA00,
    error = 0xAA0000
}

-- ============================
-- SYSTEM INITIALIZATION
-- ============================

-- Set resolution
local function setBestResolution()
    local maxW, maxH = gpu.maxResolution()
    local targetW, targetH = 80, 25
    
    if maxW >= 80 and maxH >= 25 then
        gpu.setResolution(80, 25)
    else
        gpu.setResolution(maxW, maxH)
    end
    config.resolution = {gpu.getResolution()}
end

-- Initialize filesystem
local function initFilesystem()
    local sysDirs = {
        "/sys",
        "/sys/apps", 
        "/sys/config",
        "/sys/drivers",
        "/home",
        "/home/user",
        "/tmp",
        "/usr",
        "/usr/bin"
    }
    
    for _, dir in ipairs(sysDirs) do
        if not filesystem.exists(dir) then
            filesystem.makeDirectory(dir)
        end
    end
    
    -- Create system config
    local configFile = io.open("/sys/config/system.cfg", "w")
    if configFile then
        configFile:write("os.name=" .. config.osName .. "\n")
        configFile:write("os.version=" .. config.version .. "\n")
        configFile:write("theme=" .. config.theme .. "\n")
        configFile:close()
    end
    
    -- Create basic apps
    local apps = {
        {
            name = "File Manager",
            path = "/sys/apps/filemanager.lua",
            icon = "[FM]",
            script = [[
                return {
                    name = "File Manager",
                    run = function()
                        local term = require("term")
                        local fs = require("filesystem")
                        term.clear()
                        print("=== File Manager ===")
                        print("Current dir: " .. fs.get("/"))
                        -- File manager logic here
                    end
                }
            ]]
        },
        {
            name = "Terminal",
            path = "/sys/apps/terminal.lua", 
            icon = "[>_]",
            script = [[
                return {
                    name = "Terminal",
                    run = function()
                        shell.execute("shell")
                    end
                }
            ]]
        },
        {
            name = "Settings",
            path = "/sys/apps/settings.lua",
            icon = "[SET]",
            script = [[
                return {
                    name = "Settings",
                    run = function()
                        local term = require("term")
                        term.clear()
                        print("=== System Settings ===")
                        print("1. Change theme")
                        print("2. Change resolution")
                        print("3. Manage apps")
                    end
                }
            ]]
        }
    }
    
    for _, app in ipairs(apps) do
        local file = io.open(app.path, "w")
        if file then
            file:write(app.script)
            file:close()
            desktop[#desktop + 1] = {
                name = app.name,
                icon = app.icon,
                path = app.path
            }
        end
    end
end

-- ============================
-- DRIVER MANAGER
-- ============================

local driverManager = {
    drivers = {},
    monitors = {}
}

function driverManager:init()
    -- Detect monitors from CC: Tweaked
    for address in component.list("screen") do
        local proxy = component.proxy(address)
        if proxy then
            self.monitors[address] = {
                proxy = proxy,
                width = proxy.getResolution(),
                height = select(2, proxy.getResolution()),
                address = address
            }
        end
    end
    
    -- Detect peripherals from toms-peripherals
    for address, type in component.list() do
        if type:find("peripheral") or type:find("monitor") then
            self.drivers[address] = {
                type = type,
                address = address,
                connected = true
            }
        end
    end
end

function driverManager:list()
    print("=== Connected Drivers ===")
    for addr, driver in pairs(self.drivers) do
        print(driver.type .. ": " .. addr:sub(1, 8))
    end
    for addr, monitor in pairs(self.monitors) do
        print("Monitor: " .. addr:sub(1, 8) .. " (" .. monitor.width .. "x" .. monitor.height .. ")")
    end
end

-- ============================
-- PACKAGE INSTALLER
-- ============================

local installer = {
    packages = {
        ["filemanager"] = {
            name = "File Manager",
            description = "Graphical file manager",
            dependencies = {}
        },
        ["terminal"] = {
            name = "Terminal",
            description = "Command line terminal",
            dependencies = {}
        },
        ["browser"] = {
            name = "Web Browser",
            description = "Simple web browser",
            dependencies = {"network"}
        }
    }
}

function installer:install(pkgName)
    local pkg = self.packages[pkgName]
    if not pkg then
        return false, "Package not found"
    end
    
    -- Check dependencies
    for _, dep in ipairs(pkg.dependencies) do
        if not filesystem.exists("/sys/apps/" .. dep .. ".lua") then
            return false, "Missing dependency: " .. dep
        end
    end
    
    -- Create package file
    local path = "/sys/apps/" .. pkgName .. ".lua"
    local file = io.open(path, "w")
    if not file then
        return false, "Cannot write file"
    end
    
    -- Basic app template
    file:write(string.format([[
return {
    name = "%s",
    version = "1.0",
    run = function()
        local term = require("term")
        term.clear()
        print("=== %s ===")
        print("This is %s v1.0")
        print("Press any key to exit...")
        event.pull("key")
    end
}
    ]], pkg.name, pkg.name, pkg.name))
    
    file:close()
    
    -- Add to desktop
    desktop[#desktop + 1] = {
        name = pkg.name,
        icon = "[APP]",
        path = path
    }
    
    return true
end

-- ============================
-- GUI COMPONENTS
-- ============================

local function drawBackground()
    local w, h = gpu.getResolution()
    gpu.setBackground(colors.background)
    gpu.fill(1, 1, w, h, " ")
end

local function drawTaskbar()
    local w, h = gpu.getResolution()
    gpu.setBackground(colors.title)
    gpu.fill(1, h - taskbar.height + 1, w, taskbar.height, " ")
    
    -- Start button
    gpu.setForeground(colors.text)
    gpu.set(2, h - 1, "[START]")
    
    -- Clock (simulated)
    gpu.set(w - 10, h - 1, "12:00:00")
end

local function drawDesktop()
    local w, h = gpu.getResolution()
    
    -- Desktop icons
    for i, item in ipairs(desktop) do
        local x = 2
        local y = 2 + (i - 1) * 3
        
        gpu.setForeground(colors.text)
        gpu.set(x, y, item.icon)
        gpu.set(x, y + 1, item.name)
    end
end

local function drawWindow(id, title, x, y, width, height)
    -- Window frame
    gpu.setBackground(colors.window)
    gpu.fill(x, y, width, height, " ")
    
    -- Title bar
    gpu.setBackground(colors.title)
    gpu.fill(x, y, width, 1, " ")
    gpu.setForeground(colors.text)
    gpu.set(x + 1, y, title)
    
    -- Close button
    gpu.set(x + width - 1, y, "X")
    
    windows[id] = {
        x = x, y = y,
        width = width, height = height,
        title = title,
        content = {}
    }
    activeWindow = id
end

-- ============================
-- MAIN LOOP
-- ============================

local function main()
    print("Initializing GraphOS v" .. config.version)
    
    -- Set resolution
    setBestResolution()
    
    -- Initialize filesystem
    initFilesystem()
    
    -- Initialize drivers
    driverManager:init()
    
    print("System initialized")
    print("Press any key to start GUI...")
    event.pull("key")
    
    -- Start GUI
    while running do
        -- Draw everything
        drawBackground()
        drawDesktop()
        drawTaskbar()
        
        -- Draw windows
        for id, win in pairs(windows) do
            drawWindow(id, win.title, win.x, win.y, win.width, win.height)
        end
        
        -- Update screen
        gpu.flush()
        
        -- Handle events
        local e = {event.pull(0.1)}
        if e[1] == "key" then
            if e[3] == 28 then -- Enter
                -- Open start menu
                menuOpen = not menuOpen
            elseif e[3] == 1 then -- Escape
                running = false
            end
        elseif e[1] == "touch" then
            local _, _, x, y = table.unpack(e)
            local h = config.resolution[2]
            
            -- Check start button
            if y == h - 1 and x >= 2 and x <= 8 then
                menuOpen = not menuOpen
                
                if menuOpen then
                    -- Draw start menu
                    gpu.setBackground(colors.window)
                    gpu.fill(1, h - 15, 20, 14, " ")
                    
                    gpu.setForeground(colors.text)
                    gpu.set(2, h - 14, "Applications:")
                    
                    for i, app in ipairs(desktop) do
                        gpu.set(3, h - 13 + i, app.icon .. " " .. app.name)
                    end
                    
                    gpu.set(2, h - 3, "Terminal")
                    gpu.set(2, h - 2, "Shutdown")
                end
            end
            
            -- Check desktop icons
            for i, item in ipairs(desktop) do
                local iconX = 2
                local iconY = 2 + (i - 1) * 3
                
                if x >= iconX and x <= iconX + #item.name and 
                   y >= iconY and y <= iconY + 1 then
                    -- Launch application
                    if filesystem.exists(item.path) then
                        local app = dofile(item.path)
                        if app and app.run then
                            drawWindow("app_" .. i, app.name, 10, 5, 60, 15)
                            -- In real implementation, run app in window
                            print("Launching: " .. app.name)
                        end
                    end
                end
            end
        end
    end
    
    -- Clean shutdown
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    term.clear()
    print("GraphOS shutdown complete")
end

-- ============================
-- COMMAND LINE INTERFACE
-- ============================

local function cli()
    print("GraphOS Command Line v1.0")
    print("Type 'help' for commands")
    
    while running do
        io.write("> ")
        local input = io.read()
        
        if input == "help" then
            print("Available commands:")
            print("  gui    - Start graphical interface")
            print("  drivers - List connected drivers")
            print("  install <pkg> - Install package")
            print("  list    - List installed apps")
            print("  exit    - Shutdown system")
        elseif input == "gui" then
            main()
        elseif input == "drivers" then
            driverManager:list()
        elseif input:sub(1, 7) == "install" then
            local pkg = input:sub(9)
            local ok, err = installer:install(pkg)
            if ok then
                print("Package installed: " .. pkg)
            else
                print("Error: " .. err)
            end
        elseif input == "list" then
            print("Installed applications:")
            for _, app in ipairs(desktop) do
                print("  " .. app.icon .. " " .. app.name)
            end
        elseif input == "exit" then
            running = false
        else
            print("Unknown command: " .. input)
        end
    end
end

-- ============================
-- STARTUP
-- ============================

-- Check if GUI is available
if gpu.getScreen() then
    print("Starting GraphOS GUI...")
    main()
else
    print("No screen found, starting CLI...")
    cli()
end
