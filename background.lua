local relativeFolder = (...):match("(.-)[^%.]+$") -- returns 'lib.foo.'

local Border = require (relativeFolder .. "border")

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

function Background:new(back)
  back = back or {}
  
  setmetatable(back, self)
  
  --other setup?
  
  return back
end

Background.BaseMeshSize = 10

Background.Meshes = {
  Internal = {
    Base = love.graphics.newMesh({ -- a 10x10 square, all white, no texture, "fan" mode
        { 0, 0, 0, 0 }, -- top left
        { Background.BaseMeshSize, 0, 1, 0 }, -- top right
        { Background.BaseMeshSize, Background.BaseMeshSize, 1, 1 }, -- bottom right
        { 0, Background.BaseMeshSize, 0, 1 } -- bottom left
      })
  },
  Private = {
    -- maybe?
  },
  Public = {
    -- maybe maybe?
  }
}

Background.Effects = {
  Internal = {
    -- FF6 style gradients ;)
    QuantizeInterpolation = love.graphics.newShader([[ 
      vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
        return floor(color * 30.0) / 30.0; }]])
  },
  Custom = {
  }
}


-- enum of styles
Background.Styles = {
  Transparent = 0,
  Solid = 1,
  FourCorner = 2,
  SimpleHorizontal = 3, -- these are shortcuts which abuse FourCorner, which is cheaper than using the
  SimpleVertical = 4,   -- Linear method if you don't need to angle it or use multiple colour points
--  Linear = 3,
--  Radial = 4,
--  Rectangle = 5,
--  StretchTexture = 6,
--  TileTexture = 7
}

function Background:draw(wnd)
  if self.style == self.Styles.Transparent then return end -- return so we can't go on to have a shadow :\
  
  -- shadow first, so it's underneath
  self:drawShadow(wnd)
  
  -- Now draw the actual window background
  if self.style == self.Styles.Solid then
    self:drawSolid(wnd)
  end
  if self.style == self.Styles.FourCorner then
    self:drawFourCorner(wnd)
  end
end

function Background:drawShadow(wnd)
  if wnd.border then
    -- don't shadow the background if there is a border - the shadow will be incorrect!
    if wnd.border.style ~= Border.Styles.None then return end
  end
  
  if wnd.shadow then
    local mesh = self.Meshes.Internal.Base
    if mesh:isAttributeEnabled("VertexColor") then mesh:setAttributeEnabled("VertexColor", false) end -- don't use per-vertex colours!
    
    love.graphics.setColor(wnd.shadow)
    love.graphics.draw(mesh,
      wnd.left + wnd.shadowoffset,
      wnd.top + wnd.shadowoffset,
      0,
      wnd.width / Background.BaseMeshSize,
      wnd.height / Background.BaseMeshSize)
  end
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
  if mesh:isAttributeEnabled("VertexColor") then mesh:setAttributeEnabled("VertexColor", false) end -- don't use per-vertex colours!
  
  love.graphics.draw(mesh,
    wnd.left, wnd.top, 0,
    wnd.width / Background.BaseMeshSize,
    wnd.height / Background.BaseMeshSize)
end

function Background:drawFourCorner(wnd)
  if type(self.color[1]) ~= "table" then --color has only one colour!
    self.color = { self.color } --wrap it inside a table of colours!
  end
  
  love.graphics.setColor(255, 255, 255, 255) -- reset colour so the vertex colours are as expected

  local mesh = self.Meshes.Internal.Base
  if not mesh:isAttributeEnabled("VertexColor") then mesh:setAttributeEnabled("VertexColor", true) end -- use per-vertex colours!
  
  -- set each vertex colour from the first 4 colours in self.color
  for i = 1, 4 do
    local x, y, u, v, r, g, b, a = mesh:getVertex(i)
    if self.color[i] then
      r, g, b, a = self.color[i][1], self.color[i][2], self.color[i][3], self.color[i][4]
    else
      r, g, b, a = 255, 255, 255, 255 -- default to white if unspecified (matches LOVE's Mesh conventions)
    end
    
    mesh:setVertex(i, x, y, u, v, r, g, b, a)
  end
  
  --love.graphics.setShader(self.Effects.Internal.QuantizeInterpolation)
  
  love.graphics.draw(mesh,
    wnd.left, wnd.top, 0,
    wnd.width / Background.BaseMeshSize,
    wnd.height / Background.BaseMeshSize)
  
  --love.graphics.setShader()
end

setmetatable(Background, { __call = function (self, back) return self:new(back) end})
return Background