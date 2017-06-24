# !vote script for Soldat server

Allows players start a vote for either:

* the next map - `!vote`
* any specific map - `!vote ash`, `!vote equi`, `!vote ctf_Nimble`

When a vote is started, its target map is locked and cannot be changed for its duration. A vote lasts one minute by default, with any subsequent votes increasing the time by 10 seconds.

All of the following do exactly the same thing: `!v`, `!vot`, `!vote`, `!votemap`, `!votenext`, `!votenextmap`, `!next`, `!nextmap`.  
Each allows an additional parameter with map name, which might be simple for built-in maps (e.g. `!votenext abel` for inf_Abel, `!v eq` for ctf_Equinox, or `!next blocks` for Blox) or exact (e.g. `!votenextmap inf_Outpost2`).

You can prevent spectators from voting or being counted against total player count. The threshold can also be changed from the default 51%. See `configuration.pas` for all options.
