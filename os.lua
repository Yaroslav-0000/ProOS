print("Start-OS")

local gpu = peripheral.find("tm_gpu")
gpu.refreshSize()
gpu.fill(0x111111)
gpu.sync()

x, y = gpu.getSize()
print(x .. y .. "Size")

while true do
    local event, x, y, sneaking = os.pullEvent("tm_monitor_touch")
    print("Touch at: " .. x .. " " .. y)
end
