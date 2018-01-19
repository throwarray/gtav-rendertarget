
local function CreateNamedRenderTargetForModel(name, model)
	local handle = 0

	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, 0) -- TODO wuts bool?
	end

	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end

	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end

	return handle
end


local function LoadScaleForm(scaleform)
	local scaleform = RequestScaleformMovie(scaleform)
	if scaleform ~= 0 then
		while not HasScaleformMovieLoaded(scaleform) do
			Citizen.Wait(0)
		end
	end
	return scaleform
end


function CreateObj (model, coords, cb, ...)
	local entity = nil
	RequestModel(model)
	while not HasModelLoaded(model) do Citizen.Wait(0) end
	SetModelAsNoLongerNeeded(model)
	entity = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
	if cb ~= nil then cb(entity, ...) end
	return entity
end


local BLIMP = {}

BLIMP.model = 1575467428

BLIMP.scaleform_name = "blimp_text"
BLIMP.scaleform = nil

BLIMP.rendertarget_name = "blimp_text"
BLIMP.rendertarget = nil

function BLIMP.SetScrollSpeed(scrollSpeed)
	PushScaleformMovieFunction(BLIMP.scaleform, "SET_SCROLL_SPEED")
	PushScaleformMovieFunctionParameterFloat(scrollSpeed + 0.0)
	PopScaleformMovieFunctionVoid()
end

function BLIMP.SetColour (colour)
	PushScaleformMovieFunction(BLIMP.scaleform, "SET_COLOUR")
	PushScaleformMovieFunctionParameterInt(colour)
	PopScaleformMovieFunctionVoid()
end; BLIMP.SetColor = BLIMP.SetColour

function BLIMP.SetMessage(message)
	PushScaleformMovieFunction(BLIMP.scaleform, "SET_MESSAGE")
	PushScaleformMovieFunctionParameterString(message)
	PopScaleformMovieFunctionVoid()
end

function BLIMP.RenderMessage ()
	SetTextRenderId(BLIMP.rendertarget)
		Set_2dLayer(4)
		Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
		Citizen.InvokeNative(0x40332D115A898AF5, BLIMP.scaleform, 1)
		DrawScaleformMovie(BLIMP.scaleform, 0.0, -0.08, 1.0, 1.7, 255, 255, 255, 255, 0)
	SetTextRenderId(GetDefaultScriptRendertargetRenderId())
end

Citizen.CreateThread(function ()
	-- Create blimp by player
	local ob = CreateObj(BLIMP.model, GetEntityCoords(GetPlayerPed(-1)))

	BLIMP.scaleform = LoadScaleForm(BLIMP.scaleform_name)
	BLIMP.rendertarget = CreateNamedRenderTargetForModel(BLIMP.rendertarget_name, BLIMP.model)
	BLIMP.SetMessage("Lorem ipsum dolor sit amet, consectetur adipisicing elit. Doloribus modi, incidunt ratione quas officiis tempora aspernatur qui illum fugit, sunt placeat neque perspiciatis commodi iusto natus. Eveniet voluptatem ducimus fuga.")
	BLIMP.SetColor(1)
	BLIMP.SetScrollSpeed(1.0)

	print('BLIMP scaleform handle:' .. BLIMP.scaleform)
	print('BLIMP rendertarget handle:' .. BLIMP.rendertarget)

	while true do
		BLIMP.RenderMessage()
		Citizen.Wait(0)
	end
end)
