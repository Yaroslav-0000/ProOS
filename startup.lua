if active_os == nil then
    active_os = true
    settings.set("http.enable", true)
    os.reboot()
end
shell.run("wget", "https://raw.githubusercontent.com/Yaroslav-0000/ProOS/main/os.lua", "startup.lua")
