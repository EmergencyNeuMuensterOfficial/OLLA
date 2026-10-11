Config = {}

Config.MaxCharacters = 3
Config.Command = "charaktere"
Config.Debug = false

Config.Spawn = {
    coords = vector4(-1037.7, -2737.8, 20.2, 330.0),
    freezeUntilLoaded = true
}

Config.HospitalSpawn = vector4(285.7595, -569.3894, 43.1446, 16.6185)
Config.DeathRespawnDelay = 5000

Config.Genders = {
    { value = "male", label = "Männlich", model = "mp_m_freemode_01" },
    { value = "female", label = "Weiblich", model = "mp_f_freemode_01" }
}

Config.Jobs = {
    { value = "unemployed", label = "Arbeitslos" },
    { value = "police", label = "Polizei" },
    { value = "ambulance", label = "Rettungsdienst" },
    { value = "mechanic", label = "Mechaniker" },
    { value = "taxi", label = "Taxi" }
}

Config.Text = {
    title = "CHARAKTERVERWALTUNG",
    subtitle = "Wähle deine Identität",
    create = "Charakter erstellen",
    play = "Spielen",
    empty = "Dieser Slot ist noch frei",
    firstName = "Vorname",
    lastName = "Nachname",
    birthDate = "Geburtsdatum",
    gender = "Geschlecht",
    job = "Beruf",
    save = "Charakter speichern",
    cancel = "Abbrechen",
    close = "Schließen",
    required = "Bitte fülle alle Felder korrekt aus.",
    error = "Die Aktion konnte nicht ausgeführt werden."
}
