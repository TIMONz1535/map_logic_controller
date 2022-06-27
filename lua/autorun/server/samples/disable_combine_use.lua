-- © 2022 PostBellum HL2 RP. All rights reserved.

local ENTITY = FindMetaTable("Entity")

if not ENTITY.DisableCombineUse then
	-- You can directly change this function in your gamemode to disable the doors for Combines.
	function ENTITY:DisableCombineUse()
		hook.Run("EntityDisableCombineUse", self)
	end
end

-- If you don't want to unpack the addon, just use this hook.
--[[
hook.Add(
	"EntityDisableCombineUse",
	"Helix",
	function(ent)
		ent:SetNetVar("disabled", true)
	end
)
hook.Add(
	"EntityDisableCombineUse",
	"Clockwork",
	function(ent)
		Clockwork.entity:SetDoorFalse(ent, true)
	end
)
--]]
