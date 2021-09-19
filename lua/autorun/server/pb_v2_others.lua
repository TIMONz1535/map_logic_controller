--[[
	© 2021 PostBellum HL2 RP
	Author: TIMON_Z1535 - https://steamcommunity.com/profiles/76561198047725014
--]]
-- luacheck: globals hook Clockwork LOGTYPE_URGENT cwCPPlug ents

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
	local nexus_comend = controller:GetMetaTarget("nexus_curfew")
	local nexus_kk = controller:GetMetaTarget("nexus_lockdowndeactivate")
	local nexus_judgement = controller:GetMetaTarget("nexus_judeactivate")
	local nexus_gate = controller:GetMetaTarget("nexus_globe_bulkhead_close_button")

	terms_no.OnPressed = function(ent, activator)
		if activator:IsPlayer() then
			activator:Kick("Вы ответили неправильно!")
		end
	end

	nexus_comend.OnIn = GenLog("[MapLogic] %s активировал Комендатский час!")
	nexus_comend.OnOut = GenLog("[MapLogic] %s выключил Комендатский час.")
	nexus_kk.OnIn = GenLog("[MapLogic] %s активировал Красный код!")
	nexus_kk.OnOut = GenLog("[MapLogic] %s выключил Красный код.")
	nexus_judgement.OnIn = GenLog("[MapLogic] %s активировал Судебное разбирательство отменено!")
	nexus_judgement.OnOut = GenLog("[MapLogic] %s выключил Судебное разбирательство отменено.")
	nexus_gate.OnIn = GenLog("[MapLogic] %s открыл Южные ворота!")
	nexus_gate.OnOut = GenLog("[MapLogic] %s закрыл Южные ворота.")

	local cwu_button = controller:GetMetaTarget(ents.GetMapCreatedEntity(2591))
	cwu_button.OnPressed = GenLog("[MapLogic] %s активировал оповещение Офиса ГСР!")

	local ration_button = controller:GetMetaTarget(ents.GetMapCreatedEntity(4546))
	-- make func_door usable, otherwise it will be permanently opened by Combine
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
