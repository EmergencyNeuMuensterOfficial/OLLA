lib.callback.register('drp_hud:getPlayerData', function(source)
    local character = exports.drp_core:GetActiveCharacter(source)
    if not character then return nil end

    return {
        name = ('%s %s'):format(character.first_name, character.last_name),
        cash = exports.ox_inventory:GetItemCount(source, 'money') or 0,
        bank = tonumber(character.bank) or 0,
        job = character.job_name or character.job or 'unemployed',
        jobGrade = tonumber(character.job_grade) or 0,
    }
end)
