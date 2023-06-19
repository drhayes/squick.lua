local Object = require('lib.classic')
local lume = require('lib.lume')

local GameObject = Object:extend()

function GameObject:new(x, y)
  self.components = {}
  self.removals = {}
  self.x, self.y = x or 0, y or 0
end

function GameObject:add(component)
  table.insert(self.components, component)
  component:added(self)
  return component
end

function GameObject:has(componentType)
  -- local componentType = getmetatable(component)
  for i = 1, #self.components do
    local component = self.components[i]
    if component:is(componentType) then return true end
  end
  return false
end

function GameObject:findFirst(componentType)
  for i = 1, #self.components do
    local component = self.components[i]
    if component:is(componentType) then return component end
  end
end

function GameObject:remove(component)
  lume.remove(self.components, component)
  component:removed()
end

function GameObject:init()
  local removals = self.removals
  lume.clear(removals)
  -- Initialize.
  for i = 1, #self.components do
    local component = self.components[i]
    if component.active then component:init() end
    if component.removeMe then table.insert(removals, component) end
  end
  -- Remove.
  for i = 1, #removals do
    local component = removals[i]
    self:remove(component)
  end
end

function GameObject:preUpdate(dt)
  lume.clear(self.removals)
  -- Update.
  for i = 1, #self.components do
    local component = self.components[i]
    if component.active then component:preUpdate(dt) end
  end
end

function GameObject:update(dt)
  -- Update.
  for i = 1, #self.components do
    local component = self.components[i]
    if component.active then component:update(dt) end
  end
end

function GameObject:physicsUpdate(dt)
  -- Update.
  for i = 1, #self.components do
    local component = self.components[i]
    if component.active then component:physicsUpdate(dt) end
  end
end

function GameObject:postUpdate(dt)
  local removals = self.removals
  -- Update.
  for i = 1, #self.components do
    local component = self.components[i]
    if component.active then component:postUpdate(dt) end
    if component.removeMe then table.insert(removals, component) end
  end
  -- Remove.
  for i = 1, #removals do
    local component = removals[i]
    self:remove(component)
  end
end

function GameObject:draw()
  for i = 1, #self.components do
    local component = self.components[i]
    if component.active then
      component:draw()
      component:debugDraw()
    end
  end
end

-- Called when GameObject is added to game.
function GameObject:gobAdded()
  for i = 1, #self.components do
    local component = self.components[i]
    component:gobAdded()
  end
end

-- Called when GameObject is removed from game.
function GameObject:gobRemoved()
  for i = 1, #self.components do
    local component = self.components[i]
    component:gobRemoved()
  end
end

-- Called to send all the Components a message.
-- TODO: Consider using a message queue.
-- Calls to sendMessage during message handlers would be queued up and processed later.
function GameObject:sendMessage(message, ...)
  if self.removeMe then return end
  self:onMessage(message, ...)
  for i = 1, #self.components do
    local component = self.components[i]
    if component.active then component:onMessage(message, ...) end
  end
end

-- Receive a message.
function GameObject:onMessage(message, ...) end

return GameObject
