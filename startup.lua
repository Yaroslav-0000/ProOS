path_cmd = "/"
running = true

while running do
    -- Main 
    write(path_cmd .. "&: ")
    local cmd = read()
    if cmd == "close" or cmd == "exit" then
        running = false
    end
end
