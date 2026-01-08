local TweenService = game:GetService("TweenService")
local ShapeWipe = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("ShapeWipe", {
    duration = 0.8,
    direction = "right", -- "right", "left", "up", "down"
})
]]

function ShapeWipe.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.elements = {}
	self.direction = self.config.direction or "right"
	self.color = Color3.fromRGB(255, 255, 255)

	local shapes = {
		"rbxassetid://12139960837", -- heart
		"rbxassetid://3057073083", -- star
		"rbxassetid://13518130183"  -- sparkle
	}

	function self:start()
		if self.running then return end
		self.running = true

		local container = Instance.new("Frame")
		container.Size = UDim2.fromScale(0, 1)
		container.Position = UDim2.fromScale(0, 0)
		container.BackgroundColor3 = self.color
		container.BackgroundTransparency = 1
		container.BorderSizePixel = 0
		container.Parent = self.target

		for i = 1, 8 do
			local shape = Instance.new("ImageLabel")
			shape.Image = shapes[math.random(1, #shapes)]
			shape.Size = UDim2.fromOffset(30, 30)
			shape.Position = UDim2.new(math.random(), math.random(), 0.5, 0)
			shape.AnchorPoint = Vector2.new(0.5, 0.5)
			shape.BackgroundTransparency = 1
			shape.ImageColor3 = Color3.new(1, 1, 1)
			shape.Rotation = math.random(0, 360)
			shape.BorderSizePixel = 0
			shape.Parent = container

			local rotateTween = TweenService:Create(shape, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
				Rotation = shape.Rotation + 360
			})

			local scaleTween = TweenService:Create(shape, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), {
				Size = UDim2.fromOffset(40, 40)
			})

			rotateTween:Play()
			scaleTween:Play()
			table.insert(self.elements, shape)
		end

		table.insert(self.elements, container)

		local wipeTween = TweenService:Create(container, TweenInfo.new(0.8, Enum.EasingStyle.Quad), {
			Size = UDim2.fromScale(1, 1)
		})

		local fadeOutTween = TweenService:Create(container, TweenInfo.new(0.3), {
			BackgroundTransparency = 1
		})

		wipeTween:Play()
		wipeTween.Completed:Connect(function()
			fadeOutTween:Play()
		end)

		fadeOutTween.Completed:Connect(function()
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

return ShapeWipe