local relativeFolder = (...):match("(.-)[^%.]+$") -- returns 'lib.foo.'

local Content = require (relativeFolder .. "content")
local Background = require (relativeFolder .. "background")
local Border = require (relativeFolder .. "border")

-- prototype
local Window = {
  top = 0,
  left = 0,
  
  width = 150,
  height = 50,
  autosize = false,
  maxwidth = love.window.getWidth() / 2,
  
  padding = 10,
  align = "left",
  
  font = love.graphics.getFont(),
  color = { 255, 255, 255, 255 },
  background = { 50, 90, 200, 255 },
  shadow = false, --{ 50, 50, 50, 255 },
  shadowoffset = 5,
  contentshadow = { 50, 50, 50, 255 },
  border = Border { style = Border.Styles.WeightedOutline, thickness = 9, color = { 120, 120, 120, 255 } }, --false,
  bordershadow = false -- changes render order for Window.shadow color
}
Window.__index = Window

-- ctor
function Window:new (wnd)
  wnd = wnd or {}
  
  setmetatable(wnd, self)
  
  --other setup?
  --exply padding
  if type(wnd.padding) == "table" then
    wnd.padding.top = wnd.padding.top or 0
    wnd.padding.left = wnd.padding.left or 0
    wnd.padding.bottom = wnd.padding.bottom or wnd.padding.top
    wnd.padding.right = wnd.padding.right or wnd.padding.left
  else
    wnd.padding = {
      top = tostring(wnd.padding),
      left = tostring(wnd.padding),
      bottom = tostring(wnd.padding),
      right = tostring(wnd.padding)
    }
  end
  --Window:processContent()
  
  if wnd.autosize then wnd:autoSize() end
  
  if wnd.x and not rawget(wnd, "left") then
    wnd:setX(wnd.x); wnd.x = nil
  end
  if wnd.y and not rawget(wnd, "top") then
    wnd:setY(wnd.y); wnd.y = nil
  end
  
  return wnd
end

function Window:processContent()
  return self.content:process(self)
end


-- Drawing
function Window:draw()
  -- If we have a border but are NOT using border shadow,
  -- We need to draw the shadow first, to be bottom-most
  if self.border and self.shadow and not self.bordershadow then
    self.border:drawShadow(self)
  end
  
  --normal draw order resumes
  self:drawBackground()
  self:drawContent()
  self:drawBorder()
end
function Window:drawBackground()
  if type(self.background) ~= "table" then return end
  if self.background.draw then return self.background:draw(self) end
  
  --if it doesn't have a draw method, it's just an RGBA colour table
  --create a background this one time, then use its draw method
  -- so we don't maintain 2 copies of solid fill draw
  self.background = Background {
      style = Background.Styles.Solid,
      color = self.background
    }
  self.background:draw(self)
end
function Window:drawContent()
  if type(self.content) == "number" or type(self.content) == "string" then
    self.content = Content.Text(tostring(self.content))
  end
  
  self.content:draw(self)
end
function Window:drawBorder()
  if type(self.border) ~= "table" then return end
  if self.border.draw then return self.border:draw(self) end
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
  local font, lines = self.font, nil
  self.width, lines = font:getWrap(self.content, self.maxwidth - (self.padding.left + self.padding.right))
  self.width = self.width + (self.padding.left + self.padding.right)
  
  self.height =
    (lines - 1) * (font:getHeight(self.content) * font:getLineHeight(self.content)) -- use line height for all lines except last
    + font:getHeight(self.content) -- leave last line unadjusted for line height
    + (self.padding.top + self.padding.bottom) -- add vertical padding
end

setmetatable(Window, { __call = function (self, wnd) return self:new(wnd) end})
return Window