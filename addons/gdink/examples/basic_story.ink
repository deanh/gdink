# basic_story.ink
# A simple example of an Ink script

VAR player_name = "Adventurer"
VAR health = 100
VAR has_sword = false

=== start ===
# character: Narrator
Welcome, {player_name}! Your adventure begins here.

* [Look around] -> look_around
* [Check inventory] -> check_inventory
* [Talk to stranger] -> talk_to_stranger

=== look_around ===
# character: Narrator
You find yourself in a dimly lit tavern. The air is thick with smoke and the smell of ale.

There's a mysterious stranger sitting in the corner, watching you carefully.
A rusty sword hangs on the wall.

* [Take the sword] -> take_sword
* [Approach the stranger] -> talk_to_stranger
* [Leave the tavern] -> leave_tavern

=== take_sword ===
# character: Narrator
You grab the sword from the wall. It's old but still sharp.
~ has_sword = true

* [Continue] -> look_around

=== check_inventory ===
# character: Narrator
You have:
{has_sword: A rusty sword}
{not has_sword: No weapons}
Health: {health}

* [Return] -> start

=== talk_to_stranger ===
# character: Stranger
Hello there, {player_name}. I've been waiting for someone like you.

* [Ask about the quest]
    # character: You
    What's this quest you speak of?
    
    # character: Stranger
    The village to the north is in danger. They need a brave soul to defend them.
    
    * * [Accept the quest] -> accept_quest
    * * [Decline] -> decline_quest

* [Leave] -> look_around

=== accept_quest ===
# character: Stranger
Excellent! Take this map and head north at dawn.

{has_sword: The sword you found will serve you well.}
{not has_sword: You might want to find a weapon first.}

* [End conversation] -> look_around

=== decline_quest ===
# character: Stranger
Perhaps another time then. The offer remains open.

* [End conversation] -> look_around

=== leave_tavern ===
# character: Narrator
You step outside into the cool night air. The village is quiet.

This is the end of our demo.
-> END