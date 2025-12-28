-- ProOS Installer v0.1
-- Fully ASCII, CC/Tweaked compatible

-- Helper for directories
local function makeDir(path)
    if not fs.exists(path) then
        fs.makeDir(path)
    end
end

-- Button object
local Button = {}
Button.__index = Button

function Button.new(t)
    return setmetatable(t, Button)
end

function Button:draw(selected)
    local color = selected and self.hoverColor or self.bgColor
    paintutils.drawFilledBox(self.x, self.y, self.x+self.width-1, self.y+self.height-1, color)
    term.setCursorPos(self.x + math.floor((self.width - #self.label)/2), self.y + math.floor(self.height/2))
    term.setTextColor(self.fgColor)
    term.write(self.label)
end

function Button:isClicked(mx, my)
    return mx >= self.x and mx <= self.x+self.width-1 and my >= self.y and my <= self.y+self.height-1
end

-- Installer levels
local level = 1
local running = true
local selected = 1

term.clear()
term.setCursorPos(1,1)

while running do
    if level == 1 then
        -- Level 1: User Agreement
        term.clear()
        print("ProOS Installer v0.1")
        print("--------------------")
        print("Please read the User Agreement.")
        print("You must accept to continue installation.")
        
        local buttons = {
            Button.new{ x=5, y=8, width=15, height=3, label="Accept", fgColor=colors.white, bgColor=colors.gray, hoverColor=colors.yellow, action=function() level = 2 end },
            Button.new{ x=25, y=8, width=15, height=3, label="Decline", fgColor=colors.white, bgColor=colors.gray, hoverColor=colors.red, action=function() running=false end }
        }

        for i,btn in ipairs(buttons) do btn:draw(i==selected) end

        local event, key, mx, my = os.pullEvent()
        if event == "key" then
            if key == keys.left or key == keys.up then selected = selected - 1; if selected<1 then selected=#buttons end
            elseif key == keys.right or key == keys.down then selected = selected + 1; if selected>#buttons then selected=1 end
            elseif key == keys.enter then buttons[selected].action() end
        elseif event == "mouse_click" then
            for i,btn in ipairs(buttons) do if btn:isClicked(mx,my) then btn.action() end end
        end
        for i,btn in ipairs(buttons) do btn:draw(i==selected) end

    elseif level == 2 then
        -- Level 2: Installation Options
        term.clear()
        print("Installation Options")
        print("-------------------")
        print("Files will be installed in /System/")
        print("[Start Installation]   [Back]")

        local buttons = {
            Button.new{ x=5, y=7, width=20, height=3, label="Start Install", fgColor=colors.white, bgColor=colors.gray, hoverColor=colors.green, action=function() level=3 end },
            Button.new{ x=30, y=7, width=10, height=3, label="Back", fgColor=colors.white, bgColor=colors.gray, hoverColor=colors.yellow, action=function() level=1 end }
        }

        for i,btn in ipairs(buttons) do btn:draw(i==selected) end

        local event, key, mx, my = os.pullEvent()
        if event == "key" then
            if key == keys.left or key == keys.up then selected = selected - 1; if selected<1 then selected=#buttons end
            elseif key == keys.right or key == keys.down then selected = selected + 1; if selected>#buttons then selected=1 end
            elseif key == keys.enter then buttons[selected].action() end
        elseif event == "mouse_click" then
            for i,btn in ipairs(buttons) do if btn:isClicked(mx,my) then btn.action() end end
        end
        for i,btn in ipairs(buttons) do btn:draw(i==selected) end

    elseif level == 3 then
        -- Level 3: Progress Bar / Installation
        term.clear()
        print("Installing ProOS...")
        makeDir("/System")
        makeDir("/System/Kernel")
        makeDir("/System/Drivers")
        makeDir("/System/Services")

        local files = {
            {"https://yaroslav-0000.github.io/ProOS/System/Kernel/kernel.lua", "System/Kernel/kernel.lua"},
            {"https://yaroslav-0000.github.io/ProOS/System/Drivers/monitor.lua", "System/Drivers/monitor.lua"},
            {"https://yaroslav-0000.github.io/ProOS/System/Services/display.service.lua", "System/Services/display.service.lua"},
            {"https://yaroslav-0000.github.io/ProOS/Installer.lua", "Installer.lua"}
        }

        for i,f in ipairs(files) do
            term.write("Downloading: "..f[2].." ... ")
            local ok = pcall(shell.run,"wget",f[1],f[2])
            if ok then
                print("OK")
            else
                print("FAILED")
            end
        end
        print("Installation complete!")
        sleep(1)
        level = 4

    elseif level == 4 then
        -- Level 4: Reboot
        term.clear()
        print("ProOS successfully installed!")
        print("[Reboot to start ProOS]")

        local button = Button.new{ x=10, y=5, width=25, height=3, label="Reboot", fgColor=colors.white, bgColor=colors.gray, hoverColor=colors.green, action=function() os.reboot() end }
        button:draw(true)

        local event, key, mx, my = os.pullEvent()
        if event == "key" and key == keys.enter then button.action()
        elseif event == "mouse_click" then
            if button:isClicked(mx,my) then button.action() end
        end
    end
end
