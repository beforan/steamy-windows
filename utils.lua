-- static
local Utils = {}

-- enum of gradient styles
local function linearGradient(angle)
  return { type = "linear", angle = Utils.reduceAngle(angle) }
end
Utils.GradientStyles = {
  Linear = linearGradient, --arbitrary angle
  Horizontal = function () return linearGradient(270) end,
  Vertical = function () return linearGradient() end
}

--build a gradient from a spec, with colors and style information
function Utils.createGradient(spec)
  -- we (probably) don't want to render the gradient to an mage like DvD
  -- I would prefer to wholly fragment shader this
end

-- reduce any angle in degrees to between 0 and 359
function Utils.reduceAngle(angle)
  if not angle then return 0 end
  local coeff = math.floor(math.abs(angle) / 360)
  if angle < 0 then
    return angle + ((coeff + 1) * 360)
  else
    return angle - (coeff * 360)
  end
end

return Utils