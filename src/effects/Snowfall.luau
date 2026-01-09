local TweenService = game:GetService("TweenService")
local Snowfall = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Snowfall", {
    duration = 5,
    scale = 1,
    intensity = 1,
    windSpeed = 0.5
})
]]

function Snowfall.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.particles = {}
	self.scale = self.config.scale or 1
	self.intensity = self.config.intensity or 1
	self.windSpeed = self.config.windSpeed or 0.5

	local function createSnowflake()
		local snowflake = Instance.new("Frame")
		local size = (4 + math.random() * 6) * self.scale
		snowflake.Size = UDim2.fromOffset(size, size)
		snowflake.Position = UDim2.new(math.random(), 0, -0.05, 0)
		snowflake.AnchorPoint = Vector2.new(0.5, 0.5)
		snowflake.BackgroundColor3 = Color3.new(1, 1, 1)
		snowflake.BackgroundTransparency = 0.1 + math.random() * 0.3
		snowflake.BorderSizePixel = 0
		snowflake.Parent = self.target

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = snowflake

		return snowflake
	end

	function self:start()
		if self.running then return end
		self.running = true

		task.spawn(function()
			while self.running do
				local snowflake = createSnowflake()
				table.insert(self.particles, snowflake)

				local startX = snowflake.Position.X.Scale
				local fallSpeed = 1.5 + math.random() * 1.5
				local wobbleSpeed = 1 + math.random() * 2
				local wobbleAmount = 0.05 + math.random() * 0.1

				task.spawn(function()
					local startTime = tick()
					while snowflake.Parent and self.running do
						local elapsed = tick() - startTime
						local wind = math.sin(elapsed * self.windSpeed) * 0.1
						local wobble = math.sin(elapsed * wobbleSpeed) * wobbleAmount

						snowflake.Position = UDim2.new(
							startX + wind + wobble,
							0,
							-0.05 + (elapsed / fallSpeed) * 0.4,
							0
						)

						if snowflake.Position.Y.Scale > 1.05 then
							snowflake:Destroy()
							table.remove(self.particles, table.find(self.particles, snowflake))
							break
						end
						task.wait()
					end
				end)

				task.wait(0.1 / self.intensity)
			end
		end)
	end

	function self:stop()
		self.running = false
		for _, particle in ipairs(self.particles) do
			local fadeTween = TweenService:Create(particle, TweenInfo.new(0.5), {
				BackgroundTransparency = 1
			})
			fadeTween:Play()
			fadeTween.Completed:Connect(function()
				particle:Destroy()
			end)
		end
		self.particles = {}
	end

	return self
end

return Snowfall