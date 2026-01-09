local TweenService = game:GetService("TweenService")
local Squish = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Squish", {
    duration = 0.5,
    intensity = 1
})
]]

function Squish.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.originalSize = target.Size
	self.intensity = self.config.intensity or 1

	function self:start()
		if self.running then return end
		self.running = true

		local squishAmount = 0.15 * self.intensity

		local squishDown = TweenService:Create(self.target, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(
				self.originalSize.X.Scale * (1 + squishAmount),
				self.originalSize.X.Offset * (1 + squishAmount),
				self.originalSize.Y.Scale * (1 - squishAmount),
				self.originalSize.Y.Offset * (1 - squishAmount)
			)
		})

		local squishUp = TweenService:Create(self.target, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(
				self.originalSize.X.Scale * (1 - squishAmount * 0.5),
				self.originalSize.X.Offset * (1 - squishAmount * 0.5),
				self.originalSize.Y.Scale * (1 + squishAmount * 0.7),
				self.originalSize.Y.Offset * (1 + squishAmount * 0.7)
			)
		})

		local settle1 = TweenService:Create(self.target, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			Size = UDim2.new(
				self.originalSize.X.Scale * (1 + squishAmount * 0.3),
				self.originalSize.X.Offset * (1 + squishAmount * 0.3),
				self.originalSize.Y.Scale * (1 - squishAmount * 0.2),
				self.originalSize.Y.Offset * (1 - squishAmount * 0.2)
			)
		})

		local settle2 = TweenService:Create(self.target, TweenInfo.new(0.15, Enum.EasingStyle.Elastic), {
			Size = self.originalSize
		})

		squishDown:Play()
		squishDown.Completed:Connect(function()
			squishUp:Play()
		end)
		squishUp.Completed:Connect(function()
			settle1:Play()
		end)
		settle1.Completed:Connect(function()
			settle2:Play()
		end)
		settle2.Completed:Connect(function()
			self:stop()
		end)
	end

	function self:stop()
		self.running = false
		self.target.Size = self.originalSize
	end

	return self
end

return Squish