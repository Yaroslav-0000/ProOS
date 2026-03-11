print("Start-OS")

running = true

-- загрузка ОС
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

gpu = peripheral.find("tm_gpu")
keyboard = peripheral.find("tm_keyboard")

function handleClick(x, y, isShift)
    gpu.rectangle(x - 2, y - 2, 4, 4, 0x006CFA)
    gpu.sync()
end

function handleKey(key, held)
    print("key:", key, "held:", held)
end

function handleChar(char)
    print("Key:", char)
end

function ProOS()
    gpu.refreshSize()
    gpu.setSize(64)
    gpu.fill(0x333333)
    gpu.sync()

    while true do
        local event, p1, p2, p3, p4 = os.pullEvent()
        if event == "tm_monitor_touch" then
            handleClick(p2, p3, p4)
        elseif event == "key" then
            handleKey(p1, p2)
        elseif event == "char" then
            handleChar(p1)
        end
    end
end

ProOS()
