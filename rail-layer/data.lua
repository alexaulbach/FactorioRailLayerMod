data:extend(
{
  {
    type = "item",
    name = "rail-layer",
    icon = "__rail-layer__/graphics/rail-layer-icon.png",
    flags = {"goes-to-quickbar"},
    subgroup = "transport",
    order = "a[train-system]-e[diesel-locomotive]",
    place_result = "rail-layer",
    stack_size = 8
  },
  {
    type = "recipe",
    name = "rail-layer",
    enabled = "false",
    ingredients =
    {
      {"engine-unit", 15},
      {"electronic-circuit", 15},
      {"steel-plate", 10},
      {"straight-rail", 10},
    },
    result = "rail-layer"
  },

 {
    type = "locomotive",
    name = "rail-layer",
    icon = "__rail-layer__/graphics/rail-layer-icon.png",
    flags = {"placeable-neutral", "player-creation", "placeable-off-grid"},
    minable = {mining_time = 1, result = "rail-layer"},
    max_health = 1000,
    corpse = "medium-remnants",
    dying_explosion = "huge-explosion",
    collision_box = {{-0.6, -2.6}, {0.6, 2.6}},
    selection_box = {{-0.7, -2.5}, {1, 2.5}},
    drawing_box = {{-1, -4}, {1, 3}},
    weight = 2000,
    max_speed = 0.6,
    max_power = "600kW",
    braking_force = 10,
    friction_force = 0.0015,
    -- this is a percentage of current speed that will be subtracted
    air_resistance = 0.002,
    connection_distance = 3.3,
    joint_distance = 4.6,
    energy_per_hit_point = 5,
    energy_source =
    {
      type = "burner",
      effectivity = 1,
      fuel_inventory_size = 1,
    },
    front_light =
    {
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "medium",
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {-0.6, -16},
        size = 2,
        intensity = 0.6
      },
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "medium",
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {0.6, -16},
        size = 2,
        intensity = 0.6
      }
    },
    back_light = rolling_stock_back_light(),
    stand_by_light = rolling_stock_stand_by_light(),
    pictures =
    {
      priority = "very-low",
      frame_width = 346,
      frame_height = 248,
      axially_symmetrical = false,
      direction_count = 256,
      filenames =
      {
        "__rail-layer__/graphics/rail-layer-01.png",
        "__rail-layer__/graphics/rail-layer-02.png",
        "__rail-layer__/graphics/rail-layer-03.png",
        "__rail-layer__/graphics/rail-layer-04.png",
        "__rail-layer__/graphics/rail-layer-05.png",
        "__rail-layer__/graphics/rail-layer-06.png",
        "__rail-layer__/graphics/rail-layer-07.png",
        "__rail-layer__/graphics/rail-layer-08.png"
      },
      line_length = 4,
      lines_per_file = 8,
      shift = {0.9, -0.45}
    },
    rail_category = "regular",

    stop_trigger =
    {
      -- left side
      {
        type = "create-smoke",
        repeat_count = 125,
        entity_name = "smoke-train-stop",
        initial_height = 0,
        -- smoke goes to the left
        speed = {-0.03, 0},
        speed_multiplier = 0.75,
        speed_multiplier_deviation = 1.1,
        offset_deviation = {{-0.75, -2.7}, {-0.3, 2.7}}
      },
      -- right side
      {
        type = "create-smoke",
        repeat_count = 125,
        entity_name = "smoke-train-stop",
        initial_height = 0,
        -- smoke goes to the right
        speed = {0.03, 0},
        speed_multiplier = 0.75,
        speed_multiplier_deviation = 1.1,
        offset_deviation = {{0.3, -2.7}, {0.75, 2.7}}
      },
      {
        type = "play-sound",
        sound =
        {
          {
            filename = "__base__/sound/train-breaks.ogg",
            volume = 0.6
          },
        }
      },
    },
    drive_over_tie_trigger = drive_over_tie(),
    tie_distance = 50,
    crash_trigger = crash_trigger(),
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/train-engine.ogg",
        volume = 0.4
      },
      match_speed_to_activity = true,
    },
    open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
    close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
    sound_minimum_speed = 0.5;
  },

})

table.insert(data.raw["technology"]["automated-rail-transportation"].effects,{type = "unlock-recipe",recipe = "rail-layer"})
