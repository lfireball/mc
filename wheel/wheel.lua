print("Wheel loaded!")
local term = require("term")
local fs = require("filesystem")
local ser = require("serialization")

local rewards = dofile("/wheel/rewards.lua")
local config = dofile("/wheel/config.lua")

local function weightedRandom()
  local sum = 0
  for _, r in ipairs(rewards) do sum = sum + r.weight end
  local pick = math.random(sum)
  local acc = 0
  for _, r in ipairs(rewards) do
    acc = acc + r.weight
    if pick <= acc then return r end
  end
end

local function spinAnimation()
  local frames = { "|", "/", "-", "\\" }
  for i = 1, 30 do
    term.clear()
    print("WHEEL OF FORTUNE")
    print("")
    print(" Spinning " .. frames[i % 4 + 1])
    os.sleep(0.08 + i * 0.01)
  end
end

term.clear()
local player = "Steve"

-- перевірка оплати
if not fs.exists("/wheel/paid_" .. player) then
  print("Payment not found!")
  return
end
fs.remove("/wheel/paid_" .. player)

spinAnimation()

local reward = weightedRandom()
term.clear()
print("YOU WON:")
print(reward.name)

if reward.type == "item" then
  local pending = dofile("/wheel/pending.lua")
  pending[player] = pending[player] or {}
  table.insert(pending[player], {
    item = reward.item,
    count = reward.count
  })

  local f = io.open("/wheel/pending.lua", "w")
  f:write("return " .. ser.serialize(pending))
  f:close()
end

print("")
print("Go to Withdraw Terminal")
