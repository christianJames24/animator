local TweenService = game:GetService("TweenService")
local Sparkle = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Sparkle", {
    duration = 2,
    scale = 2,
    intensity = 2,
    color = Color3.fromRGB(255, 220, 255)
})
]]

function Sparkle.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.sparkles = {}
	self.scale = self.config.scale or 1
	self.intensity = self.config.intensity or 1
	self.color = self.config.color or Color3.fromRGB(255, 220, 255)

	local function createSparkle()
		local sparkle = Instance.new("ImageLabel")
		sparkle.Image = "rbxassetid://13518130183"
		sparkle.ImageColor3 = self.color
		sparkle.BackgroundTransparency = 1
		sparkle.Size = UDim2.fromOffset(0, 0)
		sparkle.AnchorPoint = Vector2.new(0.5, 0.5)
		sparkle.Parent = self.target

		local glow = Instance.new("ImageLabel")
		glow.Image = "rbxassetid://7331234161"
		glow.ImageColor3 = self.color
		glow.ImageTransparency = 0.5
		glow.BackgroundTransparency = 1
		glow.Size = UDim2.fromScale(1.5, 1.5)
		glow.Position = UDim2.fromScale(0.5, 0.5)
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.Parent = sparkle

		return sparkle
	end

	function self:start()
		if self.running then return end
		self.running = true

		task.spawn(function()
			while self.running do
				local sparkle = createSparkle()
				sparkle.Position = UDim2.new(math.random() * 0.8 + 0.1, 0, math.random() * 0.8 + 0.1, 0)
				table.insert(self.sparkles, sparkle)

				local size = (20 + math.random() * 15) * self.scale

				local appear = TweenService:Create(sparkle, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
					Size = UDim2.fromOffset(size, size),
					Rotation = math.random(-30, 30)
				})

				local disappear = TweenService:Create(sparkle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Size = UDim2.fromOffset(0, 0),
					ImageTransparency = 1
				})

				appear:Play()
				appear.Completed:Wait()
				task.wait(0.1)
				disappear:Play()
				disappear.Completed:Connect(function()
					sparkle:Destroy()
					table.remove(self.sparkles, table.find(self.sparkles, sparkle))
				end)

				task.wait(0.1 / self.intensity)
			end
		end)
	end

	function self:stop()
		self.running = false
		for _, sparkle in ipairs(self.sparkles) do
			sparkle:Destroy()
		end
		self.sparkles = {}
	end

	return self
end

return Sparkle