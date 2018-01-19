Citizen.CreateThread(function ()
	local function echo (msg) print(msg) end -- logger

	local e_tv = nil -- tv entity
	local e_remote = nil -- tv entity
	local p_interior = nil -- player interior
	local p_room = nil -- player room
	local p_inside = false
	local i_hash = 197889 -- franklins aunts'
	local i_room = -1073987335; -- living room

	local render_target = -1 -- render target
	local channel = 1 -- current channel
	local channels = { -- channel list
		[1] = "PL_STD_CNT",
		[2] = "PL_STD_WZL",
		[3] = "PL_LO_CNT",
		[4] = "PL_LO_WZL",
		[5] = "PL_SP_WORKOUT",
		[6] = "PL_SP_INV",
		[7] = "PL_SP_INV_EXP",
		[8] = "PL_LO_RS",
		[9] = "PL_LO_RS_CUTSCENE",
		[10] = "PL_SP_PLSH1_INTRO",
		[11] = "PL_LES1_FAME_OR_SHAME",
		[12] = "PL_STD_WZL_FOS_EP2",
		[13] = "PL_MP_WEAZEL",
		[14] = "PL_MP_CCTV",
		[15] = "PL_CINEMA_ACTION",
		[16] = "PL_CINEMA_ARTHOUSE",
		[17] = "PL_CINEMA_MULTIPLAYER",
		[18] = "PL_WEB_HOWITZER",
		[19] = "PL_WEB_RANGERS"
	}

	-- Link | unlink render target
	local function LinkRenderTarget (name, entity, bool)
		local handle = -1
		if not bool then
			if IsNamedRendertargetRegistered(name) then
				ReleaseNamedRendertarget(GetHashKey(name))
				SetTextRenderId(GetDefaultScriptRendertargetRenderId())
			end
		else
			if not IsNamedRendertargetRegistered(name) then
				RegisterNamedRendertarget(name, 0)
			end
			if not IsNamedRendertargetLinked(GetEntityModel(entity)) then
				LinkNamedRendertarget(GetEntityModel(entity))
				Citizen.Wait(0)
			end
			handle = GetNamedRendertargetRenderId(name)
		end

		return handle
	end
	-- set tv channel
	local function ChangeChannel (int_channel)
		if RequestAmbientAudioBank("SAFEHOUSE_MICHAEL_SIT_SOFA", 0, -1) then
			if int_channel <= 0 or GetTvChannel() <= 0 then -- sound: tv on
				PlaySoundFrontend(-1, "MICHAEL_SOFA_TV_ON_MASTER", 0, 1)
			else -- sound: channel switch
				PlaySoundFrontend(-1, "MICHAEL_SOFA_TV_CHANGE_CHANNEL_MASTER", 0, 1)
			end
			-- (-1, "MICHAEL_SOFA_REMOTE_CLICK_VOLUME_MASTER", 0, 1);
		end
		if int_channel > 0 then
			SetTvVolume(0.5) -- set the volume
			SetTvChannel(1) -- turn tv on
			EnableMovieSubtitles(1) -- turn on subtitles
			SetStaticEmitterEnabled("SE_FRANKLIN_AUNT_HOUSE_RADIO_01", 0) -- mute radio
			SetStaticEmitterEnabled("TV_FRANKLINS_HOUSE_SOCEN", 0)
			N_0xf7b38b8305f1fe8b(1, channels[int_channel], 0) -- set station
			channel = int_channel -- retain current station
		else
			SetTvChannel(-1) -- turn tv off
			N_0x03fc694ae06c5a20() -- unk: clean up maybe? (uneeded)
			EnableMovieSubtitles(0) -- turn off subtitles
			SetStaticEmitterEnabled("SE_FRANKLIN_AUNT_HOUSE_RADIO_01", 1) -- enable radio
			SetStaticEmitterEnabled("TV_FRANKLINS_HOUSE_SOCEN", 1)
			ReleaseAmbientAudioBank() -- release audio
		end
	end

	local function cleanup ()
		if not p_inside then return end -- cleanup when outside area
		if IsPlayerPlaying(PlayerId()) then
			ClearPedTasks(PlayerPedId()) -- clear tasks
			if not IsPlayerControlOn(PlayerId()) then
				SetPlayerControl(PlayerId(), 1, 0) -- enable controls
			end
		end

		ChangeChannel(0) -- turn off the tv
		render_target = LinkRenderTarget('tvscreen', 0, false)
		p_inside = false -- mark outside
		DoScreenFadeOut(0) -- screen fade effect
		DoScreenFadeIn(800)
		echo('Exited room')
	end

	local function init ()
		if p_inside then return end -- init when inside area
		e_tv = GetClosestObjectOfType(-9.01, -1441.68, 31.28, 1.0, -897601557, 0, 0, 0) -- tv entity
		e_remote = GetClosestObjectOfType(-11.35, -1440.86, 30.56, 1.0, 542291840, 0, 0, 0) -- tv entity
		p_inside = true -- mark inside
		SetCurrentPedWeapon(GetPlayerPed(), GetHashKey("weapon_unarmed"), 1) -- disarm
		HintAmbientAudioBank("SAFEHOUSE_MICHAEL_SIT_SOFA", 0, -1) -- audio hint
		RegisterScriptWithAudio(0)
		SetTvAudioFrontend(0)
		if DoesEntityExist(e_tv) then -- and not HasObjectBeenBroken(e_tv)
			render_target = LinkRenderTarget('tvscreen', e_tv, true) -- set tv as rendertarget
			AttachTvAudioToEntity(e_tv) -- play audio from entity
			SetEntityVisible(e_tv, 1)
		end
		ChangeChannel(channel) -- turn on the tv
		DoScreenFadeOut(350) -- screen fade effect
		Citizen.Wait(350)
		DoScreenFadeIn(350)
		echo('Entered room')
	end

	while true do
		Citizen.Wait(0)
		p_interior = GetInteriorFromEntity(GetPlayerPed())
		p_room = GetKeyForEntityInRoom(GetPlayerPed()) or 0
		if p_interior == i_hash and p_room == i_room then
			init()
			HideHudAndRadarThisFrame()

			if render_target ~= 1 then
				SetTextRenderId(render_target)
				Set_2dLayer(4)
				Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
			end
			--
			DrawTvChannel(0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
			SetTextRenderId(GetDefaultScriptRendertargetRenderId()) -- reset render context
		else cleanup() end
	end
end)
