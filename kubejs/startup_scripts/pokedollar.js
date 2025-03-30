StartupEvents.registry('item', function(event) {
  event.create('modified:pokedollar')
    .displayName('§6PokéDollar')
    .texture('modified:item/pokedollar')
    .maxStackSize(99);

  event.create('modified:pokedollar_pile')
    .displayName('§6PokéDollar Pile')
    .texture('modified:item/pokedollar_pile')
    .maxStackSize(99);

  event.create('modified:pokedollar_block')
    .displayName('§6Block of PokéDollars')
    .texture('modified:item/pokedollar_block')
    .maxStackSize(99);
});