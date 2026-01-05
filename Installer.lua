local url = "https://api.github.com/repos/Yaroslav-0000/ProOS/contents"
local res = http.get(url, {["User-Agent"]="CC:T ProOS Installer"})
if not res then error("HTTP disabled or request failed") end

local data = textutils.unserializeJSON(res.readAll())
for _, file in ipairs(data) do
  if file.type == "file" then
    print("Downloading "..file.name)
    local fRes = http.get(file.download_url, {["User-Agent"]="CC:T ProOS Installer"})
    if fRes then
      fs.makeDir("/proos")
      local f = fs.open("/proos/"..file.name, "w")
      f.write(fRes.readAll())
      f.close()
    else
      print("Failed to download "..file.name)
    end
  end
end
