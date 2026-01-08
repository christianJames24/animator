local TweenService = game:GetService("TweenService")
local Petals = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Petals", {
    duration = 2,
    scale = 1.2,
    intensity = 2,
    windSpeed = 0.5
})
]]

function Petals.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.petals = {}
	self.scale = self.config.scale or 1
	self.intensity = self.config.intensity or 1
	self.windSpeed = self.config.windSpeed or 1
	self.time = 0

	local function createPetal()
		local petal = Instance.new("ImageLabel")
		petal.Image = "rbxassetid://14437254504"
		petal.BackgroundTransparency = 1
		petal.Size = UDim2.new(0, 20 * self.scale, 0, 20 * self.scale)
		petal.Position = UDim2.new(math.random(), 0, -0.1, 0)
		petal.Rotation = math.random(0, 360)
		petal.Parent = self.target
		return petal
	end

	function self:start()
		if self.running then return end
		self.running = true
		task.spawn(function()
			while self.running do
				local petal = createPetal()
				table.insert(self.petals, petal)
				local startX = petal.Position.X.Scale
				local duration = 3 / self.intensity
				task.spawn(function()
					local elapsed = 0
					local startTime = tick()
					while elapsed < duration and petal.Parent do
						elapsed = tick() - startTime
						local alpha = elapsed / duration
						local windX = math.sin(elapsed * self.windSpeed) * 0.2
						local newX = startX + windX
						petal.Position = UDim2.new(
							newX,
							0,
							-0.1 + (1.2 * alpha),
							0
						)
						petal.Rotation = petal.Rotation + math.sin(elapsed * 2) * 1.5
						local sizeScale = 1 + math.sin(elapsed * 4) * 0.1
						petal.Size = UDim2.new(0, 20 * self.scale * sizeScale, 0, 20 * self.scale * sizeScale)
						task.wait()
					end
					if petal.Parent then
						petal:Destroy()
						table.remove(self.petals, table.find(self.petals, petal))
					end
				end)
				task.wait(0.2 / self.intensity)
			end
		end)
	end

	function self:stop()
		self.running = false
		for _, petal in ipairs(self.petals) do
			local currentPosition = petal.Position
			local currentSize = petal.Size
			local currentRotation = petal.Rotation

			task.spawn(function()
				local fadeTween = TweenService:Create(petal, TweenInfo.new(0.8), {
					ImageTransparency = 1,
					Position = UDim2.new(currentPosition.X.Scale + (math.random() - 0.5) * 0.2, 
						0, 
						currentPosition.Y.Scale + 0.1, 
						0),
					Size = UDim2.new(0, currentSize.X.Offset * 0.5, 0, currentSize.Y.Offset * 0.5),
					Rotation = currentRotation + math.random(-90, 90)
				})
				fadeTween:Play()
				task.wait(0.8)
				petal:Destroy()
			end)
		end
		self.petals = {}
	end

	return self
end

return Petals