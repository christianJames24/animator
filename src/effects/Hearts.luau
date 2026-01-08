local TweenService = game:GetService("TweenService")
local Hearts = {}

--[[
EXAMPLE:

Animator:applyEffectWithConfig("Hearts", {
	duration = 0.5,
	scale = 1.5,
	intensity = 2,
	rotation = 0
})
]]

function Hearts.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.hearts = {}

	self.numberOfHearts = 8
	self.scale = self.config.scale or 1
	self.intensity = self.config.intensity or 1
	self.rotation = self.config.rotation or 45

	local function createHeart()
		local heart = Instance.new("ImageLabel")
		heart.Image = "rbxassetid://12139960837"
		heart.BackgroundTransparency = 1
		heart.Size = UDim2.new(0, 30 * self.scale, 0, 30 * self.scale)
		heart.Position = UDim2.new(0.5, 0, 0.5, 0)
		heart.AnchorPoint = Vector2.new(0.5, 0.5)
		heart.Parent = self.target
		return heart
	end

	local function animateHeart(heart, index)
		local startRotation = Random.new():NextNumber(-180, 180)
		local endRotation = startRotation + (360 * self.rotation)

		heart.Rotation = startRotation
		heart.ImageTransparency = 0

		local angle = (index / self.numberOfHearts) * math.pi * 2
		local radius = 100 * self.intensity
		local endPos = UDim2.new(
			0.5 + math.cos(angle) * radius / self.target.AbsoluteSize.X,
			0,
			0.5 + math.sin(angle) * radius / self.target.AbsoluteSize.Y,
			0
		)

		local tweenInfo = TweenInfo.new(
			1.5,
			Enum.EasingStyle.Cubic,
			Enum.EasingDirection.Out,
			0,
			false,
			0
		)

		local heartTween = TweenService:Create(heart, tweenInfo, {
			Position = endPos,
			Size = UDim2.new(0, 0, 0, 0),
			ImageTransparency = 1,
			Rotation = endRotation
		})

		heartTween.Completed:Connect(function()
			heart:Destroy()
		end)

		heartTween:Play()
	end

	function self:start()
		if self.running then return end
		self.running = true

		task.spawn(function()
			while self.running do
				for i = 1, self.numberOfHearts do
					local heart = createHeart()
					table.insert(self.hearts, heart)
					animateHeart(heart, i)
				end
				task.wait(0.5)
			end
		end)
	end

	function self:stop()
		self.running = false
		for _, heart in ipairs(self.hearts) do
			heart:Destroy()
		end
		self.hearts = {}
	end

	target.AncestryChanged:Connect(function(_, parent)
		if not parent and self.running then
			self:stop()
		end
	end)

	return self
end

return Hearts