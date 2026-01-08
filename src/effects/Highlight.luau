local TweenService = game:GetService("TweenService")
local Highlight = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Highlight", {
    duration = 0.6,
    intensity = 1,
    color = Color3.fromRGB(255, 255, 255)
})
]]

function Highlight.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.elements = {}
	self.intensity = self.config.intensity or 1
	self.color = self.config.color or Color3.fromRGB(255, 192, 203)

	function self:start()
		if self.running then return end
		self.running = true

		local container = Instance.new("Frame")
		container.Size = UDim2.fromScale(1, 1)
		container.Position = UDim2.fromScale(0.5, 0.5)
		container.AnchorPoint = Vector2.new(0.5, 0.5)
		container.BackgroundTransparency = 1
		container.Parent = self.target

		local stroke = Instance.new("UIStroke")
		stroke.Color = self.color
		stroke.Thickness = 3
		stroke.Transparency = 0
		stroke.Parent = container

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = container

		local glow = Instance.new("ImageLabel")
		glow.Image = "rbxassetid://7331234161"
		glow.ImageColor3 = self.color
		glow.ImageTransparency = 0.5
		glow.BackgroundTransparency = 1
		glow.Size = UDim2.fromScale(1.2, 1.2)
		glow.Position = UDim2.fromScale(0.5, 0.5)
		glow.AnchorPoint = Vector2.new(0.5, 0.5)
		glow.Parent = container

		table.insert(self.elements, container)

		local growTween = TweenService:Create(container, TweenInfo.new(0.2), {
			Size = UDim2.fromScale(1.1, 1.1)
		})

		local shrinkTween = TweenService:Create(container, TweenInfo.new(0.2), {
			Size = UDim2.fromScale(1, 1)
		})

		local fadeTween = TweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Transparency = 1
		})

		local glowTween = TweenService:Create(glow, TweenInfo.new(0.3), {
			ImageTransparency = 1,
			Size = UDim2.fromScale(1.4, 1.4)
		})

		growTween:Play()
		growTween.Completed:Connect(function()
			shrinkTween:Play()
			fadeTween:Play()
			glowTween:Play()
		end)

		glowTween.Completed:Connect(function()
			self:stop()
		end)
	end

	function self:stop()
		self.running = false
		for _, element in ipairs(self.elements) do
			element:Destroy()
		end
		self.elements = {}
	end

	return self
end

return Highlight