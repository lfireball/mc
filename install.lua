local component = require("component")
local internet = component.internet
local fs = require("filesystem")

local BASE_URL = "https://raw.githubusercontent.com/YOUR_GITHUB_NAME/wheel-of-fortune-oc/main/"

local files = {
  "wheel/wheel.lua",
  "wheel/rewards.lua",
  "wheel/config.lua",
  "wheel/pending.lua"
}

fs.makeDirectory("/wheel")

for _, file in ipairs(files) do
  local handle = internet.request(BASE_URL .. file)
  local data = ""
  for chunk in handle do
    data = data .. chunk
  end

  local f = io.open("/" .. file, "w")
  f:write(data)
  f:close()

  print("Installed: " .. file)
end

print("Installation complete!")
