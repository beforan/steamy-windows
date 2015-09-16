-- prototype
local Background = {
  style = 0, --default to transparent
  
  -- settable properties that aren't defautled (since default style doesn't need them)
  -- angle
  -- color
  -- pos
  -- 
}
Background.__index = Background

Background.Meshes = {
  Internal = {
    Base = love.graphics.newMesh({ -- a 10x10 square, all white, no texture, "fan" mode
        { 0, 0, 0, 0 }, -- top left
        { 10, 0, 1, 0 }, -- top right
        { 10, 10, 1, 1 }, -- bottom right
        { 0, 10, 0, 1 } -- botom left
      })
  },
  Private = {
    -- maybe?
  },
  Public = {
    -- maybe maybe?
  }
}


-- enum of styles
Background.Styles = {
  Transparent = 0,
  Solid = 1
--  FourCorner = 2,
--  Linear = 3,
--  Radial = 4,
--  Rectangle = 5,
--  StretchTexture = 6,
--  TileTexture = 7
}

function Background:new(back)
  back = back or {}
  
  setmetatable(back, self)
  
  --other setup?
  
  return back
end

function Background:draw(wnd)
  if self.style == self.Styles.Solid then
    self:drawSolid(wnd)
  end
  --Transparent or anything else will just return as it met no case above!
end

function Background:drawSolid(wnd)
  local color
  if type(self.color[1]) == "table" then --color has multiple colours
    color = self.color[1] -- we only use the first one for a solid fill
  else
    color = self.color
  end
  love.graphics.setColor(color)
  
  local mesh = self.Meshes.Internal.Base
  if mesh:hasVertexColors then mesh:setVertexColors(false) end --don't use per-vertex colours!
  
  love.graphics.draw(mesh,
    wnd.left, wnd.top, 0, wnd.width / 10, wnd.height / 10) -- don't like the magic numbers
end

setmetatable(Background, { __call = function (self, back) return self:new(back) end})
return Background