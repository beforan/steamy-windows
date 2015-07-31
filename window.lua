-- Dual purpose Factory / Prototype
local Window = {
  --new window defaults (prototype properties)
  top = 0,
  left = 0,
  
  width = 150,
  height = 50,
  autosize = false,
  maxwidth = love.window.getWidth() / 2,
  
  contentMargin = 10,
  defaultAlign = "left",
  defaultFont = love.graphics.getFont()
}
Window.__index = Window --setup prototypal inheritance


-- Factory Method / Constructor
function Window:new (wnd)
  wnd = wnd or {}
  
  setmetatable(wnd, self)
  
  --other setup?
  if wnd.autosize then wnd:autoSize() end -- adjust width and height if autosize requested
  
  if wnd.x and not rawget(wnd, "left") then -- left overrides x
    wnd:setX(wnd.x); wnd.x = nil
  end
  if wnd.y and not rawget(wnd, "top") then -- top overrides y
    wnd:setY(wnd.y); wnd.y = nil
  end
  
  return wnd
end


-- Prototype Methods!

-- Drawing
function Window:draw()
  self:renderBackground()
  self:renderContent()
end
function Window:renderBackground()
  love.graphics.setColor { 60, 80, 200, 255 }
  love.graphics.rectangle("fill", self.left, self.top, self.width, self.height)
end
function Window:renderContent()
  if type(self.content) == "number" or type(self.content) == "string" then
    return self:renderContentString()
  end
  
  -- Parse Content table
end
function Window:renderContentString()
  love.graphics.setColor { 255, 255, 255, 255 }
  if love.graphics.getFont() ~= self.defaultFont then love.graphics.setFont(self.defaultFont) end
  love.graphics.printf(self.content, self.left + self.contentMargin, self.top + self.contentMargin, self.width - self.contentMargin * 2, self.defaultAlign)
end

-- Getters and Setters
function Window:getPos()
  return {
    x = self:getX(),
    y = self:getY(),
    unpack = function(self)
      return self.x, self.y
    end
  }
end
function Window:getX() return self.left + self.width / 2 end
function Window:getY() return self.top + self.height / 2 end

function Window:setPos(x, y)
  if type(x) == "table" then y = x.y; x = x.x end
  self:setX(x)
  self:setY(y)
end
function Window:setX(x) self.left = x - self.width / 2 end
function Window:setY(y) self.top = y - self.height / 2 end

-- Helpers
function Window:autoSize()
  -- Currently only working for TEXT content
  local font, lines = self.defaultFont, nil
  self.width, lines = font:getWrap(self.content, self.maxwidth - 2*self.contentMargin)
  self.width = self.width + 2*self.contentMargin
  
  self.height =
    (lines - 1) * (font:getHeight(self.content) * font:getLineHeight(self.content)) -- use line height for all lines except last
    + font:getHeight(self.content) -- leave last line unadjusted for line height
    + 2*self.contentMargin -- add vertical margins
end

-- Make the Factory callable and return it
setmetatable(Window, { __call = function (self, wnd) return self:new(wnd) end})
return Window