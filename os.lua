print("Start-OS")

local gpu = peripheral.find("tm_gpu")
gpu.refreshSize()
gpu.fill(0x111111)
gpu.sync()

x, y = gpu.getSize()
print(x .. y .. "Size")

function Render() do
    gpu.filledRectangle(2, 2, 10, 10, 0xFF2400)
end
