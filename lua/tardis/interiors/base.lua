-- Base

local T = {}
T.Base = true
T.BaseMerged = true
T.Name = "Base"
T.ID = "base"
T.Interior = {
    Model = "models/drmatt/tardis/interior.mdl",
    ExitDistance = 600,
    Size = {},
    Portal = {
        pos = Vector(-1,-353.5,136),
        ang = Angle(0,90,0),
        width = 60,
        height = 91
    },
    Fallback = {
        pos = Vector(0,-330,95),
        ang = Angle(0,90,0)
    },
    Sounds = {
        Damage = {
            Crash = "jeredek/tardis/damage_collision.wav",
            BigCrash = "jeredek/tardis/damage_bigcollision.wav",
            Explosion = "jeredek/tardis/damage_explode.wav",
            Death = "jeredek/tardis/damage_death.wav",
            Artron = "p00gie/tardis/force_artron.wav",
        },
        Teleport = {                        -- uses exterior sounds if not specified
            mathop = "hug o/tardis/default+/base sounds/s10/int/mathop/int_matop_full.wav",
            mat_short = "hug o/tardis/default+/base sounds/s10/int/mat_short/mat_short_int_s10+.ogg",  -- for fast vortex remat (not to be confused with fast remat)
        },
        Power = {
            On = "drmatt/tardis/power_on.wav",
            Off = "drmatt/tardis/power_off.wav"
        },
        SequenceOK = "drmatt/tardis/seq_ok.wav",
        SequenceFail = "drmatt/tardis/seq_bad.wav",
        Cloister = "drmatt/tardis/cloisterbell_loop.wav",
        Lock = "drmatt/tardis/lock_int.wav",
        Unlock = "p00gie/tardis/base/door_unlock.wav",
    },
    Tips = {},
    CustomTips = {},
    PartTips = {},
    TipSettings = {
        style = "white_on_grey",
        view_range_min = 70,
        view_range_max = 100,
    },
   WindowTint = {
    Vortex = Color(0,5,10):ToVector(), --color for the window tint during vortex travel
    TintMult = 3, --multiplier for window tint brightness
    DoorSpeedMult = 1,  -- accounts for different door animation speeds
    DoorSpeedMultClosed = 1,  -- lower values = faster
    ExtTint = Color(30, 0, 200):ToVector()*5,  -- exterior window tint color
    Extambient = Color(71, 30, 77),  -- exterior ambient lighting color
    },
    -- PhaseData = {  -- this is commented out because i dont want this affecting all extensions by default; if not adjusted properly it'll mess up the material properties of all of them
    -- DefaultPhongExponent = 30,  -- default phong exponent of the exterior material
    -- DefaultPhongBoost = 1,   -- default phong boost of the exterior material
    -- PhaseMult = 0.1,            -- phase effect intensity multiplier
    -- PhongBoostMult = 5,         -- 'glossiness' multiplier
    -- },
        ProjectedLight = {  -- all the default values, a baseline that should work with any interior, but fine tuning is encouraged
        BrightnessMult = 2, --multiplier for the outside-inside light bleed
        Distance = 800, --Distance you want the lightbleed to reach inside
        Vertfov = 88.1, -- horizontal field of view of the light
        Horizfov = 47, -- vertical fov of the light
        Shortdist = 200, -- distance for the wider and brighter door area light bleed
        Animfactor = 50, -- multiplier for adjusting the speed of light animation
    },
        TintProxies_Int = {           -- these empty proxies are here to make sure the pairs loop doesnt spew a nil error if an extension
        [99] = "",                    --                                                                        doesnt have these defined
        },
        TintProxies_Ext = {
        [99] = "",
        },
        TintProxies_ExtDoor = {
        [99] = "",
        },
        TintProxies_ExtDoorInt = {
        [99] = "",
        },
        LightOverride = {
        basebrightness = 0.3,    --Base interior brightness when power is on.
        nopowerbrightness = 0.05, --Interior brightness with no power. Should always be darker than basebrightness.
        viewmodeladd = 0.0       -- used to boost the viewmodel light override because it's too dark sometimes
    },
    ScreenDistance = 500,
    ScreensEnabled = true
}
T.Exterior = {
    Model = "models/drmatt/tardis/exterior/exterior.mdl",
    ExcludedSkins = {},
    Mass = 5000,
    DoorAnimationTime = 0.5,
    ScannerOffset = Vector(22,0,50),
    PhaseMaterial = "models/drmatt/tardis/exterior/phase_noise.vmt",
    Portal = {
        pos = Vector(26,0,51.65),
        ang = Angle(0,0,0),
        width = 44,
        height = 91
    },
    Fallback = {
        pos = Vector(60,0,5),
        ang = Angle(0,0,0)
    },
    Light = {
        enabled = true,
        pos = Vector(0,0,122),
        color = Color(255,255,255),
        dynamicpos = Vector(0,0,130),
        dynamicbrightness = 2,
        dynamicsize = 300
    },
    ProjectedLight = {
        --color = Color(r,g,b), --Base color. Will use main interior light if not set.
        --warncolor = Color(r,g,b), --Warning color. Will use main interior warn color if not set.
        brightness = 0.1, --Light's brightness
        --vertfov = 90,
        --horizfov = 90, --vertical and horizontal field of view of the light. Will default to portal height and width.
        farz = 750, --FarZ property of the light. Determines how far the light projects.]]
        offset = Vector(-21,0,51.1), --Offset from box origin
        texture = "effects/flashlight/square" --Texture the projected light will use. You can get these from the Lamp tool.
    },
    TimeVortexes = {  -- technically 'vortices' but shutup
        Swirl = {
            model = "models/doctorwho1200/toyota/2014timevortex.mdl",
            color = Color(0,10,40):ToVector(),  -- interior window tint
            tint = Color(0, 126, 178):ToVector(),  -- exterior window tint
            Extambient = Color(53, 72, 80),  -- ambient color for exterior lighting
            },
        Nebula = {
            model = "models/doctorwho1200/toyota/2013timevortex.mdl",
            color = Color(60, 30, 150):ToVector()*3,
            tint = Color(60, 30, 150):ToVector()*3,
            Extambient = Color(150, 120, 200),
            },
        Clouds = {
            model = "models/doctorwho1200/copper/2010timevortex.mdl",
            color = (Color(255, 120, 30):ToVector()*5),
            tint = (Color(255, 120, 30):ToVector()*5),
            Extambient = Color(255, 120, 30),
            },
        Water = {
            model = "models/hugoextension/tuatvortex/tuattimevortex.mdl",
            color = Color(149, 213, 255):ToVector()*3,  -- interior window tint
            tint = Color(109, 160, 187):ToVector(),  -- exterior window tint
            Extambient = Color(160, 220, 255),  -- ambient color for exterior lighting
            },
        Fiery = {
            model = "models/hugoextension/2023/2023vortex.mdl",
            color = Color(121,37,4):ToVector()*3,  -- interior window tint
            tint = Color(136,27,0):ToVector()*2,  -- exterior window tint
            Extambient = Color(116,59,37),  -- ambient color for exterior lighting
            },
    },
    Sounds = {
        Teleport = {
            demat = "p00gie/tardis/base/demat.wav",
            demat_damaged = "drmatt/tardis/demat_damaged.wav",
            demat_fast = "p00gie/tardis/base/demat.wav",
            demat_hads = "p00gie/tardis/base/demat_hads.wav",
            demat_fail = "drmatt/tardis/demat_fail.wav",
            mat = "p00gie/tardis/base/mat.wav",
            mat_short = "hug o/tardis/default+/base sounds/s10/ext/mat_short/mat_short_ext_s10+.ogg",  -- for fast vortex remat (not to be confused with fast remat)
            mat_damaged = "jeredek/tardis/mat_damaged.wav",
            mat_fail = "p00gie/tardis/mat_fail.wav",
            mat_fast = "p00gie/tardis/base/mat_fast.wav",
            mat_damaged_fast = "p00gie/tardis/base/mat_damaged_fast.wav",
            fullflight = "p00gie/tardis/base/full.wav",
            fullflight_damaged = "drmatt/tardis/full_damaged.wav",
            interrupt = "p00gie/tardis/base/repairfinish.wav",
            mathop_demat = "hug o/tardis/default+/base sounds/s10/ext/mathop_demat/demat_ext_mathop.wav",
            mathop_mat = "hug o/tardis/default+/base sounds/s10/ext/mathop_mat/mat_ext_mathop.wav",
        },
        RepairFinish = "p00gie/tardis/base/repairfinish.wav",
        Lock = "drmatt/tardis/lock.wav",
        Unlock = "p00gie/tardis/base/door_unlock_ext.wav",
        Spawn = "p00gie/tardis/base/repairfinish.wav",
        Delete = "p00gie/tardis/base/tardis_delete.wav",
        Door = {
            enabled = true,
            open = "drmatt/tardis/door_open.wav",
            close = "drmatt/tardis/door_close.wav",
            locked = "drmatt/tardis/door_locked.wav"
        },
        FlightLoop = "drmatt/tardis/flight_loop.wav",
        FlightLoopDamaged = "drmatt/tardis/flight_loop_damaged.wav",
        FlightLoopBroken = "p00gie/tardis/flight_loop_broken.wav",
        FlightLand = "p00gie/tardis/base/tardis_landing.wav",
        FlightFall = "p00gie/tardis/fall.wav",
        BrokenFlightTurn = {
            "p00gie/tardis/flight_turn_1.wav",
            "p00gie/tardis/flight_turn_2.wav",
            "p00gie/tardis/flight_turn_3.wav",
        },
        BrokenFlightExplosion = "p00gie/tardis/flight_turn_explosion.wav",
        BrokenFlightEnable = "p00gie/tardis/flight_broken_start.wav",
        BrokenFlightDisable = "p00gie/tardis/flight_broken_stop.wav",
        Cloak = "drmatt/tardis/phase_enable.wav",
        CloakOff = "drmatt/tardis/phase_disable.wav",
        Hum = nil,
        Chameleon = "drmatt/tardis/chameleon_circuit.wav",
    },
    Chameleon = {
        AnimTime = 4,
    },
    Parts = {
        vortex = {
            model = "models/doctorwho1200/toyota/2013timevortex.mdl",
            pos = Vector(0,0,50),
            ang = Angle(0,0,0),
            scale = 5
        }
    },
    Teleport = {
        SequenceSpeed = 0.77,
        SequenceSpeedWarning = 0.6,
        SequenceSpeedFast = 0.935,
        SequenceSpeedVeryFast = 2.8,
        SequenceSpeedHads = 1.8,
        SequenceSpeedWarnFast = 0.97,
        PrematSequenceDelay = 8.5, -- this isnt used in the code but if this isnt here then the fast premat sequence delay breaks??? so i guess this has to be here
        PrematDelay = 8.5,
        PrematSequenceDelayFast = 1.9,
        PrematSequenceDelayVeryFast = 0.1,  -- for mathop
        PrematDelayShort = 1,  -- for fast vortex remat (not to be confused with fast remat)

        DematVeryFastSequenceDelays={  -- for mathop
            [1] = 0
        },

        DematSequence = {
            200,
            100,
            150,
            50,
            100,
            0
        },
        DematSequenceFast = {
            200,
            100,
            150,
            50,
            100,
            0
        },
        MatSequence = {
            50,
            150,
            100,
            200,
            150,
            255
        },
        MatSequenceFast = {
            50,
            150,
            100,
            200,
            150,
            255
        },
        HadsDematSequence = {
            100,
            200,
            0
        },
        DematSequenceVeryFast = {
            255,
            50
        },
        MatSequenceVeryFast = {
            50,
            255
        },
    }
}
T.Timings = {
    DematInterrupt = 1,
    DematFail = 4,
    MatFail = 8,
}

TARDIS:AddInterior(T)

local E = TARDIS:CopyTable(T.Exterior)
E.ID = "base"
E.Base = true
E.Name = "Base"
E.Category = "Exteriors.Categories.PoliceBoxes"
-- to prevent it generating other empty categories

E.Light.enabled = false

TARDIS:AddExterior(E)