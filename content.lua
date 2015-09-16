--This file details all the default content type classes
local Text = {
  text = ""
}
Text.__index = Text
function Text:new(text)
  text = (type(text) == "table") and text
    or (type(text) == "string") and { text }
    or {}
  setmetatable(text, self)
  return text
end
setmetatable(Text, { __call = function (self, ...) return self:new(...) end })

function Text:process(parent)
  -- inherit parent values if ours aren't set
  self.color = self.color or parent.color
  self.font = self.font or parent.font
  self.align = self.align or parent.align
  self.shadow = self.shadow or parent.shadow
  
  -- exply margins if necessary
  self.margin.top = self.margin.top or self.margin or 0
  self.margin.left = self.margin.left or self.margin or 0
  self.margin.bottom = self.margin.bottom or self.margin.top
  self.margin.right = self.margin.right or self.margin.left
  
  -- positioning
  self.top = parent.padding.top + self.margin.top
  self.left = parent.padding.left + self.margin.left
  
  -- dimensions
  self.width = parent.width - (self.margin.left + self.margin.right) - (parent.padding.left + parent.padding.right)
  --self.height = 
end

function Text:draw(parent)
  if love.graphics.getFont() ~= parent.font then love.graphics.setFont(parent.font) end
  
  if parent.shadow then
    love.graphics.setColor(parent.shadow)
    love.graphics.printf(self[1], parent.left + parent.padding.left + 1, parent.top + parent.padding.top + 1, parent.width - (parent.padding.left + parent.padding.right), self.align)
  end
  
  love.graphics.setColor(parent.color)
  love.graphics.printf(self[1], parent.left + parent.padding.left, parent.top + parent.padding.top, parent.width - (parent.padding.left + parent.padding.right), self.align)
end

--local Speech = {}
--Speech.__index = Speech
--function Speech:new(speech)
--  speech = speech or {}
--  setmetatable(speech, self)
--  return speech
--end


--expose them all
local content = {
  Text = Text
  --Speech = Speech
}
-- Make them all callable
for _, v in pairs(content) do
  setmetatable(v, { __call = function (self, ...) return self:new(...) end })
end

return content;