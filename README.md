# !vote script for Soldat server

Allows players to start a vote for either:

* the next map - `!vote`
* any specific map - `!vote ash`, `!vote equi`, `!vote ctf_Nimble`

When a vote is started, its target map is locked and cannot be changed for its duration. A vote lasts one minute by default, with any subsequent votes increasing the time by 10 seconds.

You can prevent spectators from voting, so they won't be counted towards player count in percentage calculations. Bots are never counted, for machines have no free will yet. The threshold can also be changed from the default 51%. See `configuration.pas` for all options.

Aliases: `!v`, `!vot`, `!vote`, `!votemap`, `!votenext`, `!votenextmap`, `!next`, `!nextmap`.
