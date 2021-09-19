-- luacheck: globals timer MAP_CONTROLLER_FUNC

local function Init(self, mapName)
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	local box1 = self:GetMetaTarget("secret_box1")
	local box2 = self:GetMetaTarget("secret_box2")
	local box3 = self:GetMetaTarget("secret_box3")
	local rebel_door = self:GetMetaTarget("sewer_secretdoor")
	local cinema1 = self:GetMetaTarget("sewer_secretdoor2")
	local cinema2 = self:GetMetaTarget("sewer_secretdoor3")
	local toiler_door = self:GetMetaTarget("grizzly_secretdoor")
	local metropol_door = self:GetMetaTarget("slums_secretdoor2")
	local metropol_window = self:GetMetaTarget("slums_secretdoor3")
	local puzzle_door = self:GetMetaTarget("grizzly_sewerdoor")

	box1:DisableCombineUse()
	box2:DisableCombineUse()
	box3:DisableCombineUse()
	rebel_door:DisableCombineUse()
	cinema1:DisableCombineUse()
	cinema2:DisableCombineUse()
	toiler_door:DisableCombineUse()
	metropol_door:DisableCombineUse()
	metropol_window:DisableCombineUse()
	puzzle_door:DisableCombineUse()
end

hook.Add("OnMapLogicInitialized", "pb_v2_secret_doors", Init)
