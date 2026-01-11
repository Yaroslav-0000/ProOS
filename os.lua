print("Start-OS")

local gpu = peripheral.find("tm_gpu")
gpu.refreshSize()
gpu.fill(0x111111)
gpu.sync()

width, height = gpu.getSize()
print(width .. height .. "Size")

running = true


function events_chek()
    local event, x, y, sneaking = os.pullEvent("tm_monitor_touch")
    print("Touch at: " .. x .. " " .. y)
end
function screen_render()
    gpu.fill(0x001100)
    gpu.sync()
    os.sleep(0.2)
    gpu.fill(0x009159)
    gpu.sync()
end
function drivers_update()
    print("UPDATE")
end
function UNLimitedFunS()
    screen_render()
    drivers_update()
end
while running do
    parallel.waitForAny(events_chek, UNLimitedFunS)
end
