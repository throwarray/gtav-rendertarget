function toModel (model)
	if type(model) == 'string' then
		model = GetHashKey(model)
	else
		model = tonumber(model) -- or 0
	end

	return model
end

function LoadModel (model)
	model = toModel(model)

	if not IsModelInCdimage(model) then
		return --0
	end

	RequestModel(model)

	while not HasModelLoaded(model) do Citizen.Wait(0) end

	return model
end

function XYZ (x, y, z)
	if x == nil then
		x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1)))
	elseif type(x) == 'table' then
		z = x.z
		y = x.y
		x = x.x
	end

	return 1.0 * tonumber(x or 0), 1.0 * tonumber(y or 0), 1.0 * tonumber(z or 0)
end

function SpawnObject (model, coords, ang, networked)
	local model = LoadModel(model)
	local x, y, z, entity

	if model then
		x, y, z = XYZ(coords)
		entity = CreateObject(model, x, y, z, networked == true, true, true)
		SetEntityHeading(entity, ang or 0.0)
		SetModelAsNoLongerNeeded(model)

		return entity
	end
end


function CreateNamedRenderTargetForModel(name, model)
	local handle = 0

	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, 0)
	end

	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end

	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end

	return handle
end

function DestroyObject (entity)
	SetEntityAsMissionEntity(entity,  false,  true)
	DeleteObject(entity)

	return entity
end

------------------------------------------------------------

local MENU
local MENU_ID = GetHashKey("bkr_prop_rt_clubhouse_plan_01a")
local MENU_TARGET = "clubhouse_plan_01a"
local MENU_HANDLE

AddEventHandler('onResourceStop', function (...)
    if resource == GetCurrentResourceName() then
        DetachEntity(MENU, 1, true)
        DestroyObject(MENU)
    end
end)


Citizen.CreateThread(function()
    Wait(100)

    local coords = GetEntityCoords(PlayerPedId())

    MENU = SpawnObject(MENU_ID, {
        x = coords.x,
        y = coords.y,
        z = coords.z
    }, 0.0, false)

    MENU_HANDLE = CreateNamedRenderTargetForModel(MENU_TARGET, MENU_ID)

    local camRot
    local items = { "Item 1", "Item 2", "Item 3", "Item 4", "Item 5" }
    local forward



    local currentItemIndex = 1
    local selectedItemIndex = 1
    local checkbox = true


    WarMenu.CreateMenu('test', 'Test title')
    WarMenu.CreateSubMenu('closeMenu', 'test', 'Are you sure?')


    AttachEntityToEntity(
       MENU, PlayerPedId(),
        31086, 4103, -- head bone
        0.0, 0.0, 0.0, -- FIXME position
        0.0, 0.0, 0.0, -- rotation
        false, false, false, false, 2, true
    )


    local function onChecked (checked) checkbox = checked end

    local function onCombo (currentIndex, selectedIndex)
        currentItemIndex = currentIndex
        selectedItemIndex = selectedIndex
    end

    while true do
        ClearDrawOrigin()
        SetTextRenderId(MENU_HANDLE)
    	Set_2dLayer(4)
    	Citizen.InvokeNative(0xC6372ECD45D73BCD, 1) -- clear?

        if WarMenu.IsMenuOpened('test') then
            camRot = GetGameplayCamRot()

            SetEntityHeading(MENU, camRot.z) -- FIXME DOESNT THIS WORK WHEN PINNED?

            if WarMenu.CheckBox('Checkbox', checkbox, onChecked) then

            elseif WarMenu.ComboBox('Combobox', items, currentItemIndex, selectedItemIndex, onCombo) then

            elseif WarMenu.MenuButton('Exit', 'closeMenu') then end

            WarMenu.Display()

        elseif WarMenu.IsMenuOpened('closeMenu') then
            if WarMenu.Button('Yes') then WarMenu.CloseMenu()
            elseif WarMenu.MenuButton('No', 'test') then end

            WarMenu.Display()
        elseif IsControlJustReleased(0, 244) then --M by default
            WarMenu.OpenMenu('test')

            forward = GetEntityForwardVector(PlayerPedId())

            SetEntityCoords(MENU, coords + forward * 1.0)
        end

        SetTextRenderId(GetDefaultScriptRendertargetRenderId())
        Citizen.Wait(0)
    end
end)
