-- Original: Motenten / Modified: Arislan
-- Haste/DW Detection Requires Gearinfo Addon
-------------------------------------------------------------------------------------------------------------------
--  Keybinds
-------------------------------------------------------------------------------------------------------------------

--  Modes:      [ F9 ]              Cycle Offense Modes
--              [ CTRL+F9 ]         Cycle Hybrid Modes
--              [ WIN+F9 ]          Cycle Weapon Skill Modes
--              [ F10 ]             Emergency -PDT Mode
--              [ ALT+F10 ]         Toggle Kiting Mode
--              [ F11 ]             Emergency -MDT Mode
--              [ F12 ]             Update Current Gear / Report Current Status
--              [ CTRL+F12 ]        Cycle Idle Modes
--              [ ALT+F12 ]         Cancel Emergency -PDT/-MDT Mode
--              [ WIN+F ]           Toggle Closed Position (Facing) Mode
--              [ WIN+C ]           Toggle Capacity Points Mode
--
--
--              [ CTRL+` ]          Chocobo Jig II

-------------------------------------------------------------------------------------------------------------------
--  Custom Commands (preface with /console to use these in macros)
-------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------------------------------------
-- Setup functions for this job.  Generally should not be modified.
-------------------------------------------------------------------------------------------------------------------

-- Initialization function for this job file.
function get_sets()
    mote_include_version = 2

    -- Load and initialize the include file.
    include('Mote-Include.lua')
end


-- Setup vars that are user-independent.  state.Buff vars initialized here will automatically be tracked.
function job_setup()
    state.Buff['Climactic Flourish'] = buffactive['climactic flourish'] or false
    state.Buff['Sneak Attack'] = buffactive['sneak attack'] or false

    state.ClosedPosition = M(false, 'Closed Position')

    state.CP = M(false, "Capacity Points Mode")
	
    no_swap_gear = S{"Warp Ring", "Dim. Ring (Dem)", "Dim. Ring (Holla)", "Dim. Ring (Mea)",
              "Trizek Ring", "Echad Ring", "Endorsement Ring", "Facility Ring", "Capacity Ring", "Reraise Ring", "Reraise Earring"}

    lockstyleset = 1
end

-------------------------------------------------------------------------------------------------------------------
-- User setup functions for this job.  Recommend that these be overridden in a sidecar file.
-------------------------------------------------------------------------------------------------------------------

-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    state.OffenseMode:options('Normal', 'LowAcc', 'MidAcc', 'HighAcc', 'STP')
    state.HybridMode:options('Normal', 'DT')
	state.CastingMode:options('Normal', 'SpellInterrupt')
    state.WeaponskillMode:options('Normal', 'Acc')
    state.IdleMode:options('Normal', 'DT')

    -- Additional local binds
    --^ means cntrl
	--! means alt
    send_command('bind ^` input /ja "Chocobo Jig II" <me>')
    send_command('bind @c gs c toggle CP')
	send_command('bind ^= gs c cycle CastingMode')    

    set_lockstyle()

    state.Auto_Kite = M(false, 'Auto_Kite')
    Haste = 0
    DW_needed = 0
    DW = false
    moving = false
    update_combat_form()
    determine_haste_group()
end


-- Called when this job file is unloaded (eg: job change)
function user_unload()
    send_command('unbind ^`')
    send_command('unbind @c')
	send_command('unbind ^=')
end


-- Define sets and vars used by this job file.
function init_gear_sets()

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Precast Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    -- Enmity set
    sets.Enmity = {
		ammo="Charitoni Sling", --1
        head="Halitus Helm", --8
		neck="Unmoving Collar +1", --10
		ear1="Cryptic Earring", --4
		ear2="Tuisto Earring", --0
		body="Emet Harness +1", --10
        hands="Horos Bangles +3", --9
		ring1="Eihwaz Ring", --5
		ring2="Provocare Ring", --5
		back={ name="Senuna's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Evasion+10','Enmity+10','Damage taken-5%',}},
		waist="Plat. Mog. Belt", --0
		legs="Obatala Subligar", --5
        feet="Maculele Toe Shoes +2", --0
		} --Enmity 78(93 Fan Dance), HP 3224, DT P23 M25 B17

    sets.precast.JA['Provoke'] = sets.Enmity
	sets.precast.JA['Warcry'] = sets.Enmity
	
    sets.precast.JA['No Foot Rise'] = {body="Horos Casaque +3"}
    sets.precast.JA['Trance'] = {head="Horos Tiara +3"}
	
	sets.precast.JA['Swordplay'] = sets.Enmity
	sets.precast.JA['Vallation'] = sets.Enmity
	sets.precast.JA['Valiance'] = sets.Enmity
	sets.precast.JA['Pflug'] = sets.Enmity
	sets.precast.JA['Swipe'] = sets.Enmity
	sets.precast.JA['Lunge'] = sets.Enmity
	sets.precast.JA['Ignis'] = sets.Enmity
	sets.precast.JA['Gelus'] = sets.Enmity
	sets.precast.JA['Flabra'] = sets.Enmity
	sets.precast.JA['Tellus'] = sets.Enmity
	sets.precast.JA['Sulpor'] = sets.Enmity
	sets.precast.JA['Unda'] = sets.Enmity
	sets.precast.JA['Lux'] = sets.Enmity
	sets.precast.JA['Tenebrae'] = sets.Enmity
	
    sets.precast.Waltz = set_combine(sets.Enmity, {
		ammo="Yamarang",
        head="Horos Tiara +3", 
		neck="Unmoving Collar +1",
        ear1="Roundel Earring", 
        ear2="Tuisto Earring", 
        body="Maxixi Casaque +3",
        hands="Nyame Gauntlets",
        ring2="Defending Ring", 
		back={ name="Senuna's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Evasion+10','Enmity+10','Damage taken-5%',}},
		waist="Plat. Mog. Belt",
        legs="Dashing Subligar", 
        feet="Maxixi Toe Shoes +2", 
        }) --Waltz 39, Enmity 31, HP 3359, DT P35 M35 B35

    sets.precast.WaltzSelf = set_combine(sets.precast.Waltz, {}) -- Waltz effects received

    sets.precast.Waltz['Healing Waltz'] = {}
    sets.precast.Samba = {head="Maxixi Tiara +3", back=gear.DncCapetp}
    sets.precast.Jig = set_combine(sets.Enmity, {feet="Maxixi Toe Shoes +2"})

    sets.precast.Step = {
        ammo="Yamarang", --15
        head="Maxixi Tiara +3", 
        body="Nyame Mail", 
        hands="Ashera Harness",
        legs="Nyame Flanchard",
        feet="Horos T. Shoes +3", 
        neck="Unmoving Collar +1",
        ear1="Odr Earring",
        ear2="Mache Earring +1",
        ring1="Defending Ring",
        ring2="Regal Ring",
        waist="Plat. Mog. Belt",
        back=gear.DncCapetp
        }

    sets.precast.Step['Feather Step'] = set_combine(sets.precast.Step, {feet="Maculele Toe Shoes +2"})
    sets.precast.Flourish1 = {}
    sets.precast.Flourish1['Animated Flourish'] = sets.Enmity

    sets.precast.Flourish1['Violent Flourish'] = {
        ammo="Yamarang",
        head="Nyame Helm",
        body="Horos Casaque +3",
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
        feet="Maculele Toe Shoes +2",
        neck="Etoile Gorget +2",
        ear1="Odnowa Earring +1",
        ear2="Tuisto Earring",
        ring1="Eihwaz Ring",
        ring2="Vertigo Ring",
        waist="Plat. Mog. Belt",
        back="Reiki Cloak",
        } -- Magic Accuracy

    sets.precast.Flourish1['Desperate Flourish'] = set_combine(sets.precast.Step, {}) -- Accuracy

    sets.precast.Flourish2 = {}
    sets.precast.Flourish2['Reverse Flourish'] = {hands="Macu. Bangles +2",back="Toetapper Mantle"}
    sets.precast.Flourish3 = {}
    sets.precast.Flourish3['Striking Flourish'] = {body="Macu. Casaque +2"}
    sets.precast.Flourish3['Climactic Flourish'] = {head="Maculele Tiara +3",}

    sets.precast.FC = {
        ammo="Sapience Orb", --2
        head="Herculean Helm", --7
		neck="Baetyl Pendant", --4
		ear1="Loquacious Earring", --2
        ear2="Tuisto Earring", 
        body="Taeon Tabard", --9
        hands="Leyline Gloves", --7
		ring1="Eihwaz Ring", 
        ring2="Weatherspoon Ring", --5 
		back="Reiki Cloak",
		waist="Plat. Mog. Belt",
		legs="Taeon Tights", --5
		feet="Taeon Boots", --5
        } --  FC=46 HP=3001



    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {
        neck="Magoraga Beads"
		})


    ------------------------------------------------------------------------------------------------
    ------------------------------------- Weapon Skill Sets ----------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.precast.WS = {
        ammo="Charitoni Sling",
        head="Nyame Helm",
        body="Macu. Casaque +3",
        hands="Maxixi Bangles +3",
        legs="Horos Tights +3",
        feet="Maculele Toe Shoes +2",
        neck="Unmoving Collar +1",
        ear1="Odnowa Earring +1",
        ear2="Moonshade Earring",
        ring1="Eihwaz Ring",
        ring2="Ilabrat Ring",
        back=gear.DncCapews,
        waist="Kentarch Belt +1",
        } -- default set
		--Enmity 26, HP 2690, DT P47 M49 B47

    sets.precast.WS.Acc = set_combine(sets.precast.WS, {
        ammo="Mantoptera Eye",
        legs="Nyame Flanchard",
        })

    sets.precast.WS.Critical = {body="Meg. Cuirie +2"}

    sets.precast.WS['Exenterator'] = set_combine(sets.precast.WS, {
        waist="Soil Belt",
        })

    sets.precast.WS['Exenterator'].Acc = set_combine(sets.precast.WS['Exenterator'], {})

    sets.precast.WS['Pyrrhic Kleos'] = set_combine(sets.precast.WS, {
	    ear2="Sherida Earring",
        hands="Nyame Gauntlets",
        legs="Nyame Flanchard",
		waist="Snow Belt"
		})

    sets.precast.WS['Pyrrhic Kleos'].Acc = set_combine(sets.precast.WS['Pyrrhic Kleos'], {
        ammo="Mantoptera Eye",
        })

    sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {
	    waist="Soil Belt",
	})

    sets.precast.WS['Evisceration'].Acc = set_combine(sets.precast.WS['Evisceration'], {})

	sets.precast.WS['Shark Bite'] = {}

    sets.precast.WS['Rudra\'s Storm'] = set_combine(sets.precast.WS, {})

    sets.precast.WS['Rudra\'s Storm'].Acc = set_combine(sets.precast.WS['Rudra\'s Storm'], {})

    sets.precast.WS['Aeolian Edge'] = set_combine(sets.Enmity, {})

    sets.precast.Skillchain = {
        hands="Macu. Bangles +2",
        }

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Midcast Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.midcast.Flash = set_combine(sets.Enmity, {})
	
	sets.midcast['Blue Magic'] = set_combine(sets.Enmity, {
		ear2="Friomisi Earring",
	})
	
	sets.midcast.FastRecast = sets.precast.FC

    sets.midcast['Blue Magic'].SpellInterrupt = {
		ammo="Staunch Tathlum +1", --11
		head="Taeon Chapeau", --10
		neck="Willpower Torque", --5
		ear1="Magnetic Earring", --8
		ear2="Halasz Earring", --5
		body="Macu. Casaque +3",
		hands="Rawhide Gloves", --15
		ring1="Evanescence Ring", --5
		ring2="Defending Ring",
		back={ name="Senuna's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Spell interruption rate down-10%',}}, --10
		waist="Resolute Belt", --8
		legs="Nyame Flanchard",
		feet="Karasutengu", --15
	} --sird 92(102 merits) -dt 35(43 acrontica) hp 2496

    sets.midcast.Utsusemi = sets.midcast.SpellInterrupt

    ------------------------------------------------------------------------------------------------
    ----------------------------------------- Idle Sets --------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.resting = {}

    sets.idle = {
		ammo="Yamarang",
		head="Nyame Helm",
		neck="Unmoving Collar +1",
		ear1="Eabani Earring",
		ear2="Tuisto Earring",
        body="Ashera Harness",
		hands="Nyame Gauntlets",
		ring1="Eihwaz Ring",
		ring2="Defending Ring",
        back={ name="Senuna's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Evasion+10','Enmity+10','Damage taken-5%',}},
		waist="Plat. Mog. Belt",
		legs="Nyame Flanchard",
		feet="Skd. Jambeaux +1"}
		--HP 3470, DT 52, MDT 11, DEF 1376, Eva 387, MEVA 562, MDB 24

    sets.idle.DT = set_combine(sets.idle, {
	    feet="Maculele Toe Shoes +2"})

    sets.idle.Town = sets.idle

    sets.idle.Weak = sets.idle.DT

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Defense Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.defense.PDT = sets.idle.DT
    sets.defense.MDT = sets.idle.DT

    sets.Kiting = {feet="Skd. Jambeaux +1"}

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Engaged Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion

    sets.engaged = {
		ammo="Coiste Bodhar",
        head="Maxixi Tiara +3",
		neck="Charis Necklace",
		ear1="Suppanomimi",
		ear2="Tuisto Earring",
        body="Horos Casaque +3",
		hands="Adhemar Wristbands +1",
		ring1="Gere Ring",
		ring2="Epona's Ring",
        back=gear.DncCapetp,
		waist="Plat. Mog. Belt",
		legs="Meg. Chausses +2",
		feet="Horos T. Shoes +3"}

    sets.engaged.LowAcc = set_combine(sets.engaged, {})

    sets.engaged.MidAcc = set_combine(sets.engaged.LowAcc, {})

    sets.engaged.HighAcc = set_combine(sets.engaged.MidAcc, {})

    sets.engaged.STP = set_combine(sets.engaged, {
		ammo="Yamarang",
		head="Maculele Tiara +1",
		neck="Etoile Gorget +2",
		ear1="Crepuscular Earring",
		ear2="Dedition Earring",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		ring1={name="Chirich Ring +1", bag="wardrobe2"},
		ring2={name="Chirich Ring +1", bag="wardrobe4"},
		back=gear.DncCapeTp,
		waist="Plat. Mog. Belt",
		legs="Meghanada Chausses +2",
		feet="Horos Toe Shoes +3"})

    -- * DNC Native DW Trait: 30% DW
    -- * DNC Job Points DW Gift: 5% DW

    -- No Magic Haste (39% DW to cap)
    sets.engaged.DW = {
        ammo="Coiste Bodhar",
        head="Maxixi Tiara +3",neck="Charis Necklace",ear1="Suppanomimi",ear2="Tuisto Earring",
        body="Horos Casaque +3",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.DncCapetp,waist="Plat. Mog. Belt",legs="Meg. Chausses +2",feet="Horos T. Shoes +3"}
		
    sets.engaged.DW.LowAcc = set_combine(sets.engaged.DW, {})

    sets.engaged.DW.MidAcc = set_combine(sets.engaged.DW.LowAcc, {})

    sets.engaged.DW.HighAcc = set_combine(sets.engaged.DW.MidAcc, {})

    sets.engaged.DW.STP = set_combine(sets.engaged.DW, {
        })

    -- 15% Magic Haste (32% DW to cap)
    sets.engaged.DW.LowHaste = {
        ammo="Coiste Bodhar",
        head="Maxixi Tiara +3",neck="Charis Necklace",ear1="Suppanomimi",ear2="Tuisto Earring",
        body="Horos Casaque +3",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.DncCapetp,waist="Reiki Yotai",legs="Meg. Chausses +2",feet="Horos T. Shoes +3"}

    sets.engaged.DW.LowAcc.LowHaste = set_combine(sets.engaged.DW.LowHaste, {})

    sets.engaged.DW.MidAcc.LowHaste = set_combine(sets.engaged.DW.LowAcc.LowHaste, {})

    sets.engaged.DW.HighAcc.LowHaste = set_combine(sets.engaged.DW.MidAcc.LowHaste, {})

    sets.engaged.DW.STP.LowHaste = set_combine(sets.engaged.DW.LowHaste, {
        ammo="Yamarang",
		head="Maculele Tiara +1",
		neck="Etoile Gorget +2",
		ear1="Crepuscular Earring",
		ear2="Dedition Earring",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		ring1={name="Chirich Ring +1", bag="wardrobe2"},
		ring2={name="Chirich Ring +1", bag="wardrobe4"},
		back=gear.DncCapeTp,
		waist="Plat. Mog. Belt",
		legs="Meghanada Chausses +2",
		feet="Horos Toe Shoes +3"})

    -- 30% Magic Haste (21% DW to cap)
    sets.engaged.DW.MidHaste = {ammo="Coiste Bodhar",
        head="Maxixi Tiara +3",neck="Etoile Gorget +2",ear1="Suppanomimi",ear2="Tuisto Earring",
        body="Horos Casaque +3",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.DncCapetp,waist="Plat. Mog. Belt",legs="Meg. Chausses +2",feet="Horos T. Shoes +3"}

    sets.engaged.DW.LowAcc.MidHaste = set_combine(sets.engaged.DW.MidHaste, {})

    sets.engaged.DW.MidAcc.MidHaste = set_combine(sets.engaged.DW.LowAcc.MidHaste, {})

    sets.engaged.DW.HighAcc.MidHaste = set_combine(sets.engaged.DW.MidAcc.MidHaste, {})

    sets.engaged.DW.STP.MidHaste = set_combine(sets.engaged.DW.MidHaste, {
        ammo="Yamarang",
		head="Maculele Tiara +1",
		neck="Etoile Gorget +2",
		ear1="Crepuscular Earring",
		ear2="Dedition Earring",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		ring1={name="Chirich Ring +1", bag="wardrobe2"},
		ring2={name="Chirich Ring +1", bag="wardrobe4"},
		back=gear.DncCapeTp,
		waist="Plat. Mog. Belt",
		legs="Meghanada Chausses +2",
		feet="Horos Toe Shoes +3"})

    -- 35% Magic Haste (16% DW to cap)
    sets.engaged.DW.HighHaste = {ammo="Coiste Bodhar",
        head="Adhemar Bonnet +1",neck="Etoile Gorget +2",ear1="Suppanomimi",ear2="Tuisto Earring",
        body="Horos Casaque +3",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.DncCapetp,waist="Plat. Mog. Belt",legs="Meg. Chausses +2",feet="Horos T. Shoes +3"} 

    sets.engaged.DW.LowAcc.HighHaste = set_combine(sets.engaged.DW.HighHaste, {})

    sets.engaged.DW.MidAcc.HighHaste = set_combine(sets.engaged.DW.LowAcc.HighHaste, {})

    sets.engaged.DW.HighAcc.HighHaste = set_combine(sets.engaged.DW.MidAcc.HighHaste, {})

    sets.engaged.DW.STP.HighHaste = set_combine(sets.engaged.DW.HighHaste, {
        ammo="Yamarang",
		head="Maculele Tiara +1",
		neck="Etoile Gorget +2",
		ear1="Crepuscular Earring",
		ear2="Dedition Earring",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		ring1={name="Chirich Ring +1", bag="wardrobe2"},
		ring2={name="Chirich Ring +1", bag="wardrobe4"},
		back=gear.DncCapeTp,
		waist="Plat. Mog. Belt",
		legs="Meghanada Chausses +2",
		feet="Horos Toe Shoes +3"})

    -- 45% Magic Haste (1% DW to cap)
    sets.engaged.DW.MaxHaste = {ammo="Coiste Bodhar",
        head="Adhemar Bonnet +1",neck="Etoile Gorget +2",ear1="Crepuscular Earring",ear2="Sherida Earring",
        body="Horos Casaque +3",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.DncCapetp,waist="Plat. Mog. Belt",legs="Meg. Chausses +2",feet="Horos T. Shoes +3"} 

    sets.engaged.DW.LowAcc.MaxHaste = set_combine(sets.engaged.DW.MaxHaste, {})

    sets.engaged.DW.MidAcc.MaxHaste = set_combine(sets.engaged.DW.LowAcc.MaxHaste, {})

    sets.engaged.DW.HighAcc.MaxHaste = set_combine(sets.engaged.DW.MidAcc.MaxHaste, {})

    sets.engaged.DW.STP.MaxHaste = set_combine(sets.engaged.DW.MaxHaste, {
        ammo="Yamarang",
		head="Maculele Tiara +1",
		neck="Etoile Gorget +2",
		ear1="Crepuscular Earring",
		ear2="Dedition Earring",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		ring1={name="Chirich Ring +1", bag="wardrobe2"},
		ring2={name="Chirich Ring +1", bag="wardrobe4"},
		back=gear.DncCapeTp,
		waist="Plat. Mog. Belt",
		legs="Meghanada Chausses +2",
		feet="Horos Toe Shoes +3"})

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Hybrid Sets -------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.engaged.Hybrid = {
        ammo="Yamarang",
		head="Maculele Tiara +3",
		neck="Etoile Gorget +2",
		ear1="Odnowa Earring +1",
		ear2="Tuisto Earring",
        body="Ashera Harness",
		hands="Maculele Bangles +2",
		ring1="Chirich Ring +1",
		ring2="Regal Ring",
        back={ name="Senuna's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Evasion+10','Enmity+10','Damage taken-5%',}},
		waist="Plat. Mog. Belt",
		legs="Nyame Flanchard",
		feet="Maculele Toe Shoes +2",
		} -- HP=3117 DT=50

    sets.engaged.DT = set_combine(sets.engaged, sets.engaged.Hybrid)
    sets.engaged.LowAcc.DT = set_combine(sets.engaged.LowAcc, sets.engaged.Hybrid)
    sets.engaged.MidAcc.DT = set_combine(sets.engaged.MidAcc, sets.engaged.Hybrid)
    sets.engaged.HighAcc.DT = set_combine(sets.engaged.HighAcc, sets.engaged.Hybrid)
    sets.engaged.STP.DT = set_combine(sets.engaged.STP, sets.engaged.Hybrid)

    sets.engaged.DW.DT = set_combine(sets.engaged.DW, sets.engaged.Hybrid)
    sets.engaged.DW.LowAcc.DT = set_combine(sets.engaged.DW.LowAcc, sets.engaged.Hybrid)
    sets.engaged.DW.MidAcc.DT = set_combine(sets.engaged.DW.MidAcc, sets.engaged.Hybrid)
    sets.engaged.DW.HighAcc.DT = set_combine(sets.engaged.DW.HighAcc, sets.engaged.Hybrid)
    sets.engaged.DW.STP.DT = set_combine(sets.engaged.DW.STP, sets.engaged.Hybrid)

    sets.engaged.DW.DT.LowHaste = set_combine(sets.engaged.DW.LowHaste, sets.engaged.Hybrid)
    sets.engaged.DW.LowAcc.DT.LowHaste = set_combine(sets.engaged.DW.LowAcc.LowHaste, sets.engaged.Hybrid)
    sets.engaged.DW.MidAcc.DT.LowHaste = set_combine(sets.engaged.DW.MidAcc.LowHaste, sets.engaged.Hybrid)
    sets.engaged.DW.HighAcc.DT.LowHaste = set_combine(sets.engaged.DW.HighAcc.LowHaste, sets.engaged.Hybrid)
    sets.engaged.DW.STP.DT.LowHaste = set_combine(sets.engaged.DW.STP.LowHaste, sets.engaged.Hybrid)

    sets.engaged.DW.DT.MidHaste = set_combine(sets.engaged.DW.MidHaste, sets.engaged.Hybrid)
    sets.engaged.DW.LowAcc.DT.MidHaste = set_combine(sets.engaged.DW.LowAcc.MidHaste, sets.engaged.Hybrid)
    sets.engaged.DW.MidAcc.DT.MidHaste = set_combine(sets.engaged.DW.MidAcc.MidHaste, sets.engaged.Hybrid)
    sets.engaged.DW.HighAcc.DT.MidHaste = set_combine(sets.engaged.DW.HighAcc.MidHaste, sets.engaged.Hybrid)
    sets.engaged.DW.STP.DT.MidHaste = set_combine(sets.engaged.DW.STP.MidHaste, sets.engaged.Hybrid)

    sets.engaged.DW.DT.HighHaste = set_combine(sets.engaged.DW.HighHaste, sets.engaged.Hybrid)
    sets.engaged.DW.LowAcc.DT.HighHaste = set_combine(sets.engaged.DW.LowAcc.HighHaste, sets.engaged.Hybrid)
    sets.engaged.DW.MidAcc.DT.HighHaste = set_combine(sets.engaged.DW.MidAcc.HighHaste, sets.engaged.Hybrid)
    sets.engaged.DW.HighAcc.DT.HighHaste = set_combine(sets.engaged.DW.HighAcc.HighHaste, sets.engaged.Hybrid)
    sets.engaged.DW.STP.DT.HighHaste = set_combine(sets.engaged.DW.HighHaste.STP, sets.engaged.Hybrid)

    sets.engaged.DW.DT.MaxHaste = set_combine(sets.engaged.DW.MaxHaste, sets.engaged.Hybrid)
    sets.engaged.DW.LowAcc.DT.MaxHaste = set_combine(sets.engaged.DW.LowAcc.MaxHaste, sets.engaged.Hybrid)
    sets.engaged.DW.MidAcc.DT.MaxHaste = set_combine(sets.engaged.DW.MidAcc.MaxHaste, sets.engaged.Hybrid)
    sets.engaged.DW.HighAcc.DT.MaxHaste = set_combine(sets.engaged.DW.HighAcc.MaxHaste, sets.engaged.Hybrid)
    sets.engaged.DW.STP.DT.MaxHaste = set_combine(sets.engaged.DW.STP.MaxHaste, sets.engaged.Hybrid)


    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Special Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.buff['Saber Dance'] = {}
    sets.buff['Fan Dance'] = {}
    sets.buff['Climactic Flourish'] = {ammo="Charis Feather",head="Maculele Tiara +1",body="Meg. Cuirie +2"}
    sets.buff['Closed Position'] = {}

    sets.buff.Doom = {}

    -- sets.CP = {back="Mecisto. Mantle"}
    -- sets.Reive = {neck="Adoulin's Refuge +1"}

end


-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for standard casting events.
-------------------------------------------------------------------------------------------------------------------

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    --auto_presto(spell)
    if spellMap == 'Utsusemi' then
        if buffactive['Copy Image (3)'] or buffactive['Copy Image (4+)'] then
            cancel_spell()
            add_to_chat(123, '**!! '..spell.english..' Canceled: [3+ IMAGES] !!**')
            eventArgs.handled = true
            return
        elseif buffactive['Copy Image'] or buffactive['Copy Image (2)'] then
            send_command('cancel 66; cancel 444; cancel Copy Image; cancel Copy Image (2)')
        end
    end
end

function job_post_precast(spell, action, spellMap, eventArgs)
    if spell.type == "WeaponSkill" then
        if state.Buff['Sneak Attack'] == true then
            equip(sets.precast.WS.Critical)
        end
        if state.Buff['Climactic Flourish'] then
            equip(sets.buff['Climactic Flourish'])
        end
    end
    if spell.type=='Waltz' and spell.english:startswith('Curing') and spell.target.type == 'SELF' then
        equip(sets.precast.WaltzSelf)
    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Weaponskills wipe SATA.  Turn those state vars off before default gearing is attempted.
    if spell.type == 'WeaponSkill' and not spell.interrupted then
        state.Buff['Sneak Attack'] = false
    end
end

-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks for non-casting events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff,gain)
    if buff == 'Saber Dance' or buff == 'Climactic Flourish' or buff == 'Fan Dance' or buff == 'Striking Flourish' then
        handle_equipping_gear(player.status)
    end

    --if buffactive['Reive Mark'] then
    --    if gain then
    --        equip(sets.Reive)
    --        disable('neck')
    --   else
    --        enable('neck')
    --    end
    --end

    if buff == "doom" then
        if gain then
            equip(sets.buff.Doom)
            send_command('@input /echo Doomed. ~DOOOOOMED!')
             disable('ring1','ring2','waist')
        else
            enable('ring1','ring2','waist')
            handle_equipping_gear(player.status)
        end
    end

end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements standard library decisions.
-------------------------------------------------------------------------------------------------------------------

-- Called by the 'update' self-command, for common needs.
-- Set eventArgs.handled to true if we don't want automatic equipping of gear.
function job_handle_equipping_gear(playerStatus, eventArgs)
    check_gear()
    update_combat_form()
    determine_haste_group()
    check_moving()
end

function job_update(cmdParams, eventArgs)
    handle_equipping_gear(player.status)
end

function update_combat_form()
	-- Check for H2H or single-wielding
	if player.equipment.sub == "Airy Buckler" or player.equipment.sub == 'empty' then -- Your going to wanna probably add or change some of these subs or change it to check for dualwield first based on what is in your sub slot...
	state.CombatForm:reset()
	end
	--Check for Aftermath Lv.3
	if buffactive['Aftermath: Lv.3'] then
		if player.equipment.main == 'Terpsichore' then
		state.CombatForm:set('STP')
		end
	else
	state.CombatForm:set('DW')
	end
end

function get_custom_wsmode(spell, action, spellMap)
    local wsmode
    if state.OffenseMode.value == 'MidAcc' or state.OffenseMode.value == 'HighAcc' then
        wsmode = 'Acc'
    end

    return wsmode
end

function customize_idle_set(idleSet)
    if state.CP.current == 'on' then
        equip(sets.CP)
        disable('back')
    else
        enable('back')
    end
    if state.Auto_Kite.value == true then
       idleSet = set_combine(idleSet, sets.Kiting)
    end

    return idleSet
end

function customize_melee_set(meleeSet)
    if state.Buff['Climactic Flourish'] then
        meleeSet = set_combine(meleeSet, sets.buff['Climactic Flourish'])
	end
	if state.Buff['Aftermath: Lv.3'] then
        meleeSet = set_combine(meleeSet, sets.buff['Aftermath: Lv.3'])	
    end
    if state.ClosedPosition.value == true then
        meleeSet = set_combine(meleeSet, sets.buff['Closed Position'])
    end

    return meleeSet
end

-- Function to display the current relevant user state when doing an update.
-- Set eventArgs.handled to true if display was handled, and you don't want the default info shown.
function display_current_job_state(eventArgs)
    local cf_msg = ''
    if state.CombatForm.has_value then
        cf_msg = ' (' ..state.CombatForm.value.. ')'
    end

    local m_msg = state.OffenseMode.value
    if state.HybridMode.value ~= 'Normal' then
        m_msg = m_msg .. '/' ..state.HybridMode.value
    end

    local ws_msg = state.WeaponskillMode.value

    local d_msg = 'None'
    if state.DefenseMode.value ~= 'None' then
        d_msg = state.DefenseMode.value .. state[state.DefenseMode.value .. 'DefenseMode'].value
    end

    local i_msg = state.IdleMode.value

    local msg = ''
    if state.Kiting.value then
        msg = msg .. ' Kiting: On |'
    end

    add_to_chat(002, '| ' ..string.char(31,210).. 'Melee' ..cf_msg.. ': ' ..string.char(31,001)..m_msg.. string.char(31,002)..  ' |'
        ..string.char(31,207).. ' WS: ' ..string.char(31,001)..ws_msg.. string.char(31,002)..  ' |'
        ..string.char(31,060).. ' Step: '  ..string.char(31,001)..s_msg.. string.char(31,002)..  ' |'
        ..string.char(31,004).. ' Defense: ' ..string.char(31,001)..d_msg.. string.char(31,002)..  ' |'
        ..string.char(31,008).. ' Idle: ' ..string.char(31,001)..i_msg.. string.char(31,002)..  ' |'
        ..string.char(31,002)..msg)

    eventArgs.handled = true
end


-------------------------------------------------------------------------------------------------------------------
-- User self-commands.
-------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

function determine_haste_group()
    classes.CustomMeleeGroups:clear()
    if DW == true then
        if DW_needed <= 1 then
            classes.CustomMeleeGroups:append('MaxHaste')
        elseif DW_needed > 1 and DW_needed <= 9 then
            classes.CustomMeleeGroups:append('HighHaste')
        elseif DW_needed > 9 and DW_needed <= 21 then
            classes.CustomMeleeGroups:append('MidHaste')
        elseif DW_needed > 21 and DW_needed <= 39 then
            classes.CustomMeleeGroups:append('LowHaste')
        elseif DW_needed > 39 then
            classes.CustomMeleeGroups:append('')
        end
    end
end

function gearinfo(cmdParams, eventArgs)
    if cmdParams[1] == 'gearinfo' then
        if type(tonumber(cmdParams[2])) == 'number' then
            if tonumber(cmdParams[2]) ~= DW_needed then
            DW_needed = tonumber(cmdParams[2])
            DW = true
            end
        elseif type(cmdParams[2]) == 'string' then
            if cmdParams[2] == 'false' then
                DW_needed = 0
                DW = false
            end
        end
        if type(tonumber(cmdParams[3])) == 'number' then
            if tonumber(cmdParams[3]) ~= Haste then
                Haste = tonumber(cmdParams[3])
            end
        end
        if type(cmdParams[4]) == 'string' then
            if cmdParams[4] == 'true' then
                moving = true
            elseif cmdParams[4] == 'false' then
                moving = false
            end
        end
        if not midaction() then
            job_update()
        end
    end
end



function check_moving()
    if state.DefenseMode.value == 'None'  and state.Kiting.value == false then
        if state.Auto_Kite.value == false and moving then
            state.Auto_Kite:set(true)
        elseif state.Auto_Kite.value == true and moving == false then
            state.Auto_Kite:set(false)
        end
    end
end

function check_gear()
    if no_swap_gear:contains(player.equipment.left_ring) then
        disable("ring1")
    else
        enable("ring1")
    end
    if no_swap_gear:contains(player.equipment.right_ring) then
        disable("ring2")
    else
        enable("ring2")
    end
end

windower.register_event('zone change',
    function()
        if no_swap_gear:contains(player.equipment.left_ring) then
            enable("ring1")
            equip(sets.idle)
        end
        if no_swap_gear:contains(player.equipment.right_ring) then
            enable("ring2")
            equip(sets.idle)
        end
    end)

function set_lockstyle()
    send_command('wait 1; input /echo Check Lockstyle')
end