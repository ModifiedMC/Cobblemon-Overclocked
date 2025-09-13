// This File has been authored by AllTheMods Staff, or a Community contributor for use in AllTheMods - AllTheMods 10.
// As all AllTheMods packs are licensed under All Rights Reserved, this file is not allowed to be used in any public packs not released by the AllTheMods Team, without explicit permission.

ServerEvents.recipes(allthemods => {

    allthemods.shaped('kubejs:magical_soil', ['ABC', 'DEF', 'GHI'], {
        A: 'mysticalagradditions:insanium_block',
        B: '#c:nether_stars',
        C: 'minecraft:sculk_catalyst',
        D: 'mysticalagriculture:awakened_supremium_growth_accelerator',
        E: 'mysticalagradditions:insanium_farmland',
        F: 'minecraft:dragon_head',
        G: 'allthemodium:piglich_heart',
        H: '#c:storage_blocks/entro',
        I: 'aether:golden_oak_sapling'
    }).id('allthemods:kjs/magical_soil')

    function addInfustion(seed, item, essence) {
        allthemods.custom(
            {
                type: 'mysticalagriculture:infusion',
                input: {
                    item:  'mysticalagriculture:prosperity_seed_base'
                },
                ingredients: [
                    {
                        item: item
                    },
                    {
                        item: essence
                    },
                    {
                        item: item
                    },
                    {
                        item: essence
                    },
                    {
                        item: item
                    },
                    {
                        item: essence
                    },
                    {
                        item: item
                    },
                    {
                        item: essence
                    }
                ],
                result: {
                    id: seed
                }
            }
        ).id(seed.replace(':', ':infusion/'))
    }

    //addInfustion('mysticalagriculture:silicon_seeds', 'ae2:silicon', 'mysticalagriculture:prudentium_essence')
    //addInfustion('mysticalagriculture:steel_seeds', 'alltheores:steel_ingot', 'mysticalagriculture:imperium_essence')

})

// This File has been authored by AllTheMods Staff, or a Community contributor for use in AllTheMods - AllTheMods 10.
// As all AllTheMods packs are licensed under All Rights Reserved, this file is not allowed to be used in any public packs not released by the AllTheMods Team, without explicit permission.
