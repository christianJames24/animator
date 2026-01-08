local TweenService = game:GetService("TweenService")
local MagicCircle = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("MagicCircle", {
    duration = 2,
    scale = 1.2,
    intensity = 1,
    color = Color3.fromRGB(255, 255, 255)
})
]]

function MagicCircle.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.elements = {}
	self.scale = self.config.scale or 1
	self.intensity = self.config.intensity or 1
	self.color = self.config.color or Color3.fromRGB(255, 182, 255)

	local function createCircle()
		local container = Instance.new("Frame")
		container.Size = UDim2.new(0, 0, 0, 0)
		container.BackgroundTransparency = 1
		container.Position = UDim2.new(0.5, 0, 0.5, 0)
		container.AnchorPoint = Vector2.new(0.5, 0.5)
		container.Parent = self.target

		local circle = Instance.new("ImageLabel")
		circle.Image = "rbxassetid://7452563698"
		circle.ImageColor3 = self.color
		circle.BackgroundTransparency = 1
		circle.Size = UDim2.new(1, 0, 1, 0)
		circle.Position = UDim2.new(0.5, 0, 0.5, 0)
		circle.AnchorPoint = Vector2.new(0.5, 0.5)
		circle.Parent = container

		local innerCircle = circle:Clone()
		innerCircle.Size = UDim2.new(0.7, 0, 0.7, 0)
		innerCircle.ImageTransparency = 0.3
		innerCircle.Parent = container

		local glow = Instance.new("ImageLabel")
		glow.Image = "rbxassetid://5845458206"
		glow.ImageColor3 = self.color
		glow.ImageTransparency = 0.7
		glow.BackgroundTransparency = 1
		glow.Size = UDim2.new(1.5, 0, 1.5, 0)
		glow.Position = UDim2.new(0.5, 0, 0.5, 0)
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.Parent = container

		return {
			container = container,
			circle = circle,
			innerCircle = innerCircle,
			glow = glow
		}
	end

	function self:start()
		if self.running then return end
		self.running = true

		task.spawn(function()
			while self.running do
				local elements = createCircle()
				table.insert(self.elements, elements)

				local appearTween = TweenService:Create(elements.container, TweenInfo.new(0.5), {
					Size = UDim2.new(0, 200 * self.scale, 0, 200 * self.scale)
				})
				appearTween:Play()

				task.spawn(function()
					local startTime = tick()
					while self.running and elements.container.Parent do
						local elapsed = tick() - startTime
						elements.circle.Rotation = elapsed * 30
						elements.innerCircle.Rotation = elapsed * -45

						local pulse = math.sin(elapsed * 2)
						elements.glow.ImageTransparency = 0.7 + pulse * 0.2
						elements.glow.Size = UDim2.new(1.5 + pulse * 0.1, 0, 1.5 + pulse * 0.1, 0)

						task.wait()
					end
				end)

				task.wait(3 / self.intensity)

				local fadeTween = TweenService:Create(elements.container, TweenInfo.new(0.5), {
					Size = UDim2.new(0, 0, 0, 0),
					Rotation = elements.container.Rotation + 180
				})
				fadeTween:Play()
				fadeTween.Completed:Connect(function()
					elements.container:Destroy()
					table.remove(self.elements, table.find(self.elements, elements))
				end)
			end
		end)
	end

	function self:stop()
		self.running = false
		for i, elements in ipairs(self.elements) do
			task.spawn(function()
				task.wait(i * 0.15)--stagger

				local glowTween = TweenService:Create(elements.glow, TweenInfo.new(0.3), {
					ImageTransparency = 1,
					Size = UDim2.new(1.2, 0, 1.2, 0)
				})
				glowTween:Play()

				task.wait(0.1)
				local innerTween = TweenService:Create(elements.innerCircle, TweenInfo.new(0.4), {
					Size = UDim2.new(0, 0, 0, 0),
					ImageTransparency = 1,
					Rotation = elements.innerCircle.Rotation + 180
				})
				innerTween:Play()

				task.wait(0.1)
				local containerTween = TweenService:Create(elements.container, TweenInfo.new(0.5), {
					Size = UDim2.new(0, 0, 0, 0),
					Rotation = elements.container.Rotation + 180
				})
				containerTween:Play()

				containerTween.Completed:Connect(function()
					elements.container:Destroy()
				end)
			end)
		end
		self.elements = {}
	end

	return self
end

return MagicCircle