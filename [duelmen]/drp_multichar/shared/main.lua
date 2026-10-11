GermanCharacters = GermanCharacters or {}
GermanCharacters.Config = Config

function GermanCharacters.GetGender(value)
    for _, gender in ipairs(Config.Genders) do
        if gender.value == value then return gender end
    end
    return nil
end

function GermanCharacters.GetJob(value)
    for _, job in ipairs(Config.Jobs) do
        if job.value == value then return job end
    end
    return nil
end
