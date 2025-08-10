//
// Copyright (c) 2025 ImpavidEh - https://www.curseforge.com/members/impavideh/projects 
// (@Jaker.zzz on Discord) - https://discord.gg/6R6Ch2mNgZ
// 
// 
// This file is for use only in "MODIFIED COBBLEMON" projects.
// https://ModifiedMC.com

// All rights reserved.
//

// -- Currency Recipes
ServerEvents.recipes(event => {
  
  event.shapeless(
  Item.of('modified:pokedollar', 9),
  [
    'modified:coinpile_pokedollar'
  ])
});

ServerEvents.recipes(event => {
  
  event.shapeless(
  Item.of('modified:mtoken', 9),
  [
    'modified:coinpile_mtoken'
  ])
});

ServerEvents.recipes(event => {
  
  event.shapeless(
  Item.of('modified:coinpile_pokedollar', 4),
  [
    'modified:coinblock_pokedollar'
  ])
});

ServerEvents.recipes(event => {
  
  event.shapeless(
  Item.of('modified:coinpile_mtoken', 4),
  [
    'modified:coinblock_mtoken'
  ])
});

ServerEvents.recipes(event => {
  
  event.shapeless(
  Item.of('modified:coinpile_pokedollar', 1),
  [
    '9x modified:pokedollar'
  ])
});

ServerEvents.recipes(event => {
  
  event.shapeless(
  Item.of('modified:coinpile_mtoken', 1),
  [
    '9x modified:mtoken'
  ])
});

ServerEvents.recipes(event => {
  
  event.shapeless(
  Item.of('modified:coinblock_pokedollar', 1),
  [
    '4x modified:coinpile_pokedollar'
  ])
});

ServerEvents.recipes(event => {
  
  event.shapeless(
  Item.of('modified:coinblock_mtoken', 1),
  [
    '4x modified:coinpile_mtoken'
  ])
});

// -- Misc. Items
ServerEvents.recipes(event => {

    event.remove({output:'explorerscompass:explorerscompass'});
    event.shaped(
      'explorerscompass:explorerscompass',
    [
      'EME',
      'SCD',
      'EAE'
    ],
    {
      E: 'minecraft:ender_eye',
      C: 'minecraft:recovery_compass',
      A: 'minecraft:ancient_debris',
      D: 'deeperdarker:heart_of_the_deep',
      M: 'cobblemon:master_ball',
      S: 'minecraft:heart_of_the_sea'
    })
});

// -- Cobblemon Specific
ServerEvents.recipes(event=> {
  event.remove({output:'cobblemon:master_ball'})
});

ServerEvents.recipes(event=> {

  event.remove({id: 'tomtaru:mixer/hyper_potion_from_sitrus'})
});

ServerEvents.recipes(event => {

  event.custom({
    type: 'immersiveengineering:mixer',
    energy: 1600,
    fluid: { fluid: 'tmtceic:medicinal_brew', amount: 1000 },
    inputs: [
      { item: 'cobblemon:sitrus_berry' }
    ],
    result: { id: 'tmtceic:hyper_potion', amount: 1000 }
  })
});

ServerEvents.recipes(event => {
  
  event.shaped(
  'cobblemon:tart_apple',
  [
    ' G ',
    'GBG',
    ' G '
  ],
  {
    B: 'biomeswevegone:green_apple',
    G: 'minecraft:gold_block'
  })
});

ServerEvents.recipes(event => {
  
  event.shaped(
  'cobblemon:sweet_apple',
  [
    ' S ',
    'SAS',
    ' S '
  ],
  {
    A: 'minecraft:golden_apple',
    S: 'supplementaries:sugar_cube'
  })
});

 // Moon Event Items
ServerEvents.recipes(event => {
    const keystone = 'mega_showdown:keystone';

    // -- Crafting Recipes for Moon Crescents
    event.shapeless('modified:moon_crescent_blue', [
        'modified:moon_fragment_blue', 
        'modified:moon_fragment_blue', 
        keystone                     
    ]).id('kubejs:moon_crescent_blue_crafting'); 

    event.shapeless('modified:moon_crescent_blood', [
        'modified:moon_fragment_blood',
        'modified:moon_fragment_blood',
        keystone
    ]).id('modified:moon_crescent_blood_crafting');

    event.shapeless('modified:moon_crescent_harvest', [
        'modified:moon_fragment_harvest',
        'modified:moon_fragment_harvest',
        keystone
    ]).id('modified:moon_crescent_harvest_crafting');

    // -- Crafting Recipes for SUPER Moon Crescents
    event.shapeless('modified:super_moon_crescent_blue', [
        'modified:moon_crescent_blue', 
        'modified:moon_crescent_blue', 
        keystone                     
    ]).id('modified:super_moon_crescent_blue_crafting');

    event.shapeless('modified:super_moon_crescent_blood', [
        'kmodified:moon_crescent_blood',
        'modified:moon_crescent_blood',
        keystone
    ]).id('modified:super_moon_crescent_blood_crafting');

    event.shapeless('modified:super_moon_crescent_harvest', [
        'modified:moon_crescent_harvest',
        'modified:moon_crescent_harvest',
        keystone
    ]).id('modified:super_moon_crescent_harvest_crafting');
});

// Allthemodium items
ServerEvents.recipes(event => {

  event.custom({
    type: 'powah:energizing',
	ingredients: [
	  { item: 'allthemodium:allthemodium_ingot' },
	  { item: 'allthemodium:piglich_heart' },
	  { item: 'powah:nitro_crystal_block' },
	  { item: 'powah:nitro_crystal_block' },
	  { item: 'allthemodium:piglich_heart' },
	  { item: 'allthemodium:vibranium_ingot' }
	],
	energy: 1000000000,
	result: { id: 'allthemodium:vibranium_allthemodium_alloy_ingot', count: 1 }
  })
});

ServerEvents.recipes(event => {

  event.custom({
    type: 'ars_nouveau:enchanting_apparatus',
	keepNbtOfReagent: false,
	pedestalItems: [
	  { item: 'allthemodium:piglich_heart' },
	  { item: 'ars_nouveau:air_essence' },
	  { item: 'allthemodium:allthemodium_ingot' },
	  { item: 'ars_nouveau:earth_essence' },
	  { item: 'allthemodium:piglich_heart' },
	  { item: 'ars_nouveau:fire_essence' },
	  { item: 'allthemodium:unobtainium_ingot' },
	  { item: 'ars_nouveau:water_essence' }
	],
	reagent: { item: 'ars_nouveau:source_gem' },
	result: { id: 'allthemodium:unobtainium_allthemodium_alloy_ingot', count: 1 },
	sourceCost: 10000
  })
});

ServerEvents.recipes(event => {

  event.custom({
    type: 'create:mixing',
	heat_requirement: 'superheated',
	ingredients: [
	  { tag: 'c:storage_blocks/slime' },
	  { tag: 'c:storage_blocks/slime' },
	  { tag: 'c:storage_blocks/slime' },
	  { tag: 'c:storage_blocks/slime' },
	  { item: 'allthemodium:piglich_heart' },
	  { item: 'allthemodium:piglich_heart' },
	  { item: 'allthemodium:vibranium_ingot' },
	  { item: 'allthemodium:unobtainium_ingot' },
	  { type: 'fluid_stack', fluid: 'allthemodium:soul_lava', amount: 1000 }
	],
	results: [
	  { id: 'allthemodium:unobtainium_vibranium_alloy_ingot', amount: 1 }
	]
  })
});

ServerEvents.recipes(event => {

  event.custom({
    type: 'ars_nouveau:enchanting_apparatus',
	keepNbtOfReagent: true,
	pedestalItems: [
	  { item: 'allthemodium:unobtainium_vibranium_alloy_ingot' },
	  { item: 'minecraft:dragon_breath' },
	  { item: 'create:experience_block' },
	  { item: 'allthemodium:unobtainium_allthemodium_alloy_ingot' },
	  { item: 'cobblemon:dragon_gem' },
	  { item: 'allthemodium:vibranium_allthemodium_alloy_ingot' },
	  { item: 'create:experience_block' },
	  { item: 'cobblemon:dragon_fang' }
	],
	reagent: { item: 'allthemodium:unobtainium_pickaxe' },
	result: { id: 'allthemodium:alloy_pick', count: 1 },
	sourceCost: 10000
  })
});

ServerEvents.recipes(event => {

  event.custom({
    type: 'ars_nouveau:enchanting_apparatus',
	keepNbtOfReagent: true,
	pedestalItems: [
	  { item: 'allthemodium:unobtainium_vibranium_alloy_ingot' },
	  { item: 'minecraft:dragon_breath' },
	  { item: 'create:experience_block' },
	  { item: 'allthemodium:unobtainium_allthemodium_alloy_ingot' },
	  { item: 'cobblemon:dragon_gem' },
	  { item: 'allthemodium:vibranium_allthemodium_alloy_ingot' },
	  { item: 'create:experience_block' },
	  { item: 'cobblemon:dragon_fang' }
	],
	reagent: { item: 'allthemodium:unobtainium_axe' },
	result: { id: 'allthemodium:alloy_axe', count: 1 },
	sourceCost: 10000
  })
});

ServerEvents.recipes(event => {

  event.custom({
    type: 'ars_nouveau:enchanting_apparatus',
	keepNbtOfReagent: true,
	pedestalItems: [
	  { item: 'allthemodium:unobtainium_vibranium_alloy_ingot' },
	  { item: 'minecraft:dragon_breath' },
	  { item: 'create:experience_block' },
	  { item: 'allthemodium:unobtainium_allthemodium_alloy_ingot' },
	  { item: 'cobblemon:dragon_gem' },
	  { item: 'allthemodium:vibranium_allthemodium_alloy_ingot' },
	  { item: 'create:experience_block' },
	  { item: 'cobblemon:dragon_fang' }
	],
	reagent: { item: 'allthemodium:unobtainium_shovel' },
	result: { id: 'allthemodium:alloy_shovel', count: 1 },
	sourceCost: 10000
  })
});

ServerEvents.recipes(event => {

  event.custom({
    type: 'ars_nouveau:enchanting_apparatus',
	keepNbtOfReagent: true,
	pedestalItems: [
	  { item: 'allthemodium:unobtainium_vibranium_alloy_ingot' },
	  { item: 'minecraft:dragon_breath' },
	  { item: 'create:experience_block' },
	  { item: 'allthemodium:unobtainium_allthemodium_alloy_ingot' },
	  { item: 'cobblemon:dragon_gem' },
	  { item: 'allthemodium:vibranium_allthemodium_alloy_ingot' },
	  { item: 'create:experience_block' },
	  { item: 'cobblemon:dragon_fang' }
	],
	reagent: { item: 'allthemodium:unobtainium_sword' },
	result: { id: 'allthemodium:alloy_sword', count: 1 },
	sourceCost: 10000
  })
});

ServerEvents.recipes(event => {

  event.custom({
    type: 'create:mechanical_crafting',
	accept_mirrored: false,
	category: 'misc',
	pattern: [
	  ' FXE ',
	  'FLSRE',
	  'XHBPX',
	  'AKTWQ',
	  ' AXQ '
	],
	key: {
	  F: { item: 'ars_nouveau:fire_essence' },
	  X: { item: 'create:experience_block' },
	  E: { item: 'ars_nouveau:earth_essence' },
	  L: { item: 'mega_showdown:flameplate' },
	  S: { item: 'allthemodium:alloy_sword' },
	  R: { item: 'mega_showdown:earthplate' },
	  H: { item: 'allthemodium:alloy_shovel' },
	  B: { item: 'silentgear:paxel_blueprint' },
	  P: { item: 'allthemodium:alloy_pick' },
	  A: { item: 'ars_nouveau:air_essence' },
	  K: { item: 'mega_showdown:skyplate' },
	  T: { item: 'allthemodium:alloy_axe' },
	  W: { item: 'mega_showdown:splashplate' },
	  Q: { item: 'ars_nouveau:water_essence' }
	},
	result: { id: 'allthemodium:alloy_paxel', count: 1 },
	show_notification: false
  })
});

{
console.log('$$$ MODIFIED RECIPES LOADED $$$')
}

//
// Copyright (c) 2025 ImpavidEh - https://www.curseforge.com/members/impavideh/projects 
// (@Jaker.zzz on Discord) - https://discord.gg/6R6Ch2mNgZ
// 
// 
// This file is for use only in "MODIFIED COBBLEMON" projects.
// https://ModifiedMC.com

// All rights reserved.
//
