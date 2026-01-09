local TweenService = game:GetService("TweenService")
local Wobble = {}

--[[
EXAMPLE:
Animator:applyEffectWithConfig("Wobble", {
    duration = 2,
    intensity = 1,
    speed = 1
})
]]

function Wobble.new(target, config)
	local self = {}
	self.target = target
	self.config = config or {}
	self.running = false
	self.originalRotation = target.Rotation
	self.intensity = self.config.intensity or 1
	self.speed = self.config.speed or 1

	function self:start()
		if self.running then return end
		self.running = true

		task.spawn(function()
			local startTime = tick()
			while self.running do
				local elapsed = (tick() - startTime) * self.speed
				local wobble = math.sin(elapsed * 8) * (5 * self.intensity)
				local decay = math.exp(-elapsed * 0.5)

				self.target.Rotation = self.originalRotation + wobble * decay

				if decay < 0.01 then
					break
				end
				task.wait()
			end
			self.target.Rotation = self.originalRotation
			self.running = false
		end)
	end

	function self:stop()
		self.running = false
		local returnTween = TweenService:Create(self.target, TweenInfo.new(0.2), {
			Rotation = self.originalRotation
		})
		returnTween:Play()
	end

	return self
end

return Wobble