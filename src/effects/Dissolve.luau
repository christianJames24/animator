local TweenService = game:GetService("TweenService")
local Dissolve = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Dissolve", {
    duration = 1,
    particleSize = 8,
    color = Color3.fromRGB(255, 182, 255)
})
]]

function Dissolve.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.particles = {}
	self.particleSize = self.config.particleSize or 8
	self.color = self.config.color or Color3.fromRGB(255, 182, 255)

	function self:start()
		if self.running then return end
		self.running = true

		local container = Instance.new("Frame")
		container.Size = UDim2.fromScale(1, 1)
		container.BackgroundTransparency = 1
		container.ClipsDescendants = false
		container.Parent = self.target
		table.insert(self.particles, container)

		local cols = math.ceil(self.target.AbsoluteSize.X / self.particleSize)
		local rows = math.ceil(self.target.AbsoluteSize.Y / self.particleSize)

		for x = 1, cols do
			for y = 1, rows do
				local particle = Instance.new("Frame")
				particle.Size = UDim2.fromOffset(self.particleSize, self.particleSize)
				particle.Position = UDim2.fromScale((x-0.5)/cols, (y-0.5)/rows)
				particle.AnchorPoint = Vector2.new(0.5, 0.5)
				particle.BackgroundColor3 = self.color
				particle.BackgroundTransparency = 0.3
				particle.BorderSizePixel = 0
				particle.Parent = container

				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0.3, 0)
				corner.Parent = particle

				table.insert(self.particles, particle)

				local delay = ((x + y) / (cols + rows)) * 0.5 + math.random() * 0.2
				local endY = particle.Position.Y.Scale - 0.3 - math.random() * 0.2
				local endX = particle.Position.X.Scale + (math.random() - 0.5) * 0.3

				task.spawn(function()
					task.wait(delay)
					local dissolveTween = TweenService:Create(particle, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
						Position = UDim2.fromScale(endX, endY),
						Size = UDim2.fromOffset(0, 0),
						BackgroundTransparency = 1,
						Rotation = math.random(-180, 180)
					})
					dissolveTween:Play()
				end)
			end
		end

		task.wait(1.5)
		self:stop()
	end

	function self:stop()
		self.running = false
		for _, particle in ipairs(self.particles) do
			particle:Destroy()
		end
		self.particles = {}
	end

	return self
end

return Dissolve