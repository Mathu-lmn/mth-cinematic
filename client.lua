local inCinematic = true
local finalPos = vector3(304.444824, -1204.422729, 38.892593)

local function Subtitle(text, time)
    ClearPrints()
    BeginTextCommandPrint("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandPrint(time and math.ceil(time) or 0, true)
end

RegisterNetEvent("mth-cinematic:start")
AddEventHandler("mth-cinematic:start", function()
    Citizen.CreateThread(function()
        while inCinematic do
            Wait(0)
            DisableAllControlActions(0)
            SetWeatherTypeNow("EXTRASUNNY")
        end
    end)
    DisplayRadar(false)
    DoScreenFadeOut(100)
    Wait(100)
    ClearWeatherTypePersist()
    SetOverrideWeather("EXTRASUNNY")
    PrepareMusicEvent("FM_INTRO_START")
    TriggerMusicEvent("FM_INTRO_START")

    for i = 1, #Config do
        NetworkOverrideClockTime(Config[i].time.h, Config[i].time.m, 0)

        local endCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(endCam, Config[i].endPos)
        PointCamAtCoord(endCam, Config[i].endLookAt)

        local startCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(startCam, Config[i].startPos)
        PointCamAtCoord(startCam, Config[i].startLookAt)

        NewLoadSceneStartSphere(Config[i].endPos, 1000, 0)
        while not IsNewLoadSceneLoaded() do
            Wait(0)
        end
        RenderScriptCams(true, false, 0, true, true)
        DoScreenFadeIn(200)
        Wait(200)
        Subtitle(Config[i].text, Config[i].duration)

        SetCamActiveWithInterp(endCam, startCam, Config[i].duration, 1, 1)
        Wait(Config[i].duration - 500)
        DoScreenFadeOut(1200)
        Wait(1500)
        DestroyCam(startCam, false)
        DestroyCam(endCam, false)
        NewLoadSceneStop()
    end

    SetEntityCoordsNoOffset(PlayerPedId(), finalPos, false, false, false)
    Wait(2000)
    TriggerMusicEvent("FM_INTRO_STOP")
    RenderScriptCams(false, false, 0, true, true)
    DoScreenFadeIn(2000)
    inCinematic = false
    DisplayRadar(true)
end)

RegisterCommand("cinematic", function()
    TriggerEvent("mth-cinematic:start")
end)