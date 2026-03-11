print("Start-OS")

running = true

local url_os = "https://raw.githubusercontent.com/Yaroslav-0000/ProOS/main/os.lua"

-- local res_os = http.get(url_os)
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

gpu = peripheral.find("tm_gpu")

function handleClick(x, y, isShift)
    gpu.filledRectangle(x - 2, y - 2, 4, 4, 0x006CFA)
    gpu.sync()
end

print(gpu.getSize())
function ProOS()

    gpu.refreshSize()
    gpu.setSize(64)

    gpu.fill(0x333333)

    local W, H = gpu.getSize()

    for y = 2, H - 1 do
        for x = 2, W - 1 do
            local t = (x + y) / (W + H)
            local r = math.floor(((math.sin(t * math.pi * 2) * 0.5) + 0.5) * 255)
            local g = math.floor(((math.sin(t * math.pi * 2 + 2.094) * 0.5) + 0.5) * 255)
            local b = math.floor(((math.sin(t * math.pi * 2 + 4.188) * 0.5) + 0.5) * 255)

            local color = (r * 0x10000) + (g * 0x100) + b

            gpu.filledRectangle(x, y, 1, 1, color)
        end
    end

    gpu.sync()

    while true do
        local event, p, x, y, isShift = os.pullEvent()
        if event == "tm_monitor_touch" then
            handleClick(x, y, isShift)
        end
    end

end

ProOS()
