local path = "/"
local running = true

local function split(input)
    local t = {}
    for w in input:gmatch("%S+") do
        table.insert(t, w)
    end
    return t
end

while running do
    -- Main loop
    write(path .. "&: ")
    local input = read(nil, nil)
    local args = split(input)
    local cmd = args[1]

    if cmd == nil then
        print("OUP")
    elseif cmd == "exit" or cmd == "close" then
        running = false

    elseif cmd == "help" then
        print("Commands:")
        print(" help  exit  close")
        print(" echo  clear")

    elseif cmd == "echo" then
        for i = 2, #args do
            write(args[i] .. " ")
        end
        print()

    elseif cmd == "clear" then
        term.clear()
        term.setCursorPos(1,1)

    else
        print("Unknown command: " .. cmd)
    end
end

print("Shell stopped.")
