local TweenService = game:GetService("TweenService")
local Cut = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Cut", {
    duration = 0.5,
    angle = 45, -- diagonal angle
    color = Color3.fromRGB(255, 255, 255)
})
]]

function Cut.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.elements = {}
	self.angle = self.config.angle or 45
	self.color = self.config.color or Color3.fromRGB(255, 182, 255)

	function self:start()
		if self.running then return end
		self.running = true

		local topPiece = Instance.new("Frame")
		topPiece.Size = UDim2.fromScale(1, 0.5)
		topPiece.Position = UDim2.fromScale(0.5, 0.25)
		topPiece.AnchorPoint = Vector2.new(0.5, 0.5)
		topPiece.BackgroundColor3 = self.color
		topPiece.BackgroundTransparency = 0.1
		topPiece.BorderSizePixel = 0
		topPiece.Parent = self.target

		local bottomPiece = Instance.new("Frame")
		bottomPiece.Size = UDim2.fromScale(1, 0.5)
		bottomPiece.Position = UDim2.fromScale(0.5, 0.75)
		bottomPiece.AnchorPoint = Vector2.new(0.5, 0.5)
		bottomPiece.BackgroundColor3 = self.color
		bottomPiece.BackgroundTransparency = 0.1
		bottomPiece.BorderSizePixel = 0
		bottomPiece.Parent = self.target

		local shine = Instance.new("Frame")
		shine.Size = UDim2.fromScale(0.05, 1.5)
		shine.Position = UDim2.fromScale(0, 0.5)
		shine.BackgroundColor3 = Color3.new(1, 1, 1)
		shine.AnchorPoint = Vector2.new(0,0.5)
		shine.BackgroundTransparency = 0.5
		shine.BorderSizePixel = 0
		shine.Rotation = self.angle
		shine.Parent = self.target

		table.insert(self.elements, topPiece)
		table.insert(self.elements, bottomPiece)
		table.insert(self.elements, shine)

		local shineTween = TweenService:Create(shine, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			Position = UDim2.fromScale(1, 0.5),
			BackgroundTransparency = 1
		})

		local topTween = TweenService:Create(topPiece, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0.5, 0),
			BackgroundTransparency = 1
		})

		local bottomTween = TweenService:Create(bottomPiece, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = 1
		})

		shineTween:Play()
		task.wait(0.1)
		topTween:Play()
		bottomTween:Play()

		task.wait(0.4)
		self:stop()
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

return Cut