# Spawn Animations - Cobblemon Compat

Basic support for Cobblemon in [Spawn Animations](https://modrinth.com/project/zrzYrlm0).

Contains two variants for both spawn animation types (Poof and Digup) - Also available as a mod (Fabric/NeoForge) if you prefer that over a datapack.

![Digup Sample][DigupSample]

## Issues

Cobblemon uses custom natural spawning mechanics, which are not entirely compatible with Spawn Animations but it can be made to work with some limitations:

- Don't use the "Vanilla" activation mode, as it will cause Pokemon to spawn without any animation at all.
- Increase the Activation Distance to 40 or higher blocks to prevent Pokemon from bugging out in the distance with the Digup variant.
    - For some reason, Pokemon don't hide underground so they will be visible until they are close enough to the player to trigger the animation, which looks janky.
- Some NPC mons may trigger spawn animations unexpectedly.
    - This can happen depending on how the NPC mons are configured and whether they have owned behaviour correctly set up.
    - If you're a pack maker, ensure either it's mons are spawned `uncatchable`, and/or have the `cobblemon:pokemon_follows_owner` behaviour enabled.

## License

Packaged under Apache License 2.0, see [LICENSE] for more details.

You may use this in your modpacks, all I ask is that you please link back to this [Modrinth Project](https://modrinth.com/project/49Qa4WIf) via a [manifest](https://support.modrinth.com/en/articles/8802351-modrinth-modpack-format-mrpack)!

<!--
    LINKS BELOW
-->

[DigupSample]: .github/assets/digup-example.gif
[LICENSE]: LICENSE
