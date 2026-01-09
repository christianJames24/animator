local TweenService = game:GetService("TweenService")
local Confetti = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Confetti", {
    duration = 3,
    scale = 1,
    intensity = 2
})
]]

function Confetti.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.particles = {}
	self.scale = self.config.scale or 1
	self.intensity = self.config.intensity or 1

	local colors = {
		Color3.fromRGB(255, 182, 193),
		Color3.fromRGB(255, 218, 185),
		Color3.fromRGB(186, 255, 201),
		Color3.fromRGB(186, 225, 255),
		Color3.fromRGB(255, 255, 186),
		Color3.fromRGB(223, 186, 255)
	}

	local function createConfetti()
		local confetti = Instance.new("Frame")
		local width = math.random(8, 15) * self.scale
		local height = math.random(4, 8) * self.scale
		confetti.Size = UDim2.fromOffset(width, height)
		confetti.Position = UDim2.new(math.random(), 0, -0.1, 0)
		confetti.AnchorPoint = Vector2.new(0.5, 0.5)
		confetti.BackgroundColor3 = colors[math.random(#colors)]
		confetti.Rotation = math.random(0, 360)
		confetti.BorderSizePixel = 0
		confetti.Parent = self.target

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.2, 0)
		corner.Parent = confetti

		return confetti
	end

	function self:start()
		if self.running then return end
		self.running = true

		task.spawn(function()
			while self.running do
				local confetti = createConfetti()
				table.insert(self.particles, confetti)

				local startX = confetti.Position.X.Scale
				local swayAmount = (math.random() - 0.5) * 0.4
				local rotSpeed = math.random(-360, 360)
				local fallSpeed = 2 + math.random() * 2

				task.spawn(function()
					local startTime = tick()
					while confetti.Parent and self.running do
						local elapsed = tick() - startTime
						local sway = math.sin(elapsed * 3) * 0.1 + swayAmount * elapsed

						confetti.Position = UDim2.new(
							startX + sway,
							0,
							-0.1 + (elapsed / fallSpeed),
							0
						)
						confetti.Rotation = confetti.Rotation + rotSpeed * 0.016

						if confetti.Position.Y.Scale > 1.1 then
							confetti:Destroy()
							table.remove(self.particles, table.find(self.particles, confetti))
							break
						end
						task.wait()
					end
				end)

				task.wait(0.05 / self.intensity)
			end
		end)
	end

	function self:stop()
		self.running = false
		for _, particle in ipairs(self.particles) do
			local fadeTween = TweenService:Create(particle, TweenInfo.new(0.3), {
				BackgroundTransparency = 1
			})
			fadeTween:Play()
			fadeTween.Completed:Connect(function()
				particle:Destroy()
			end)
		end
		self.particles = {}
	end

	return self
end

return Confetti