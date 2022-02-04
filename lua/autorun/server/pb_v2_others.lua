--[[
	© 2021 PostBellum HL2 RP
	Author: TIMON_Z1535 - https://steamcommunity.com/profiles/76561198047725014
--]]
-- luacheck: globals hook Clockwork LOGTYPE_URGENT cwCPPlug ents IsValid FACTION_MPF FACTION_ADMIN FACTION_INCOG

local proxies = {}

-- TODO: Add GetMapCreatedEntity for entity list, and AcceptInputProxy meta
-- TODO: Add AddOutput meta, add remove output (supress outputs)
local function AcceptInputProxy(target, input, callback)
	for _, v in ipairs(target) do
		local idx = v:EntIndex()
		proxies[idx] = proxies[idx] or {}
		proxies[idx][input] = callback
	end
end

hook.Add(
	"AcceptInput",
	"MapLogicProxy",
	function(ent, input, activator, caller, value)
		local callbacks = proxies[ent:EntIndex()]
		if callbacks then
			local callback = callbacks[input]
			if callback then
				return callback(ent, input, activator, caller, value)
			end
		end
	end
)

local function RestrictionProxy(ent, input, activator, caller, value)
	if IsValid(activator) and activator:IsPlayer() then
		local faction = activator:GetFaction()
		if faction == FACTION_MPF or faction == FACTION_ADMIN or faction == FACTION_INCOG then
			return
		end

		local whitelisted = activator:GetData("Whitelisted")
		if not whitelisted or #whitelisted == 0 then
			activator:Ban(
				0,
				"Багоюз, до разбирательств.",
				function(name, duration, reason)
					Clockwork.player:NotifyAll("Console: '" .. name .. "' has been banned permanently (" .. reason .. ").")
				end
			)
		end

		return true
	end
end

local function GenLog(message)
	return function(ent, activator)
		local name = activator:IsPlayer() and ("Игрок " .. activator:Name()) or ("Нечто " .. tostring(activator))
		local text = message:format(name)

		Clockwork.kernel:PrintLog(LOGTYPE_URGENT, text)
		for _, v in ipairs(cwCPPlug:GetAdminListeners()) do
			Clockwork.player:Notify(v, text)
		end
	end
end

local function Init(controller, mapName)
	if mapName ~= "rp_pb_industrial17_v2" then
		return
	end

	local terms_no = controller:GetMetaTarget("start_button_no")
	terms_no.OnPressed = function(ent, activator)
		if activator:IsPlayer() then
			activator:Kick("Вы ответили неправильно!")
		end
	end

	local nexus_comend = controller:GetMetaTarget("nexus_curfew")
	local nexus_kk = controller:GetMetaTarget("nexus_lockdowndeactivate")
	local nexus_judgement = controller:GetMetaTarget("nexus_judeactivate")
	local nexus_gate = controller:GetMetaTarget("nexus_globe_bulkhead_close_button")
	local cwu_button = controller:GetMetaTarget(ents.GetMapCreatedEntity(2591))
	local ration_button = controller:GetMetaTarget(ents.GetMapCreatedEntity(4546))

	local nexus_kpp1 = controller:GetMetaTarget("nexus_admin_but01")
	local nexus_kpp2 = controller:GetMetaTarget("nexus_admin_but02")
	local nexus_kpp3 = controller:GetMetaTarget("nexus_admin_but03")
	local nexus_kpp4 = controller:GetMetaTarget("nexus_admin_but04")
	local nexus_kpp5 = controller:GetMetaTarget("nexus_admin_but05")
	local nexus_ga_window = controller:GetMetaTarget(ents.GetMapCreatedEntity(5619))
	local nexus_ga_bridge1 = controller:GetMetaTarget(ents.GetMapCreatedEntity(4843))
	local nexus_ga_bridge2 = controller:GetMetaTarget(ents.GetMapCreatedEntity(4830))
	local nexus_ga_bridge3 = controller:GetMetaTarget(ents.GetMapCreatedEntity(4826))
	local nexus_hall1 = controller:GetMetaTarget(ents.GetMapCreatedEntity(4597))
	local nexus_hall2 = controller:GetMetaTarget(ents.GetMapCreatedEntity(4596))
	local nexus_hall3 = controller:GetMetaTarget(ents.GetMapCreatedEntity(4516))
	local nexus_main_elevator = controller:GetMetaTarget("nexus_tunnel_elevator1_button")
	local vkz1 = controller:GetMetaTarget("kpp_button1")
	local vkz2 = controller:GetMetaTarget("kpp_button2")
	local kpp3_1 = controller:GetMetaTarget(ents.GetMapCreatedEntity(3989))
	local kpp3_2 = controller:GetMetaTarget(ents.GetMapCreatedEntity(3958))
	local kpp3_3 = controller:GetMetaTarget(ents.GetMapCreatedEntity(3988))

	AcceptInputProxy(nexus_comend, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_kk, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_judgement, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_gate, "Use", RestrictionProxy)
	AcceptInputProxy(cwu_button, "Use", RestrictionProxy)
	AcceptInputProxy(ration_button, "Use", RestrictionProxy)

	AcceptInputProxy(nexus_kpp1, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_kpp2, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_kpp3, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_kpp4, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_kpp5, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_ga_window, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_ga_bridge1, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_ga_bridge2, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_ga_bridge3, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_hall1, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_hall2, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_hall3, "Use", RestrictionProxy)
	AcceptInputProxy(nexus_main_elevator, "Use", RestrictionProxy)
	AcceptInputProxy(vkz1, "Use", RestrictionProxy)
	AcceptInputProxy(vkz2, "Use", RestrictionProxy)
	AcceptInputProxy(kpp3_1, "Use", RestrictionProxy)
	AcceptInputProxy(kpp3_2, "Use", RestrictionProxy)
	AcceptInputProxy(kpp3_3, "Use", RestrictionProxy)

	nexus_comend.OnIn = GenLog("[MapLogic] %s активировал Комендатский час!")
	nexus_comend.OnOut = GenLog("[MapLogic] %s выключил Комендатский час.")
	nexus_kk.OnIn = GenLog("[MapLogic] %s активировал Красный код!")
	nexus_kk.OnOut = GenLog("[MapLogic] %s выключил Красный код.")
	nexus_judgement.OnIn = GenLog("[MapLogic] %s активировал Судебное разбирательство отменено!")
	nexus_judgement.OnOut = GenLog("[MapLogic] %s выключил Судебное разбирательство отменено.")
	nexus_gate.OnIn = GenLog("[MapLogic] %s открыл Южные ворота!")
	nexus_gate.OnOut = GenLog("[MapLogic] %s закрыл Южные ворота.")
	cwu_button.OnPressed = GenLog("[MapLogic] %s активировал оповещение Офиса ГСР!")

	-- make func_door usable, otherwise it will be permanently opened by Combines
	ration_button:SetKeyValue("spawnflags", 292)
	-- fix wait delay of func_door
	ration_button.OnClose = function(ent, activator)
		ent:Fire("Lock")
		GenLog("[MapLogic] %s активировал оповещение Выдачи Рационов!")(ent, activator)
		controller:TimerSimple(
			60,
			function()
				ent:Fire("Unlock")
			end
		)
	end
	ration_button.OnOpen = function(ent, activator)
		ent:Fire("Lock")
		GenLog("[MapLogic] %s выключил оповещение Выдачи Рационов.")(ent, activator)
		controller:TimerSimple(
			60,
			function()
				ent:Fire("Unlock")
			end
		)
	end
end

hook.Add("OnMapLogicInitialized", "pb_v2_others", Init)
