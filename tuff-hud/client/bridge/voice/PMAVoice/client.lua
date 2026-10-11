return {
    GetProximityRange = function ()
        local proximity = Player(GetPlayerServerId(PlayerId())).state['proximity']
        local modes = {
            ["Whisper"] = 1,
            ["Normal"] = 2,
            ["Shouting"] = 3
        }
        return modes[proximity?.mode] or 2
    end
}