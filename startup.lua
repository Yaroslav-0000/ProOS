local url = "https://raw.githubusercontent.com/Yaroslav-0000/ProOS/main/os.lua"
local res = http.get(url)
if res then
  local f = fs.open("startup.lua", "w")
  f.write(res.readAll())
  f.close()
  print("downloaded!")
else
  print("Error downloading OS")
end
 
