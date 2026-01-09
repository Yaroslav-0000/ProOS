path_cmd = "/"
running = true

while running do
    -- Main 
    local cmd = read(path_cmd .. "&: ")
    if cmd == "close" or cmd == "exit" then
        running = false
    end
end
