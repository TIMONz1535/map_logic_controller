--[[
	© 2021 PostBellum HL2 RP
	Author: TIMON_Z1535 - https://steamcommunity.com/profiles/76561198047725014
--]]
-- luacheck: globals hook FindMetaTable

local ENTITY = FindMetaTable("Entity")

-- You can directly change this function in your gamemode to disable the doors for Combines.
function ENTITY:DisableCombineUse()
	hook.Run("EntityDisableCombineUse", self)
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
