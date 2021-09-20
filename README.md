# BirdLancer (working title)
### A Joust-Inspired Roguelike

## ELEVATOR PITCH:
**One sentence describing the game concept.**

A reimagining/riff of the Williams Arcade game Joust as a Roguelite in which a gladiator fights for his freedom atop a flying ostrich-like mount.


## TECH:
**List of software/aesthetic requirements**

- pixel art aesthetic
 - procedurally generated at the map level (how rooms connect to each other)
 - hand-designed at the room level ( individual room layouts aren't procedural, though enemy placement could still be )
 - Engine TBD

## GAMEPLAY LOOP: 
**Describe the core mechanics and objectives**

The player EXPLORES a series of interconnected rooms and areas, FIGHTING through waves of enemies to BECOME STRONGER and EARN THEIR FREEDOM.

- **BASIC MOVEMENT**: 
    - The player can walk on floors, gaining momentum as long as they are grounded
    - The player can fly by repeatedly pressing a button to flap the mount's wings, which propels them upwards slightly
    - Momentum in the air is not lost unless the player becomes grounded or makes contact with another entity or walls
    - If a collision is made (while airborne or grounded), a bounceback occurs, pushing the player in the opposite direction of the impact
    - The player can press a button to raise their lance in preparation for a strike
    - The player can also raise a shield to deflect an attack, causing bounceback if the shield takes a collision
    
- **EXPLORATION**:
    - Each floor/level consists of ~25 rooms proceduarlly stitched together in a 5x5 grid. 
    - The player always begins a floor/level in the lowest row of rooms on the map and works his way to an exit in a room in the highest row of rooms.
    - Rooms are largely single-screen with no scrolling (we should experiment and test larger scrolliing rooms in prototyping)
    - Exits are locked until the current room's enemy waves are exhausted.
    - Some exits must be unlocked with keys, gathered through exploration or dropped from stronger enemies (Boss Key for example)

- **FIGHTING**:
    - Enemies are defeated by colliding with them with a raised lance
    - Enemies fight in the same manner with windup frames of animation that give the player time to respond to the incoming threat
    - Enemies drop "Eggs" upon death, which are used as currency to upgrade the player's mount prior to each new run
    - The player also drops eggs upon death. Amount TBD

- **BECOME STRONGER**:
    - Prior to each run, the player may spend amassed eggs to upgrade their mount
    - Upgrades include:
        - Increase HP
        - Reduce bounceback
        - Increase length of lance
        - Hold button to auto-flap wings 
        - Dash forward
        - Increase size of Shield
        - others, pending prototyping
    
- **EARN THEIR FREEDOM**:
    - Fight through 8-10 floors, defeating a bosses in each
    - Confront your captor, either accepting your freedom or fighting as a boss.

## GAME ELEMENTS:
**Setting, Story, Characters**

- I could see this being pretty cool in a sci-fi setting or something more fantasy based
- The player is an unwilling gladiator, fighting for his freedom for the entertainment of others
- Some of the enemy gladiators are other prisoners; some are warriors/soldiers that are their for the sport ( Bosses, for example )
- The bossman is maybe an emperor or something. At least the organizer of the event.

## ROSTER:
**Assign roles to members here**


| Role                 | Assigned To                 |
| -------------------- | --------------------------- |
| Project Manager      | Bradley                     |
| Developer            | Luca / FATNUT               |
| Game Designer        | Bradley / Luca / John / Ivy |
| Character Artist     | Bradley                     |
| Environmental Artist | Bradley                     |
| Level Designer       | John / Ivy                  |
| Music                | Ivy                         |
| SFX                  | Ivy                         |
| Narrative Design     | Bradley                     |
| Marketing            | John                        |
| Community Manager    | TBD                         |

###### tags: `pitches`
