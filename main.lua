gdebug.log_info("more_world: loaded")

local function check_accelerator()
  local avatar = gapi.get_avatar()
  if not avatar then return end

  local has_bio = avatar:has_bionic(BionicDataId.new("bio_emergency_accelerator"))

  if not has_bio then
    if avatar:has_effect(EffectTypeId.new("eff_emergency_accel")) then
      avatar:remove_effect(EffectTypeId.new("eff_emergency_accel"))
    end
    return
  end

  local pct = avatar:hp_percentage()

  if pct <= 25 then
    local intensity = 1
    if pct <= 5 then
      intensity = 4
    elseif pct <= 10 then
      intensity = 3
    elseif pct <= 18 then
      intensity = 2
    end

    local effect_id = EffectTypeId.new("eff_emergency_accel")
    if not avatar:has_effect(effect_id) then
      avatar:add_effect(effect_id, TimeDuration.from_turns(50), nil, intensity)
    else
      local current_int = avatar:get_effect_int(effect_id)
      if current_int ~= intensity then
        avatar:remove_effect(effect_id)
        avatar:add_effect(effect_id, TimeDuration.from_turns(50), nil, intensity)
      end
    end
  else
    local effect_id = EffectTypeId.new("eff_emergency_accel")
    if avatar:has_effect(effect_id) then
      avatar:remove_effect(effect_id)
    end
  end
end

gapi.add_on_every_x_hook(TimeDuration.from_turns(5), check_accelerator)

game.add_hook("on_creature_melee_attacked", function(params)
  local char = params.char
  if not char or not char:is_avatar() then return end
  if not char:has_bionic(BionicDataId.new("bio_adrenaline_stim")) then return end
  local target = params.target
  if target and target:get_hp() <= 0 then
    local max_st = char:get_stamina_max()
    char:mod_stamina(math.floor(max_st * 0.1))
  end
end)

-- Sarif converter: +1 kJ every 10 minutes (approx 600 turns)
gapi.add_on_every_x_hook(TimeDuration.from_turns(600), function()
  local avatar = gapi.get_avatar()
  if avatar and avatar:has_bionic(BionicDataId.new("bio_sarif_converter")) then
    avatar:mod_power_level(units.energy.from_kilojoule(1))
  end
end)

