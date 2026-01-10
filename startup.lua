if active_os == nil then
    active_os = true
    settings.set("http.enable", true)
    os.reboot()
end
shell.run("wget", "", "startup.lua")
