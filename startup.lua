path_cmd = "/"
running = true

while running do
    -- Main 
    write(path_cmd .. "&: ")
    local cmd = read(nil, nil)
    if cmd == "close" or cmd == "exit" then
        running = false
    end
end
