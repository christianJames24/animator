local TweenService = game:GetService("TweenService")
local Sparkles2 = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Sparkles2", {
    duration = 2,
    scale = 1,
    intensity = 1
})
]]

function Sparkles2.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.sparkles = {}
	self.scale = self.config.scale or 1
	self.intensity = self.config.intensity or 1

	local function createFourPointStar()
		local container = Instance.new("Frame")
		container.Size = UDim2.fromOffset(20 * self.scale, 20 * self.scale)
		container.BackgroundTransparency = 1
		container.AnchorPoint = Vector2.new(0.5, 0.5)
		container.Parent = self.target

		local vertical = Instance.new("Frame")
		vertical.Size = UDim2.fromScale(0.15, 1)
		vertical.Position = UDim2.fromScale(0.5, 0.5)
		vertical.AnchorPoint = Vector2.new(0.5, 0.5)
		vertical.BackgroundColor3 = Color3.new(1, 1, 1)
		vertical.BorderSizePixel = 0
		vertical.Parent = container

		local vCorner = Instance.new("UICorner")
		vCorner.CornerRadius = UDim.new(1, 0)
		vCorner.Parent = vertical

		local horizontal = Instance.new("Frame")
		horizontal.Size = UDim2.fromScale(1, 0.15)
		horizontal.Position = UDim2.fromScale(0.5, 0.5)
		horizontal.AnchorPoint = Vector2.new(0.5, 0.5)
		horizontal.BackgroundColor3 = Color3.new(1, 1, 1)
		horizontal.BorderSizePixel = 0
		horizontal.Parent = container

		local hCorner = Instance.new("UICorner")
		hCorner.CornerRadius = UDim.new(1, 0)
		hCorner.Parent = horizontal

		local glow = Instance.new("ImageLabel")
		glow.Image = "rbxassetid://7331234161"
		glow.ImageColor3 = Color3.fromRGB(255, 240, 250)
		glow.ImageTransparency = 0.5
		glow.BackgroundTransparency = 1
		glow.Size = UDim2.fromScale(2, 2)
		glow.Position = UDim2.fromScale(0.5, 0.5)
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.Parent = container

		return container
	end

	function self:start()
		if self.running then return end
		self.running = true

		task.spawn(function()
			while self.running do
				local star = createFourPointStar()
				star.Position = UDim2.new(math.random() * 0.8 + 0.1, 0, math.random() * 0.8 + 0.1, 0)
				star.Size = UDim2.fromOffset(0, 0)
				star.Rotation = math.random(-15, 15)
				table.insert(self.sparkles, star)

				local growTween = TweenService:Create(star, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
					Size = UDim2.fromOffset(20 * self.scale, 20 * self.scale)
				})

				local rotateTween = TweenService:Create(star, TweenInfo.new(0.4), {
					Rotation = star.Rotation + 45
				})

				local shrinkTween = TweenService:Create(star, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Size = UDim2.fromOffset(0, 0)
				})

				growTween:Play()
				rotateTween:Play()
				growTween.Completed:Wait()
				task.wait(0.1)
				shrinkTween:Play()
				shrinkTween.Completed:Connect(function()
					star:Destroy()
					table.remove(self.sparkles, table.find(self.sparkles, star))
				end)

				task.wait(0.15 / self.intensity)
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

return Sparkles2