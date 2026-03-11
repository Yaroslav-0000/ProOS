print("Start-OSа")

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

function handleKey(key)
    print("Нажата клавиша:", key)
end

function handleChar(char)
    print("Введён символ:", char)
end

function ProOS()
    gpu.refreshSize()
    gpu.setSize(64)
    gpu.fill(0x333333)
    gpu.sync()

    while true do
        local event, p1, p2 = os.pullEvent()
        if event == "tm_monitor_touch" then
            handleClick(p1, p2)
        elseif event == "tm_key" then
            handleKey(p1)
        elseif event == "tm_char" then
            handleChar(p1)
        end
    end
end

ProOS()

