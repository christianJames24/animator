local TweenService = game:GetService("TweenService")
local Swipe = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Swipe", {
    duration = 0.4,
    direction = "right", -- "left", "right", "up", "down"
    color = Color3.fromRGB(255, 255, 255)
})
]]

function Swipe.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.elements = {}
	self.color = self.config.color or Color3.fromRGB(255, 182, 255)
	self.direction = self.config.direction or "right"

	function self:start()
		if self.running then return end
		self.running = true

		local swipe = Instance.new("Frame")
		swipe.BorderSizePixel = 0
		swipe.BackgroundColor3 = self.color
		swipe.BackgroundTransparency = 0.2
		swipe.Parent = self.target

		if self.direction == "right" then
			swipe.Size = UDim2.fromScale(0, 1)
			swipe.Position = UDim2.fromScale(0, 0)
			swipe.AnchorPoint = Vector2.new(0, 0)
		elseif self.direction == "left" then
			swipe.Size = UDim2.fromScale(0, 1)
			swipe.Position = UDim2.fromScale(1, 0)
			swipe.AnchorPoint = Vector2.new(1, 0)
		elseif self.direction == "down" then
			swipe.Size = UDim2.fromScale(1, 0)
			swipe.Position = UDim2.fromScale(0, 0)
			swipe.AnchorPoint = Vector2.new(0, 0)
		elseif self.direction == "up" then
			swipe.Size = UDim2.fromScale(1, 0)
			swipe.Position = UDim2.fromScale(0, 1)
			swipe.AnchorPoint = Vector2.new(0, 1)
		end

		table.insert(self.elements, swipe)

		local growGoals = {
			Size = (self.direction == "right" or self.direction == "left") 
				and UDim2.fromScale(1, 1) 
				or UDim2.fromScale(1, 1)
		}

		local growTween = TweenService:Create(swipe, TweenInfo.new(0.4, Enum.EasingStyle.Quad), growGoals)
		local shrinkTween = TweenService:Create(swipe, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			BackgroundTransparency = 1
		})

		growTween:Play()
		growTween.Completed:Connect(function()
			shrinkTween:Play()
		end)

		shrinkTween.Completed:Connect(function()
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

return Swipe