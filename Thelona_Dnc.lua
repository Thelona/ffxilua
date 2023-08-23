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
	state.Buff['Striking Flourish'] = buffactive['striking flourish'] or false
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
    state.WeaponskillMode:options('Normal', 'Acc')
    state.IdleMode:options('Normal', 'DT')

    -- Additional local binds
    --^ means cntrl
	--! means alt
    send_command('bind ^` input /ja "Chocobo Jig II" <me>')
    send_command('bind @c gs c toggle CP')

    set_lockstyle()

    state.Auto_Kite = M(false, 'Auto_Kite')
    Haste = 0
    DW_needed = 0
    DW = true
    moving = false
    update_combat_form()
    determine_haste_group()
end


-- Called when this job file is unloaded (eg: job change)
function user_unload()
    send_command('unbind ^`')
    send_command('unbind @c')
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
		ear1="Odnowa Earring +1", --0
		ear2="Tuisto Earring", --0
		body="Emet Harness +1", --10
        hands="Horos Bangles +3", --9
		ring1="Eihwaz Ring", --5
		ring2="Provocare Ring", --5
		back="Reiki Cloak", --6
		waist="Kasiri Belt", --3
		legs="Obatala Subligar", --5
        feet="Maculele Toe Shoes +2", --0
		} --Enmity 72, HP 2745, DT P34 M39 B28
		
    sets.precast.JA['Provoke'] = sets.Enmity
    sets.precast.JA['No Foot Rise'] = {body="Horos Casaque +3"}
    sets.precast.JA['Trance'] = {head="Horos Tiara +3"}

    sets.precast.Waltz = {
		ammo="Staunch Tathlum", --0/3
        head="Anwig Salade", --0/0
        body="Maxixi Casaque +3", --19/0
        hands="Nyame Gauntlets", --0/7
        legs="Dashing Subligar", --10/0
        feet="Maxixi Toe Shoes +2", --10/0
        neck="Etoile Gorget +2", --10/0
        ear1="Handler's Earring", --0/0
        ear2="Handler's Earring +1", --0/0
        ring1="Regal Ring", --
        ring2="Defending Ring", --0/10
        back=gear.DncCapetp, --0/5
        } --Waltz Potency 52/Damage taken -25%

    sets.precast.WaltzSelf = set_combine(sets.precast.Waltz, {ear1="Odnowa Earring +1",}) -- Waltz effects received

    sets.precast.Waltz['Healing Waltz'] = {}
    sets.precast.Samba = {head="Maxixi Tiara +3", back=gear.DncCapetp}
    sets.precast.Jig = {legs="Horos Tights +3", feet="Maxixi Toe Shoes +2"}

    sets.precast.Step = {
        ammo="Per. Lucky Egg", --15
        head="Volte Cap", --49
        body="Maxixi Casaque +3", --61
        hands="Maxixi Bangles +3",--103
        legs="Horos Tights +3", --50
        feet="Maxixi Toe Shoes +2", --65
        neck="Etoile Gorget +2", --37
        ear1="Crepuscular Earring", --10
        ear2="Odr Earring",
        ring1={name="Chirich Ring +1", bag="wardrobe2"},
        ring2={name="Chirich Ring +1", bag="wardrobe4"},
        waist="Chaac Belt",
        back=gear.DNC_TP_Cape
        }

    sets.precast.Step['Feather Step'] = set_combine(sets.precast.Step, {feet="Maculele Toe Shoes +2"})
    sets.precast.Flourish1 = {}
    sets.precast.Flourish1['Animated Flourish'] = sets.Enmity

    sets.precast.Flourish1['Violent Flourish'] = {
        ammo="Yamarang",
        head="Maculele Tiara +3",
        body="Horos Casaque +3",
        hands="Macu. Bangles +2",
        legs="Mummu Kecks +2",
        feet="Mummu Gamash. +2",
        neck="Etoile Gorget +2",
        ear1="Crepuscular Earring",
        ear2="Gwati Earring",
        ring1="Mummu Ring",
        ring2="Vertigo Ring",
        waist="Eschan Stone",
        back=gear.DNC_TP_Cape,
        } -- Magic Accuracy

    sets.precast.Flourish1['Desperate Flourish'] = {
        ammo="Yamarang",
        head="Maxixi Tiara +3",
        body="Maxixi Casaque +3",
        hands="Maxixi Bangles +3",
        legs="Gleti's Breeches",
        feet="Mummu Gamash. +2",
        neck="Etoile Gorget +2",
        ear1="Crepuscular Earring",
        ear2="Odr Earring",
        ring1={name="Chirich Ring +1", bag="wardrobe2"},
        ring2={name="Chirich Ring +1", bag="wardrobe4"},
        back=gear.DNC_TP_Cape,
        } -- Accuracy

    sets.precast.Flourish2 = {}
    sets.precast.Flourish2['Reverse Flourish'] = {hands="Macu. Bangles +2",back="Toetapper Mantle"}
    sets.precast.Flourish3 = {}
    sets.precast.Flourish3['Striking Flourish'] = {body="Macu. Casaque +3"}
    sets.precast.Flourish3['Climactic Flourish'] = {head="Maculele Tiara +3",}

    sets.precast.FC = {
        ammo="Sapience Orb",
        head="Herculean Helm", --7
        body="Taeon Tabard", --4
        hands="Leyline Gloves", --7
        neck="Baetyl Pendant", --2
        ear1="Loquacious Earring", --2
        ear2="Etiolation Earring", --1
        ring2="Prolix Ring", --2
        }

    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {
        neck="Magoraga Beads"
		})


    ------------------------------------------------------------------------------------------------
    ------------------------------------- Weapon Skill Sets ----------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.precast.WS = {
        ammo="Crepuscular Pebble",
        head="Maculele Tiara +3",
        body="Horos Casaque +3",
        hands="Maxixi Bangles +3",
        legs="Horos Tights +3",
        feet="Horos T. Shoes +3",
        neck="Fotia Gorget",
        ear1="Moonshade Earring",
        ear2="Sherida Earring",
        ring1="Regal Ring",
        ring2="Ilabrat Ring",
        back=gear.DncCapews,
        waist=gear.ElementalBelt,
        } -- default set

    sets.precast.WS.Acc = set_combine(sets.precast.WS, {
        ammo="Mantoptera Eye",
        ear2="Odr Earring",
        })

    sets.precast.WS.Critical = {body="Meg. Cuirie +2"}

    sets.precast.WS['Exenterator'] = set_combine(sets.precast.WS, {
	    ammo="Oshasha's Treatise",
		head="Maculele Tiara +3",
        ear1="Brutal Earring",		
        hands="Horos Bangles +3",
		ring2="Gere Ring",
        legs="Meghanada chausses +2",
        back=gear.DncCapews,
        waist="Soil Belt",
        })

    sets.precast.WS['Exenterator'].Acc = set_combine(sets.precast.WS['Exenterator'], {})

    sets.precast.WS['Pyrrhic Kleos'] = set_combine(sets.precast.WS, {
        ammo="Coiste Bodhar",
		head="Maculele Tiara +3",
		neck="Etoile Gorget +2",
        hands="Adhemar wristbands +1",
        legs="Meghanada chausses +2",
        ear1="Mache Earring +1",
		ring2="Gere Ring",
		waist="Snow Belt",
		feet="Lustratio Leggings +1",
		})

    sets.precast.WS['Pyrrhic Kleos'].Acc = set_combine(sets.precast.WS['Pyrrhic Kleos'], {
        ammo="Mantoptera Eye",
        head="Turms Cap +1",
        hands="Maxixi Bangles +3",
		back=gear.DncCapepk,
        })

    sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {
        ammo="Charis Feather",
        head="Blistering Sallet +1",
		ear2="Odr Earring",
        body="Meghanada cuirie +2",
        hands="Mummu Wrists +2",
		ring1="Mummu Ring",
		ring2="Gere Ring",
		waist="Soil Belt",
        legs="Mummu Kecks +2",
		feet="Mummu Gamashes +2",
		})

    sets.precast.WS['Evisceration'].Acc = set_combine(sets.precast.WS['Evisceration'], {})

	sets.precast.WS['Shark Bite'] = {
        ammo="Oshasha's Treatise",
		neck="Rep. Plat. Medal",
		body="Macu. Casaque +3",
		ring2="Cornelia's Ring",
		waist="Sailfi Belt +1",
		feet="Herculean Boots",
        }

    sets.precast.WS['Rudra\'s Storm'] = set_combine(sets.precast.WS, {
        ammo="Oshasha's Treatise",
        neck="Etoile Gorget +2",
		body="Macu. Casaque +3",
		ring2="Cornelia's Ring",
        waist="Kentarch Belt +1",
		feet="Herculean Boots",
        })

    sets.precast.WS['Rudra\'s Storm'].Acc = set_combine(sets.precast.WS['Rudra\'s Storm'], {})

    sets.precast.WS['Aeolian Edge'] = {
		ammo="Oshasha's Treatise",
		head="Nyame Helm",
		neck="Sibyl Scarf",
		ear1="Friomisi Earring",
		ear2="Moonshade Earring",
	    body="Nyame Mail",
		hands="Nyame Gauntlets",
		ring1="Metamor. Ring +1",
		ring2="Cornelia's Ring",
		back=gear.DncCapeae,
		waist="Eschan Stone",
		legs="Nyame Flanchard",
		feet="Herculean Boots"}

    sets.precast.Skillchain = {
        hands="Macu. Bangles +2",
        }

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Midcast Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.midcast.FastRecast = sets.precast.FC

    sets.midcast.SpellInterrupt = {}

    sets.midcast.Utsusemi = sets.midcast.SpellInterrupt

    ------------------------------------------------------------------------------------------------
    ----------------------------------------- Idle Sets --------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.resting = {}

    sets.idle = {
		ammo="Staunch Tathlum +1",
		head="Turms Cap +1",
		neck="Republican platinum medal",
		ear1="Infused Earring",
		ear2="Dawn Earring",
        body="Gleti's Cuirass",
		hands="Gleti's Gauntlets",
		ring1="Sheltered Ring",
		ring2="Paguroidea Ring",
        back={ name="Senuna's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Evasion+10','Enmity+10','Damage taken-5%',}},
		waist="Lycopodium Sash",
		legs="Gleti's Breeches",
		feet="Skadi's Jambeaux +1"}

    sets.idle.DT = set_combine(sets.idle, {
		ammo="Yamarang",
        head="Nyame Helm",
		neck="Etoile Gorget +2",
		ear1="Odnowa Earring +1",
		ear2="Tuisto Earring",
        body="Nyame Mail",
		hands="Nyame Gauntlets",
		ring1="Dark Ring",
		ring2="Defending Ring",
        back={ name="Senuna's Mantle", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Evasion+10','Enmity+10','Damage taken-5%',}},
		waist="Plat. Mog. Belt",
		legs="Nyame Flanchard"})

    sets.idle.Town = sets.idle

    sets.idle.Weak = sets.idle
	sets.idle.Weak.DT = sets.idle.DT

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
		ear2="Eabani Earring",
        body="Macu. Casaque +3",
		hands="Adhemar Wristbands +1",
		ring1="Gere Ring",
		ring2="Epona's Ring",
        back=gear.DncCapetp,
		waist="Reiki Yotai",
		legs="Meg. Chausses +2",
		feet="Horos T. Shoes +3"}

    sets.engaged.LowAcc = set_combine(sets.engaged, {})

    sets.engaged.MidAcc = set_combine(sets.engaged.LowAcc, {})

    sets.engaged.HighAcc = set_combine(sets.engaged.MidAcc, {})

    sets.engaged.STP = set_combine(sets.engaged, {
		ammo="Yamarang",
		head="Maculele Tiara +3",
		neck="Etoile Gorget +2",
		ear1="Crepuscular Earring",
		ear2="Dedition Earring",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		ring1={name="Chirich Ring +1", bag="wardrobe2"},
		ring2={name="Chirich Ring +1", bag="wardrobe4"},
		back=gear.DncCapeTp,
		waist="Windbuffet Belt +1",
		legs="Meghanada Chausses +2",
		feet="Maculele Toe Shoes +2"})

    -- * DNC Native DW Trait: 30% DW
    -- * DNC Job Points DW Gift: 5% DW

    -- No Magic Haste (39% DW to cap)
    sets.engaged.DW = {
        ammo="Coiste Bodhar",
        head="Maxixi Tiara +3",neck="Charis Necklace",ear1="Suppanomimi",ear2="Eabani Earring",
        body="Macu. Casaque +3",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.DncCapetp,waist="Reiki Yotai",legs="Meg. Chausses +2",feet="Horos T. Shoes +3"}
		
    sets.engaged.DW.LowAcc = set_combine(sets.engaged.DW, {})

    sets.engaged.DW.MidAcc = set_combine(sets.engaged.DW.LowAcc, {})

    sets.engaged.DW.HighAcc = set_combine(sets.engaged.DW.MidAcc, {})

    sets.engaged.DW.STP = set_combine(sets.engaged.DW, {
        })

    -- 15% Magic Haste (32% DW to cap)
    sets.engaged.DW.LowHaste = {
        ammo="Coiste Bodhar",
        head="Maxixi Tiara +3",neck="Charis Necklace",ear1="Suppanomimi",ear2="Sherida Earring",
        body="Macu. Casaque +3",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.DncCapetp,waist="Reiki Yotai",legs="Meg. Chausses +2",feet="Horos T. Shoes +3"}

    sets.engaged.DW.LowAcc.LowHaste = set_combine(sets.engaged.DW.LowHaste, {})

    sets.engaged.DW.MidAcc.LowHaste = set_combine(sets.engaged.DW.LowAcc.LowHaste, {})

    sets.engaged.DW.HighAcc.LowHaste = set_combine(sets.engaged.DW.MidAcc.LowHaste, {})

    sets.engaged.DW.STP.LowHaste = set_combine(sets.engaged.DW.LowHaste, {
        ammo="Yamarang",
		head="Maculele Tiara +3",
		neck="Etoile Gorget +2",
		ear1="Crepuscular Earring",
		ear2="Dedition Earring",
		body="Macu. Casaque +3",
		hands="Malignance Gloves",
		ring1={name="Chirich Ring +1", bag="wardrobe2"},
		ring2={name="Chirich Ring +1", bag="wardrobe4"},
		back=gear.DncCapeTp,
		waist="Windbuffet Belt +1",
		legs="Meghanada Chausses +2",
		feet="Maculele Toe Shoes +2"})

    -- 30% Magic Haste (21% DW to cap)
    sets.engaged.DW.MidHaste = {ammo="Coiste Bodhar",
        head="Adhemar Bonnet +1",neck="Charis Necklace",ear1="Dedition Earring",ear2="Sherida Earring",
        body="Macu. Casaque +3",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.DncCapetp,waist="Reiki Yotai",legs="Meg. Chausses +2",feet="Horos T. Shoes +3"}

    sets.engaged.DW.LowAcc.MidHaste = set_combine(sets.engaged.DW.MidHaste, {})

    sets.engaged.DW.MidAcc.MidHaste = set_combine(sets.engaged.DW.LowAcc.MidHaste, {})

    sets.engaged.DW.HighAcc.MidHaste = set_combine(sets.engaged.DW.MidAcc.MidHaste, {})

    sets.engaged.DW.STP.MidHaste = set_combine(sets.engaged.DW.MidHaste, {
        ammo="Yamarang",
		head="Maculele Tiara +3",
		neck="Etoile Gorget +2",
		ear1="Crepuscular Earring",
		ear2="Dedition Earring",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		ring1={name="Chirich Ring +1", bag="wardrobe2"},
		ring2={name="Chirich Ring +1", bag="wardrobe4"},
		back=gear.DncCapeTp,
		waist="Windbuffet Belt +1",
		legs="Meghanada Chausses +2",
		feet="Horos Toe Shoes +3"})

    -- 35% Magic Haste (16% DW to cap)
    sets.engaged.DW.HighHaste = {ammo="Coiste Bodhar",
        head="Adhemar Bonnet +1",neck="Etoile Gorget +2",ear1="Suppanomimi",ear2="Sherida Earring",
        body="Macu. Casaque +3",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.DncCapetp,waist="Windbuffet Belt +1",legs="Meg. Chausses +2",feet="Horos T. Shoes +3"} 

    sets.engaged.DW.LowAcc.HighHaste = set_combine(sets.engaged.DW.HighHaste, {})

    sets.engaged.DW.MidAcc.HighHaste = set_combine(sets.engaged.DW.LowAcc.HighHaste, {})

    sets.engaged.DW.HighAcc.HighHaste = set_combine(sets.engaged.DW.MidAcc.HighHaste, {})

    sets.engaged.DW.STP.HighHaste = set_combine(sets.engaged.DW.HighHaste, {
        ammo="Yamarang",
		head="Maculele Tiara +3",
		neck="Etoile Gorget +2",
		ear1="Crepuscular Earring",
		ear2="Dedition Earring",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		ring1={name="Chirich Ring +1", bag="wardrobe2"},
		ring2={name="Chirich Ring +1", bag="wardrobe4"},
		back=gear.DncCapeTp,
		waist="Windbuffet Belt +1",
		legs="Meghanada Chausses +2",
		feet="Maculele Toe Shoes +2"})

    -- 45% Magic Haste (1% DW to cap)
    sets.engaged.DW.MaxHaste = {ammo="Coiste Bodhar",
        head="Adhemar Bonnet +1",neck="Etoile Gorget +2",ear1="Dedition Earring",ear2="Sherida Earring",
        body="Horos Casaque +3",hands="Adhemar Wristbands +1",ring1="Gere Ring",ring2="Epona's Ring",
        back=gear.DncCapetp,waist="Windbuffet Belt +1",legs="Meg. Chausses +2",feet="Horos T. Shoes +3"} 

    sets.engaged.DW.LowAcc.MaxHaste = set_combine(sets.engaged.DW.MaxHaste, {})

    sets.engaged.DW.MidAcc.MaxHaste = set_combine(sets.engaged.DW.LowAcc.MaxHaste, {})

    sets.engaged.DW.HighAcc.MaxHaste = set_combine(sets.engaged.DW.MidAcc.MaxHaste, {})

    sets.engaged.DW.STP.MaxHaste = set_combine(sets.engaged.DW.MaxHaste, {
        ammo="Yamarang",
		head="Maculele Tiara +3",
		neck="Etoile Gorget +2",
		ear1="Crepuscular Earring",
		ear2="Dedition Earring",
		body="Malignance Tabard",
		hands="Malignance Gloves",
		ring1={name="Chirich Ring +1", bag="wardrobe2"},
		ring2={name="Chirich Ring +1", bag="wardrobe4"},
		back=gear.DncCapeTp,
		waist="Windbuffet Belt +1",
		legs="Meghanada Chausses +2",
		feet="Maculele Toe Shoes +2"})

    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Hybrid Sets -------------------------------------------
    ------------------------------------------------------------------------------------------------

    --sets.engaged.Hybrid = {
    --    ammo="Crepuscular Pebble",
    --    head="Nyame Helm",
    --    body="Malignance Tabard",
	--	hands="Malignance Gloves",
	--	ring1="Dark Ring",
	--	ring2="Defending Ring",
     --   back=gear.DncCapetp,
	--	legs="Gleti's Breeches"}

    sets.engaged.DT = set_combine(sets.engaged, sets.engaged.Hybrid)
    sets.engaged.LowAcc.DT = set_combine(sets.engaged.LowAcc, sets.engaged.Hybrid)
    sets.engaged.MidAcc.DT = set_combine(sets.engaged.MidAcc, sets.engaged.Hybrid)
    sets.engaged.HighAcc.DT = set_combine(sets.engaged.HighAcc, sets.engaged.Hybrid)
    sets.engaged.STP.DT = set_combine(sets.engaged.STP, sets.engaged.Hybrid)

    sets.engaged.DW.DT = set_combine(sets.engaged.DW, {
		ammo="Crepuscular Pebble",
		hands="Macu. Bangles +2",
		legs="Gleti's Breeches",
		feet="Macu. Toe Sh. +2",
	})
    sets.engaged.DW.LowAcc.DT = set_combine(sets.engaged.DW.LowAcc, sets.engaged.Hybrid)
    sets.engaged.DW.MidAcc.DT = set_combine(sets.engaged.DW.MidAcc, sets.engaged.Hybrid)
    sets.engaged.DW.HighAcc.DT = set_combine(sets.engaged.DW.HighAcc, sets.engaged.Hybrid)
    sets.engaged.DW.STP.DT = set_combine(sets.engaged.DW.STP, sets.engaged.Hybrid)

    sets.engaged.DW.DT.LowHaste = set_combine(sets.engaged.DW.LowHaste, {
		ammo="Crepuscular Pebble",
		hands="Macu. Bangles +2",
		legs="Gleti's Breeches",
		feet="Macu. Toe Sh. +2",
	})
    sets.engaged.DW.LowAcc.DT.LowHaste = set_combine(sets.engaged.DW.LowAcc.LowHaste, sets.engaged.Hybrid)
    sets.engaged.DW.MidAcc.DT.LowHaste = set_combine(sets.engaged.DW.MidAcc.LowHaste, sets.engaged.Hybrid)
    sets.engaged.DW.HighAcc.DT.LowHaste = set_combine(sets.engaged.DW.HighAcc.LowHaste, sets.engaged.Hybrid)
    sets.engaged.DW.STP.DT.LowHaste = set_combine(sets.engaged.DW.STP.LowHaste, sets.engaged.Hybrid)

    sets.engaged.DW.DT.MidHaste = set_combine(sets.engaged.DW.MidHaste, {
		ammo="Crepuscular Pebble",
		hands="Macu. Bangles +2",
		legs="Gleti's Breeches",
		feet="Macu. Toe Sh. +2",
	})
    sets.engaged.DW.LowAcc.DT.MidHaste = set_combine(sets.engaged.DW.LowAcc.MidHaste, sets.engaged.Hybrid)
    sets.engaged.DW.MidAcc.DT.MidHaste = set_combine(sets.engaged.DW.MidAcc.MidHaste, sets.engaged.Hybrid)
    sets.engaged.DW.HighAcc.DT.MidHaste = set_combine(sets.engaged.DW.HighAcc.MidHaste, sets.engaged.Hybrid)
    sets.engaged.DW.STP.DT.MidHaste = set_combine(sets.engaged.DW.STP.MidHaste, sets.engaged.Hybrid)

    sets.engaged.DW.DT.HighHaste = set_combine(sets.engaged.DW.HighHaste, {
		ammo="Crepuscular Pebble",
		hands="Macu. Bangles +2",
		legs="Gleti's Breeches",
		feet="Macu. Toe Sh. +2",
	})
    sets.engaged.DW.LowAcc.DT.HighHaste = set_combine(sets.engaged.DW.LowAcc.HighHaste, sets.engaged.Hybrid)
    sets.engaged.DW.MidAcc.DT.HighHaste = set_combine(sets.engaged.DW.MidAcc.HighHaste, sets.engaged.Hybrid)
    sets.engaged.DW.HighAcc.DT.HighHaste = set_combine(sets.engaged.DW.HighAcc.HighHaste, sets.engaged.Hybrid)
    sets.engaged.DW.STP.DT.HighHaste = set_combine(sets.engaged.DW.HighHaste.STP, sets.engaged.Hybrid)

    sets.engaged.DW.DT.MaxHaste = set_combine(sets.engaged.DW.MaxHaste, {
		ammo="Crepuscular Pebble",
		hands="Macu. Bangles +2",
		ring1="Defending Ring",
		legs="Gleti's Breeches",
		feet="Macu. Toe Sh. +2",
	})
    sets.engaged.DW.LowAcc.DT.MaxHaste = set_combine(sets.engaged.DW.LowAcc.MaxHaste, sets.engaged.Hybrid)
    sets.engaged.DW.MidAcc.DT.MaxHaste = set_combine(sets.engaged.DW.MidAcc.MaxHaste, sets.engaged.Hybrid)
    sets.engaged.DW.HighAcc.DT.MaxHaste = set_combine(sets.engaged.DW.HighAcc.MaxHaste, sets.engaged.Hybrid)
    sets.engaged.DW.STP.DT.MaxHaste = set_combine(sets.engaged.DW.STP.MaxHaste, sets.engaged.Hybrid)


    ------------------------------------------------------------------------------------------------
    ---------------------------------------- Special Sets ------------------------------------------
    ------------------------------------------------------------------------------------------------

    sets.buff['Saber Dance'] = {}
    sets.buff['Fan Dance'] = {}
	--sets.buff['Striking Flourish'] = {}
    sets.buff['Climactic Flourish'] = {ammo="Charis Feather",head="Maculele Tiara +3",body="Meg. Cuirie +2"}
    sets.buff['Closed Position'] = {feet="Horos T. Shoes +3"}

    sets.buff.Doom = {}

    -- sets.CP = {back="Mecisto. Mantle"}
    --sets.Reive = {neck="Adoulin's Refuge +1"}

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
    if buff == 'Saber Dance' or buff == 'Climactic Flourish' or buff == 'Fan Dance' then
        handle_equipping_gear(player.status)
    end

    --if buffactive['Reive Mark'] then
    --    if gain then
    --       equip(sets.Reive)
    --        disable('neck')
    --    else
    --        enable('neck')
    --    end
    --end

    if buff == "doom" then
        if gain then
            equip(sets.buff.Doom)
            send_command('@input /echo Doomed.')
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
	update_combat_form()
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