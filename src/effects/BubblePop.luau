local TweenService = game:GetService("TweenService")
local BubblePop = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("BubblePop", {
    duration = 2,
    scale = 1.2,
    intensity = 2,
})
]]

function BubblePop.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.bubbles = {}
	self.scale = self.config.scale or 1
	self.intensity = self.config.intensity or 1

	local colors = {
		Color3.fromRGB(255, 182, 255),  -- Pink
		Color3.fromRGB(182, 255, 255),  -- Cyan
		Color3.fromRGB(255, 223, 255),  -- Light Pink
		Color3.fromRGB(255, 182, 223),  -- Rose
		Color3.fromRGB(200, 255, 255)   -- Light Blue
	}

	local function createBubble()
		local bubble = Instance.new("Frame")
		bubble.Size = UDim2.new(0, 30 * self.scale, 0, 30 * self.scale)
		bubble.Position = UDim2.new(math.random(), 0, 1.1, 0)
		bubble.AnchorPoint = Vector2.new(0.5, 0.5)
		bubble.BackgroundColor3 = colors[math.random(#colors)]
		bubble.BackgroundTransparency = 0.4
		bubble.Parent = self.target

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = bubble

		local shimmer = Instance.new("Frame")
		shimmer.Size = UDim2.new(0.3, 0, 0.3, 0)
		shimmer.Position = UDim2.new(
			math.random() * 0.6, 
			0, 
			math.random() * 0.6, 
			0
		)
		shimmer.BackgroundColor3 = Color3.new(1, 1, 1)
		shimmer.BackgroundTransparency = 0.3
		shimmer.Parent = bubble

		local shimmerCorner = Instance.new("UICorner")
		shimmerCorner.CornerRadius = UDim.new(1, 0)
		shimmerCorner.Parent = shimmer

		return bubble, shimmer
	end

	function self:start()
		if self.running then return end
		self.running = true

		task.spawn(function()
			while self.running do
				local bubble, shimmer = createBubble()
				table.insert(self.bubbles, bubble)

				local startX = bubble.Position.X.Scale
				local amplitude = math.random() * 0.2 + 0.1
				local frequency = math.random() * 2 + 1
				local startTime = tick()

				task.spawn(function()
					while bubble.Parent and self.running do
						local elapsed = tick() - startTime
						local wobble = math.sin(elapsed * frequency) * amplitude

						bubble.Position = UDim2.new(
							startX + wobble,
							0,
							1.1 - (elapsed * 0.3),
							0
						)

						shimmer.BackgroundTransparency = 0.3 + math.sin(elapsed * 3) * 0.2

						local scale = 1 + math.sin(elapsed * 3) * 0.1
						bubble.Size = UDim2.new(0, 30 * self.scale * scale, 0, 30 * self.scale * scale)

						if bubble.Position.Y.Scale < -0.1 then
							local popTween = TweenService:Create(bubble, TweenInfo.new(0.2), {
								Size = UDim2.new(0, 40 * self.scale, 0, 40 * self.scale),
								BackgroundTransparency = 1
							})
							popTween:Play()
							popTween.Completed:Connect(function()
								bubble:Destroy()
								table.remove(self.bubbles, table.find(self.bubbles, bubble))
							end)
							break
						end
						task.wait()
					end
				end)

				task.wait(0.3 / self.intensity)
			end
		end)
	end

	function self:stop()
		self.running = false
		for _, bubble in ipairs(self.bubbles) do
			local popTween = TweenService:Create(bubble, TweenInfo.new(0.2), {
				Size = UDim2.new(0, 40 * self.scale, 0, 40 * self.scale),
				BackgroundTransparency = 1
			})
			popTween:Play()
			popTween.Completed:Connect(function()
				bubble:Destroy()
			end)
		end
		self.bubbles = {}
	end

	return self
end

return BubblePop