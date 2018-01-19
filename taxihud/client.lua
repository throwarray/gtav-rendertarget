local TAXI = {}

TAXI.scaleform = nil

function TAXI.AddDestination (index, blipIndex, blipR, blipG, blipB, destinationStr, addressStr1, addressStr2, isAsian)
	PushScaleformMovieFunction(TAXI.scaleform, "ADD_TAXI_DESTINATION")
		PushScaleformMovieFunctionParameterInt(index)
		PushScaleformMovieFunctionParameterInt(blipIndex)
		PushScaleformMovieFunctionParameterInt(blipR)
		PushScaleformMovieFunctionParameterInt(blipG)
		PushScaleformMovieFunctionParameterInt(blipB)
		PushScaleformMovieFunctionParameterString(destinationStr)
		PushScaleformMovieFunctionParameterString(addressStr1)
		PushScaleformMovieFunctionParameterString(addressStr2)
		PushScaleformMovieFunctionParameterBool(isAsian)
	PopScaleformMovieFunctionVoid()
end

function TAXI.ClearDisplay ()
	PushScaleformMovieFunction(TAXI.scaleform, "CLEAR_TAXI_DISPLAY");
    PopScaleformMovieFunctionVoid();
end

function TAXI.ShowDestination ()
	PushScaleformMovieFunction(TAXI.scaleform, "SHOW_TAXI_DESTINATION")
	PopScaleformMovieFunctionVoid()
end

function TAXI.SetPrice (price, isAsian)
	PushScaleformMovieFunction(TAXI.scaleform, "SET_TAXI_PRICE")
		PushScaleformMovieFunctionParameterString(tostring(price))
		PushScaleformMovieFunctionParameterBool(isAsian)
	PopScaleformMovieFunctionVoid()
end

function TAXI.HighlightDestination (forceDest)
	PushScaleformMovieFunction(TAXI.scaleform, "HIGHLIGHT_DESTINATION")
		PushScaleformMovieFunctionParameterBool(forceDest)
	PopScaleformMovieFunctionVoid()
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

--------------------------------------------------------------------------------

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


TAXI.meter_rt = nil

function TAXI.RenderMeter ()
	SetTextRenderId(TAXI.meter_rt)
		Set_2dLayer(4)
		Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
		DrawScaleformMovie(TAXI.scaleform, 0.201000005, 0.351, 0.4, 0.6, 0, 0, 0, 255, 0)
	SetTextRenderId(GetDefaultScriptRendertargetRenderId())
end

TAXI.meter_model = GetHashKey('prop_taxi_meter_2')
TAXI.meter_entity = nil

function TAXI.CreateTaxiMeter (vehicle)
	local c = GetEntityCoords(vehicle)

	local meter = GetClosestObjectOfType(
		c.x, c.y, c.z, 2.0, TAXI.meter_model, 0, 0, 0
	)

	if not DoesEntityExist(meter) then
		meter = CreateObject(TAXI.meter_model, c.x, c.y, c.z, 1, 1, 0)
		AttachEntityToEntity(
			meter, vehicle,
			GetEntityBoneIndexByName(vehicle, "Chassis"),
			-0.01, 0.6, 0.24,
			-5.0 , 0.0 , 0.0,
			0, 0, 0, 0, 2, 1
		);
	end

	return meter
end
--------------------------------------------------------------------------------

TAXI.model = -956048545
TAXI.entity = nil

function TAXI.IsPedInAnyTaxi (ped) return IsPedInAnyTaxi(ped) end

function TAXI.SetTaxiLights (vehicle, bool)
	return SetTaxiLights(vehicle, bool)
end

Citizen.CreateThread(function ()
	TAXI.scaleform = LoadScaleForm("taxi_display")
	TAXI.meter_rt = CreateNamedRenderTargetForModel("taxi", TAXI.meter_model)

	local coords = { x = -810.59, y = 170.46, z = 77.25 }
	local zoneName = GetNameOfZone(table.unpack(coords))
	local streetName = GetStreetNameAtCoord(table.unpack(coords))
	local mapArea = GetHashOfMapAreaAtCoords(table.unpack(coords))
	local city = mapArea == -289320599
	local countryside = mapArea == 2072609373

	TAXI.AddDestination(0, 2, 0, 0, 255, 'Location', GetStreetNameFromHashKey(streetName), GetLabelText(zoneName), false)
	TAXI.SetPrice('0') -- can also takes an numb
	TAXI.HighlightDestination(0)
	TAXI.ShowDestination()

	while true do
		TAXI.entity = GetVehiclePedIsIn(GetPlayerPed(-1), 0)
		if DoesEntityExist(TAXI.entity) and GetEntityModel(TAXI.entity) == TAXI.model then
			TAXI.meter_entity = TAXI.CreateTaxiMeter(TAXI.entity)
			TAXI.RenderMeter()

			if not IsTaxiLightOn(TAXI.entity) then
				SetTaxiLights(TAXI.entity, 1)
			end
		end
		Citizen.Wait(0)
	end
end)
