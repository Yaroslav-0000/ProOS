local url_os = "https://raw.githubusercontent.com/Yaroslav-0000/ProOS/main/os.lua"
local res_os = http.get(url_os)
if res_os then
  local f = fs.open("startup.lua", "w")
  f.write(res_os.readAll())
  f.close()
  print("downloaded!")
  os.sleep(1)
  os.reboot()
else
  print("Error downloading OS")
end
 
