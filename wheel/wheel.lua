local component = require("component")
local event = require("event")
local term = require("term")
local internet = component.internet
local fs = require("filesystem")

local rewards = dofile("/wheel/rewards.lua")
local config = dofile("/wheel/config.lua")

local pendingPath = "/wheel/pending.lua"

-- utils
local function loadPending()
  if not fs.exists(pendingPath) then return {} end
  return dofile(pendingPath)
end

local function savePending(data)
  local f = io.open(pendingPath, "w")
  f:write("return " .. require("serialization").serialize(data))
  f:close()
end

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

local function economyAdd(player, amount)
  local data = string.format(
    '{"player":"%s","amount":%d}',
    player, amount
  )
  internet.request(config.economy_api, data)
end

-- animation
local function spinAnimation()
  for i = 1, 20 do
    term.clear()
    print("Spinning" .. string.rep(".", i % 4))
    os.sleep(0.15 + i * 0.02)
  end
end

-- main
term.clear()
print("=== WHEEL OF FORTUNE ===")
print("Enter your nickname:")

local player = io.read()

print("Press ENTER to spin (cost " .. config.cost_per_spin .. " coins)")
io.read()

spinAnimation()

local reward = weightedRandom()
term.clear()
print("You won: " .. reward.name)

if reward.type == "money" then
  economyAdd(player, reward.amount)

elseif reward.type == "item" then
  local pending = loadPending()
  pending[player] = pending[player] or {}
  table.insert(pending[player], {
    item = reward.item,
    count = reward.count
  })
  savePending(pending)
end

print("Reward processed!")
