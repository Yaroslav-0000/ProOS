print("Start-OS")

local gpu = peripheral.find("tm_gpu")
gpu.refreshSize()
gpu.fill(0x111111)
gpu.sync()

width, height = gpu.getSize()
print(width .. height .. "Size")

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
        os.sleep(1)
        os.reboot()
    end
else
    print("Error downloading OS")
end

function events_chek()
    local event, keyCode = os.pullEvent("key")
    local keyName = keys.getName(keyCode)
    print("Key name: ", keyName)
    if keyCode == keys.q then
        print("Exiting...")
        os.reboot()
    end
end
function screen_render()
    gpu.fill(0x001100)
    gpu.sync()
    os.sleep(0.2)
    gpu.fill(0x009159)
    gpu.sync()
    os.sleep(0.5)
end
function drivers_update()
end
function UNLimitedFunS()
    screen_render()
    drivers_update()
end
while running do
    parallel.waitForAny(events_chek, UNLimitedFunS)
end
