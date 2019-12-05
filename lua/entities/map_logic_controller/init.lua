-- luacheck: globals ents ENT PB_GenerateTimeId Stack timer IsValid isfunction

--[[
	Please don't create multiple map_logic_controllers.
	Unlock all doors for elevator.
	Disable all sounds for buttons on floor and in elevator.
	Repeat path tracks in the ring for hot reload.
--]]
local META_TARGET = {}

-- Симулирует вызов функции на энтити ent:SomeFunc()
META_TARGET.__index = function(self, key)
	return function(_, ...)
		for _, v in ipairs(self.entities) do
			if IsValid(v) then
				assert(isfunction(v[key]), "no valid method: " .. key)
				v[key](v, ...)
			end
		end
	end
end

-- Регистрирует OutputCallback для энтитей.
META_TARGET.__newindex = function(self, output, func)
	assert(#self.entities == 1, "attempt to register callback to multiple entities: " .. output)
	local ent = self.entities[1]
	assert(IsValid(ent), "no valid ent")

	ent["map_logic_" .. output] = func
	ent:Fire("AddOutput", ("%s %s:OutputCallback:%s:0:-1"):format(output, self.managerName, output))
end

-- ====================================================================================================

ENT.Base = "base_point"
ENT.Type = "point"

function ENT:AcceptInput(input, activator, ent, output)
	if input == "OutputCallback" then
		ent["map_logic_" .. output](ent, activator)
		return true
	end
end

function ENT:GetMetaTarget(name)
	assert(self.cache, "no cache in manager")
	local entities = self.cache[name]
	assert(entities, "no entities with name: " .. name)

	local metaTarget = {
		managerName = self:GetName(),
		entities = entities
	}
	return setmetatable(metaTarget, META_TARGET)
end

function ENT:CacheEntNames()
	local cache = {}
	for _, v in ipairs(ents.GetAll()) do
		if v:CreatedByMap() then
			local name = v:GetName()
			cache[name] = cache[name] or Stack()
			cache[name]:Push(v)
		end
	end
	self.cache = cache
end

function ENT:Initialize()
	-- no multiple controllers
	for _, v in ipairs(ents.FindByClass("map_logic_controller")) do
		if v ~= self then
			v:Remove()
		end
	end

	self:SetName("logic_manager_" .. PB_GenerateTimeId())
	self:CacheEntNames()

	self:SetupOfficeElevator()

	self.cache = nil
end

-- ====================================================================================================

function ENT:SetupOfficeElevator()
	local buttonDelay = 3
	local elevator = self:GetMetaTarget("office_elevator")
	local path1 = self:GetMetaTarget("office_elevator_path1")
	local path2 = self:GetMetaTarget("office_elevator_path2")
	local path3 = self:GetMetaTarget("office_elevator_path3")
	local button1 = self:GetMetaTarget("office_elevator_button1")
	local button2 = self:GetMetaTarget("office_elevator_button2")
	local button3 = self:GetMetaTarget("office_elevator_button3")
	local call1 = self:GetMetaTarget("office_elevator_call1")
	local call2 = self:GetMetaTarget("office_elevator_call2")
	local call3 = self:GetMetaTarget("office_elevator_call3")
	local gate = self:GetMetaTarget("office_elevator_gate")
	local doors1 = self:GetMetaTarget("office_elevator_doors1")
	local doors2 = self:GetMetaTarget("office_elevator_doors2")
	local doors3 = self:GetMetaTarget("office_elevator_doors3")

	button1:SetKeyValue("wait", buttonDelay)
	button2:SetKeyValue("wait", buttonDelay)
	button3:SetKeyValue("wait", buttonDelay)
	call1:SetKeyValue("wait", buttonDelay)
	call2:SetKeyValue("wait", buttonDelay)
	call3:SetKeyValue("wait", buttonDelay)

	local isMoving = false
	local targetFloor = 1
	local currentFloor = 1

	local function moveTo(floor)
		if isMoving or currentFloor == floor then
			return false
		end
		isMoving = true
		targetFloor = floor

		gate:Fire("SetAnimation", "close")
		doors1:Fire("Close")
		doors2:Fire("Close")
		doors3:Fire("Close")

		if currentFloor < targetFloor then
			elevator:Fire("StartForward", nil, 1)
		else
			elevator:Fire("StartBackward", nil, 1)
		end
		return true
	end

	local function checkFloor(floor)
		if targetFloor ~= floor then
			return false
		end
		currentFloor = floor
		elevator:Fire("Stop", nil, 0)

		if currentFloor == 1 then
			doors1:Fire("Open", 1)
		elseif currentFloor == 2 then
			doors2:Fire("Open", 1)
		else
			doors3:Fire("Open", 1)
		end
		gate:Fire("SetAnimation", "open", 1.5)

		timer.Simple(
			buttonDelay,
			function()
				isMoving = false
			end
		)
		return true
	end

	local function moveToGen(floor)
		return function(ent, activator)
			if moveTo(floor) then
				ent:EmitSound("buttons/button24.wav", 75)
			else
				ent:EmitSound("buttons/button8.wav", 75)
			end
		end
	end

	button1.OnPressed = moveToGen(1)
	button2.OnPressed = moveToGen(2)
	button3.OnPressed = moveToGen(3)

	call1.OnPressed = moveToGen(1)
	call2.OnPressed = moveToGen(2)
	call3.OnPressed = moveToGen(3)

	path1.OnPass = function(ent, activator)
		checkFloor(1)
	end
	path2.OnPass = function(ent, activator)
		checkFloor(2)
	end
	path3.OnPass = function(ent, activator)
		checkFloor(3)
	end
end

--[[

	do
		local elevator = GetOne("med_elevator")
		local button = GetOne("med_elevator_button")
		local call1 = GetOne("med_elevator_call1")
		local call2 = GetOne("med_elevator_call2")
		local gate = GetOne("med_elevator_gate")
		local doors1 = GetMany("med_elevator_doors1")
		local doors2 = GetMany("med_elevator_doors2")

		button:SetKeyValue("wait", 3)
		call1:SetKeyValue("wait", 3)
		call2:SetKeyValue("wait", 3)

		local floor = 0
		local function move()
			doors1:Fire("Close")
			doors2:Fire("Close")
			gate:Fire("SetAnimation", "close")
			-- can play sound and delay
			elevator:Fire("Toggle", nil, 0.5)
		end

		button.OnPressed = move
		call1.OnPressed = move
		call2.OnPressed = move

		elevator.OnFullyClosed = function()
			elevator:Fire("Toggle")
			elevator:Fire("SetAnimation", "close")
		end

		elevator.OnFullyOpen = function()
			elevator:Fire("Toggle")
			elevator:Fire("SetAnimation", "close")
		end

		-- BindOutput(
		-- 	elevator,
		-- 	"OnClose",
		-- 	function()
		-- 		elevator:Fire("Toggle")
		-- 	end
		-- )
	end
	--]]
--------------------------

local man = ents.Create("map_logic_controller")
man:Spawn()
