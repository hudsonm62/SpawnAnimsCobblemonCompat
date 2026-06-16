# Spawn Animations - Cobblemon Compat

Basic support for Cobblemon in [Spawn Animations](https://modrinth.com/project/zrzYrlm0).

Pack contains two variants for both spawn animation types (Poof and Digup) - Both variants also available as NeoForge & Fabric Mods if you prefer that over a datapack.

## Issues

Cobblemon uses custom natural spawning mechanics, which are not entirely compatible with Spawn Animations but it can be made to work with some limitations:

- Increase the Activation Distance to 40 or higher blocks to prevent Pokemon from bugging out in the distance with the Digup variant.
    - For some reason, Pokemon don't hide underground so they will be visible until they are close enough to the player to trigger the animation, which looks janky.
- Don't use the "Vanilla" activation mode, as it will cause Pokemon to spawn without any animation at all.

## License

Packaged under Apache License 2.0, see [LICENSE](LICENSE) for more details.

You may use this in your modpacks, all I ask is that you please link back to this [Modrinth Project](https://modrinth.com/project/49Qa4WIf) via a [manifest](https://support.modrinth.com/en/articles/8802351-modrinth-modpack-format-mrpack)!
