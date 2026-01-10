local gpu = peripheral.find("tm_gpu")
gpu.sync()
gpu.refreshSize()
gpu.fill(0x0000FF)
gpu.filledRectangle(2, 2, 10, 10, FF2400)
gpu.rectangle(2, 2, 10, 10, 0x11FF00)
gpu.sync()

running = true

local keyboard = peripheral.find("tm_keyboard")
if keyboard then
    keyboard.setFireNativeEvents(true)
end

print("Press q to exit")

-- Главный цикл
while running do
    local event, keyCode = os.pullEvent("key")
    local keyName = keys.getName(keyCode)
    
    print("Key code:", keyCode)
    print("Key name (English layout):", keyName)
    if keyCode == keys.q then
        print("Exiting...")
        running = false
    end
end
