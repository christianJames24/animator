local TweenService = game:GetService("TweenService")
local Select = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Select", {
    duration = 0.3,
    color = Color3.fromRGB(255, 255, 255),
    thickness = 3
})
]]

function Select.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.elements = {}
	self.color = self.config.color or Color3.fromRGB(255, 182, 255)
	self.thickness = self.config.thickness or 3
	self.duration = self.config.duration or 0.3

	function self:start()
		if self.running then return end
		self.running = true

		local frame = Instance.new("Frame")
		frame.Size = UDim2.fromScale(1, 1)
		frame.Position = UDim2.fromScale(0.5, 0.5)
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundTransparency = 1
		frame.Parent = self.target

		local stroke = Instance.new("UIStroke")
		stroke.Color = self.color
		stroke.Thickness = self.thickness
		stroke.Transparency = 0
		stroke.Parent = frame

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = frame

		table.insert(self.elements, frame)

		local expandTween = TweenService:Create(frame, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
			Size = UDim2.fromScale(1.1, 1.1)
		})

		local shrinkTween = TweenService:Create(frame, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
			Size = UDim2.fromScale(1, 1)
		})

		expandTween:Play()
		expandTween.Completed:Connect(function()
			shrinkTween:Play()
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

return Select