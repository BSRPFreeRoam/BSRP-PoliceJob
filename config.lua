Config = {}

-- LEO job names (must match bsrp/config_jobs.lua). type = 'leo' also works via FW.GetJobType.
Config.LeoJobs = {
    police = true,
    bcso = true,
    doc = true,
    sapr = true,
    grapeseedpd = true,
    swat = true,
    sasp = true,
    lssd = true,
    pbpd = true,
    dppd = true,
    noose = true,
    fib = true,
    borderpatrol = true,
    mw = true,
}

Config.HandCuffItem = 'handcuffs'
Config.LicenseRank = 2
Config.MaxSpikes = 5
Config.PoliceHelicopter = 'polmav'
Config.CuffDistance = 2.0
Config.SearchDistance = 2.5
Config.EscortDistance = 2.5

-- Soft integrations (resources are never hard dependencies)
Config.UsePsDispatch = true
Config.UsePsMdt = true

Config.Armory = {
    { name = 'WEAPON_PISTOL', amount = 1, grade = 0 },
    { name = 'WEAPON_STUNGUN', amount = 1, grade = 0 },
    { name = 'WEAPON_NIGHTSTICK', amount = 1, grade = 0 },
    { name = 'WEAPON_FLASHLIGHT', amount = 1, grade = 0 },
    { name = 'ammo-9', amount = 48, grade = 0 },
    { name = 'handcuffs', amount = 1, grade = 0 },
    { name = 'empty_evidence_bag', amount = 5, grade = 0 },
    { name = 'radio', amount = 1, grade = 0 },
    { name = 'armour', amount = 1, grade = 1 },
    { name = 'WEAPON_CARBINERIFLE', amount = 1, grade = 3 },
    { name = 'ammo-rifle', amount = 60, grade = 3 },
}

Config.AuthorizedVehicles = {
    [0] = {
        { model = 'police', label = 'Police Cruiser' },
        { model = 'police2', label = 'Police Buffalo' },
        { model = 'police3', label = 'Police Interceptor' },
        { model = 'policeb', label = 'Police Bike' },
    },
    [4] = {
        { model = 'police4', label = 'Unmarked Cruiser' },
        { model = 'sheriff', label = 'Sheriff Cruiser' },
    },
    [10] = {
        { model = 'riot', label = 'Riot Van' },
    },
}

Config.Objects = {
    cone = { model = `prop_roadcone02a`, freeze = false },
    barrier = { model = `prop_barrier_work06a`, freeze = true },
    roadsign = { model = `prop_snow_sign_road_06g`, freeze = true },
    tent = { model = `prop_gazebo_03`, freeze = true },
    light = { model = `prop_worklight_03b`, freeze = true },
}

Config.Locations = {
    duty = {
        vector3(440.085, -974.924, 30.689),
        vector3(-449.811, 6012.909, 31.815),
    },
    vehicle = {
        vector4(448.159, -1017.41, 28.562, 90.654),
        vector4(471.13, -1024.05, 28.17, 274.5),
        vector4(-455.39, 6002.02, 31.34, 87.93),
    },
    stash = {
        vector3(453.075, -980.124, 30.889),
    },
    armory = {
        vector3(462.23, -981.12, 30.69),
    },
    impound = {
        vector3(436.68, -1007.42, 27.32),
        vector3(-436.14, 5982.63, 31.34),
    },
    helicopter = {
        vector4(449.168, -981.325, 43.691, 87.234),
        vector4(-475.43, 5988.353, 31.716, 31.34),
    },
    trash = {
        vector3(439.0907, -976.746, 30.776),
    },
    fingerprint = {
        vector3(460.9667, -989.180, 24.92),
    },
    evidence = {
        vector3(442.1722, -996.067, 30.689),
        vector3(451.7031, -973.232, 30.689),
        vector3(455.1456, -985.462, 30.689),
    },
    stations = {
        { label = 'MRPD', coords = vector4(428.23, -984.28, 29.76, 3.5), sprite = 60, color = 29 },
        { label = 'Prison', coords = vector4(1845.903, 2585.873, 45.672, 272.249), sprite = 188, color = 0 },
        { label = 'Paleto PD', coords = vector4(-451.55, 6014.25, 31.716, 223.81), sprite = 60, color = 29 },
    },
}

Config.Jail = {
    coords = vector4(1691.45, 2565.86, 45.56, 180.0),
    release = vector4(1848.13, 2586.05, 45.67, 270.0),
    maxMinutes = 120,
}

Config.FineSocietyAccount = 'police' -- bank job account label for logs only
