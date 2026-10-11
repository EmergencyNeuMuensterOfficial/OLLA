return {
    GetProximityRange = function ()
        local proximity = exports["saltychat"]:GetVoiceRange()
        local mode = 2
        if proximity <= 5.0 then
            mode = 1
        elseif proximity >= 10.0 then
            mode = 3
        end
        return mode
    end
}