# DruidMacroHelper (TBC Classic) by Mylaerla-Everlook

This addon aims to simplify consume/powershifting macros as much as possible,
making them more readable and massively reduce the character count.

Credit to:
- Fyroth and Zia for coming up / bringing to attention this improved method of powershifting
- PsiloShift / Psilocybin-Mograine(H) for providing inspiration to further improve the addon (see https://github.com/HxxxxxS/PsiloShift )
- The youtuber griftin for bringing those macro to my attention (see https://www.youtube.com/watch?v=wAjeA4ZokyY )

The addon allows your macros to prevent shifting out of form if:
- You are stunned/feared/...
- You are on global cooldown
- You don't have enough mana to shift back
And optionally
- If specific items are on cooldown
- If your enegery is above a certain threshold

## Download

You can download the latest Version on CurseForge (manually or via the app):
https://www.curseforge.com/wow/addons/druidmacrohelper

## Examples:

### Cat powershifting
#### Will shift out of cat form and back in if you are below 30 energy
```lua
#showtooltip
/stopattack
/dmh energy 30
/cast !Cat Form
/dmh end
/startattack
```

### Healthstone
#### Will shift out of form, use a Healthstone and shift back into the form you started in
```lua
#showtooltip
/stopattack
/click dmhStart
/dmh cd hs
/use Master Healthstone
/click dmhEnd
/startattack
```

### Super Healing Potion
#### Will shift out of form, use a Super Healing Potion and shift back into the form you started in
```lua
#showtooltip
/stopattack
/click dmhStart
/dmh cd pot
/use Super Healing Potion
/click dmhEnd
/startattack
```

### Goblin Sapper
#### Will shift out of form, use a Super Sapper Charge / Goblin Sapper Charge and shift back into the form you started in
```lua
#showtooltip
/click [mod:shift]dmhSuperSap;dmhSap
/click dmhStart
/use [mod:shift]Super Sapper Charge;Goblin Sapper Charge
/click dmhEnd
```

## Available commands

There are two options on how to use the addon in macros:

### Click variants
The click variants allow to use modifiers (like shown in the sapper example)
* `/click dmhStart` Change actionbar based on the current form. (includes /dmh start)
* `/click dmhReset` Change actionbar back to 1.
* `/click dmhEnd` Change back to form based on the current bar. (includes /dmh end)
* `/click dmhPot` Disable autoUnshift if not ready to use a potion
* `/click dmhHs` Disable autoUnshift if not ready to use a healthstone
* `/click dmhSap` Disable autoUnshift if not ready to use a sapper
* `/click dmhSuperSap` Disable autoUnshift if not ready to use a super sapper

### Slash commands
The slash commands allow for more flexibility in some cases (like custom itemIds or energy-based shifting)
* `/dmh start`

    Disable autoUnshift if player is stunned, on gcd or out of mana
* `/dmh end`

    Enable autoUnshift again
* `/dmh stun`

    Disable autoUnshift if stunned    
* `/dmh cd <itemId|itemShortcut>[ <itemId|itemShortcut> ...]`

    Disable autoUnshift if items are on cooldown, player is stunned, on gcd or out of mana
* `/dmh energy <maxEnergy>`

    Disable autoUnshift if above given energy value, player is stunned, on gcd or out of mana
