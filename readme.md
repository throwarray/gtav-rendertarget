__Drawing (general)__
```lua
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

-- TV in Jimmys room
Citizen.CreateThread(function ()
	local model = GetHashKey("des_tvsmash_start"); -- 2054093856
	local pos = { x = -810.59, y = 170.46, z = 77.25 };
	local entity = GetClosestObjectOfType(pos.x, pos.y, pos.z, 0.05, model, 0, 0, 0)
	local handle = CreateNamedRenderTargetForModel("tvscreen", model)
	while true do
		SetTextRenderId(handle) -- set render target
		Set_2dLayer(4)
		SetScriptGfxDrawBehindPausemenu(1)
			DrawRect(0.5, 0.5, 1.0, 0.5, 255, 0, 0, 255); -- WOAH!
		SetTextRenderId(GetDefaultScriptRendertargetRenderId()) -- reset
		SetScriptGfxDrawBehindPausemenu(0)
		Citizen.Wait(0)
	end
end)
```

__Drawing (channels)__
```lua
local Playlists = {
	 "PL_STD_CNT",
	 "PL_STD_WZL",
	 "PL_LO_CNT",
	 "PL_LO_WZL",
	 "PL_SP_WORKOUT",
	 "PL_SP_INV",
	 "PL_SP_INV_EXP",
	 "PL_LO_RS",
	 "PL_LO_RS_CUTSCENE",
	 "PL_SP_PLSH1_INTRO",
	 "PL_LES1_FAME_OR_SHAME",
	 "PL_STD_WZL_FOS_EP2",
	 "PL_MP_WEAZEL",
	 "PL_MP_CCTV",
	 "PL_CINEMA_ACTION",
	 "PL_CINEMA_ARTHOUSE",
	 "PL_CINEMA_MULTIPLAYER",
	 "PL_WEB_HOWITZER",
	 "PL_WEB_RANGERS"
}

-- TV Michaels bedroom
Citizen.CreateThread(function ()
	local model = GetHashKey("prop_tv_flat_michael"), -- 1194029334
	local pos = { x = -810.59, y = 170.46, z = 77.25 };
	local entity = GetClosestObjectOfType(pos.x, pos.y, pos.z, 20.0, model, 0, 0, 0)
	local handle = CreateNamedRenderTargetForModel("tvscreen", model)

	RegisterScriptWithAudio(0)
	SetTvChannel(-1)

	Citizen.InvokeNative(0x9DD5A62390C3B735, 2, "PL_STD_CNT", 0)
	SetTvChannel(2)
	EnableMovieSubtitles(1)

	while true do
		SetTvAudioFrontend(0)
		AttachTvAudioToEntity(entity)
		SetTextRenderId(handle)
		Set_2dLayer(4)
		SetScriptGfxDrawBehindPausemenu(1)
			DrawTvChannel(0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)
		SetTextRenderId(GetDefaultScriptRendertargetRenderId())
		SetScriptGfxDrawBehindPausemenu(0)
		Citizen.Wait(0)
	end
end)
```

#### Notes

__Set playlist__
```lua
local channel_input = 2
local channel_name = "PL_STD_CNT"
local playback_rp = 0
LoadTvChannelSequence(channel_input, channel_name, playback_rp)
SetTvChannel(channel_input)
```

__Is playing clip__
```lua
LoadTvChannel(GetHashKey("end_of_movie_marker"))

```

_See tvplaylists.xml in game files_

```xml
...
<Item>
  <Name>END_OF_MOVIE_MARKER</Name>
  <VideoFileName>2SecondsBlack</VideoFileName>
  <fDuration value="60.000000" />
  <bNotOnDisk value="false" />
</Item>
...
```


__Determine fDuration for custom clips__

_float fDuration = frames * fps to 6 decimal places_

[Source and info](http://gtaforums.com/topic/800319-better-tv-channel-switching-mod/?hl=channel)


__IMAGES__

![alt text][preview]

[preview]: https://github.com/throwarray/gtav-rendertarget/raw/master/img/rt%20(0).png "TV"

![alt text][rt1]

[rt1]: https://github.com/throwarray/gtav-rendertarget/raw/master/img/rt%20(1).png "TV"
