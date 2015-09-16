-- prototype
local Border = {
  style = 0, --default to none
  thickness = 2,
  color = { 255, 255, 255, 255 } --default to white so images look right
  -- settable properties that aren't defaulted (since default style doesn't need them)
  -- image
}
Border.__index = Border

function Border:new(border)
  border = border or {}
  
  setmetatable(border, self)
  
  --other setup?
  
  return border
end

-- enum of Styles
Border.Styles = {
  None = 0,
  Flat = 1,
  --HardBevel = 2, -- 2 colour in/out
  BalancedOutline = 3, -- 2 colour line/fill, all three lines equal thickness
  WeightedOutline = 4, -- 2 colour line/fill, thickness weighted in favour of the middle
  --SoftBevel = 4 -- 3 colour highlight, fill, lowlight
  --Image = 5
}

function Border:draw(wnd)
  if self.style == self.Styles.None then self = false; return end -- make us false, so the background shadow works right, then return so we don't have a shadow
  
  -- shadow first, so it's underneath
  if wnd.shadow and wnd.bordershadow then
    self:drawShadow(wnd)
  end
  
  -- Now draw the actual window background
  if self.style == self.Styles.Flat then
    self:drawFlat(wnd)
  end
  if self.style == self.Styles.BalancedOutline
  or self.style == self.Styles.WeightedOutline then
    self:drawOutlined(wnd, self.style == self.Styles.BalancedOutline)
  end
end

function Border:drawShadow(wnd)
  if self.style == self.Styles.None then self = false; return end -- need this for the external call from Window:draw()
  
  if self.style == self.Styles.Image then
    --shadow the image shape
    
  else --default rectangle based shadow
    love.graphics.setColor(wnd.shadow)

    love.graphics.setLineWidth(self.thickness)
    love.graphics.rectangle("line",
      wnd.left + wnd.shadowoffset, wnd.top + wnd.shadowoffset,
      wnd.width, wnd.height)
  end
end

function Border:drawFlat(wnd)
  local color
  if type(self.color[1]) == "table" then --color has multiple colours
    color = self.color[1] -- we only use the first one for a flat border
  else
    color = self.color
  end
  love.graphics.setColor(color)
  
  love.graphics.setLineWidth(self.thickness)
  love.graphics.rectangle("line",
    wnd.left, wnd.top,
    wnd.width, wnd.height)
end

function Border:drawOutlined(wnd, balance)
  if type(self.color[1]) ~= "table" then --color has only one colour!
    self.color = { self.color } --wrap it inside a table of colours!
  end
  --colour order is outside colour, inside colour
  
  --deal with thickness
  local outer, inner
  if balance then
    outer = self.thickness / 3
    inner = outer
  else
    outer, inner = self:GetTripleWidth()
  end
  
  if not balance then
    -- Do the fill first
    love.graphics.setColor(self.color[2] or { 255, 255, 255, 255 }) --default to White, as always
    love.graphics.setLineWidth(inner)
    
    love.graphics.rectangle("line",
      wnd.left, wnd.top,
      wnd.width, wnd.height)
  end
  
  -- Do the outline
  love.graphics.setColor(self.color[1])
  love.graphics.setLineWidth(outer)
  
  -- positioning of outlines
  local outeroffset, inneroffset
  if balance then
    outeroffset = inner
    inneroffset = outeroffset
  else
    outeroffset = inner / 2
    inneroffset = outeroffset
  end
  
  --Outer outline
  love.graphics.rectangle("line",
    wnd.left - outeroffset, wnd.top - outeroffset,
    wnd.width + (2*outeroffset), wnd.height + (2*outeroffset))
  
  --Inner outline
  love.graphics.rectangle("line",
    wnd.left + inneroffset, wnd.top + inneroffset,
    wnd.width - (2*inneroffset), wnd.height - (2*inneroffset))
  
  if balance then
    -- Do the fill last
    love.graphics.setColor(self.color[2] or { 255, 255, 255, 255 }) --default to White, as always
    love.graphics.setLineWidth(inner)
    
    love.graphics.rectangle("line",
      wnd.left, wnd.top,
      wnd.width, wnd.height)
  end
end

-- Utility functions
function Border:GetDoubleWidth() --split the thickness in 2
  --Figure out the inside and outside thicknesses, from the provided thickness
  local even = self.thickness % 2  == 0
  local half
  
  if even then half = self.thickness / 2
  else half = (self.thickness - 1) / 2 end
  
  --returns outer, inner
  if even then return half, half
  else return half + 1, half end -- always make outer thicker, if uneven
end
function Border:GetTripleWidth() -- split the thickness in 3
  --Figure out the inside and outside thicknesses, from the provided thickness
  local even = self.thickness % 2  == 0
  local half
  
  if even then half = self.thickness / 2
  else half = (self.thickness - 1) / 2 end
  
  local inner = 0
  inner = even and half or half + 1 -- always make inner thicker, if uneven
  
  --do the same division check for outer
  even = half % 2 == 0
  if even then half = half / 2
  else half = (half - 1) / 2 end
  
  --returns outer, inner
  if even then return half, inner
  else return half, inner + 1 end -- always make inner thicker, if uneven
end

setmetatable(Border, { __call = function (self, border) return self:new(border) end})
return Border