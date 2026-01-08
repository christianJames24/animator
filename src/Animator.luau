local Animator = {}
local Effects = {}

export type AnimatorConfig = {
	duration: number?,
	easing: string?,
	delay: number?,
	repeatCount: number?,
	reverses: boolean?,
	amplitude: number?,
	frequency: number?,
	scale: number?,
	rotation: number?,
	transparency: number?,
	intensity: number?
}

function Animator.new(uiObject: GuiObject)
	local self = {
		target = uiObject,
		activeEffects = {}
	}

	local function loadEffects()
		local scriptModules = script:GetChildren()
		for _, module in ipairs(scriptModules) do
			if module:IsA("ModuleScript") then
				Effects[module.Name] = require(module)
			end
		end
	end
	loadEffects()

	function self:applyEffect(effectName: string, duration: number?)
		if Effects[effectName] then
			local effect = Effects[effectName].new(self.target)
			effect:start()
			table.insert(self.activeEffects, effect)
			if duration then
				task.delay(duration, function()
					effect:stop()
					table.remove(self.activeEffects, table.find(self.activeEffects, effect))
				end)
			end
			return effect
		end
		warn("Effect not found:", effectName)
		return nil
	end

	function self:applyEffectWithConfig(effectName: string, config: AnimatorConfig)
		if Effects[effectName] then
			local effect = Effects[effectName].new(self.target, config)
			effect:start()
			table.insert(self.activeEffects, effect)
			if config.duration then
				task.delay(config.duration, function()
					effect:stop()
					table.remove(self.activeEffects, table.find(self.activeEffects, effect))
				end)
			end
			return effect
		end
		warn("Effect not found:", effectName)
		return nil
	end

	function self:stopAll()
		for _, effect in ipairs(self.activeEffects) do
			effect:stop()
		end
		self.activeEffects = {}
	end

	return self
end

return Animator