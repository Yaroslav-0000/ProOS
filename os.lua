print("Start-OS")

local gpu = peripheral.find("tm_gpu")
gpu.refreshSize()
gpu.fill(0x111111)
gpu.sync()

width, height = gpu.getSize()
print(width .. height .. "Size")

running = true


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
