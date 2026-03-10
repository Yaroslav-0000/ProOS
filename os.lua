print("Start-OS")

running = true

local url_os = "https://raw.githubusercontent.com/Yaroslav-0000/ProOS/main/os.lua"

local res_os = http.get(url_os)
if res_os then
    local new_content = res_os.readAll()
    res_os.close()

    local need_update = true

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
        os.sleep(0.2)
        os.reboot()
    end
else
    print("Error downloading OS")
end

ProOS()
