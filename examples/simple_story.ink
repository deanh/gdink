VAR player_name = "Player"
VAR has_sword = false

=== start ===
# character:Narrator
Once upon a time, there was a brave adventurer named {player_name}.

* [Continue]
    -> village

=== village ===
# character:Village Elder
Welcome to our village, {player_name}. We need your help!

* [What's the problem?]
    The dragon has been terrorizing our village for weeks!
    
    * [I'll help you]
        -> quest_accepted
    * [Not my problem]
        -> quest_declined

=== quest_accepted ===
# character:Village Elder
Thank you, {player_name}! You'll need a weapon.

{has_sword:
    # character:Narrator
    You already have a sword.
    -> dragon
- else:
    # character:Village Elder
    Take this sword, it may help you.
    ~ has_sword = true
    -> dragon
}

=== quest_declined ===
# character:Village Elder
I understand. Not everyone is meant to be a hero.

-> END

=== dragon ===
# character:Narrator
You approach the dragon's cave...

* {has_sword} [Attack with sword]
    # character:Narrator
    With your mighty sword, you defeat the dragon!
    -> victory
* [Run away]
    # character:Narrator
    You decide this was a bad idea and run back to the village.
    -> village

=== victory ===
# character:Village Elder
You've saved our village, {player_name}! You are a true hero!

-> END