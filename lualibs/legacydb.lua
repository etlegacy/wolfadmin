--[[
	Author: [ET:Legacy Team]
	License: GPLv3
	Website: http://www.etlegacy.com
	Mod: compatible with Legacy mod only
	Description: WolfAdmin 'plug and play' integration
]]--

local function createDb()
    -- FIXME: Do bulk insert

    cur = assert(con:execute[[
        CREATE TABLE IF NOT EXISTS `config` (
            `id` TEXT NOT NULL PRIMARY KEY,
            `value` TEXT NOT NULL
        );
    ]])
    cur = assert(con:execute[[
        CREATE TABLE IF NOT EXISTS `level` (
            `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            `name` TEXT NOT NULL
        );
    ]])
    cur = assert(con:execute[[
        CREATE TABLE IF NOT EXISTS `level_permission` (
            `level_id` INTEGER NOT NULL,
            `permission` TEXT NOT NULL,
            PRIMARY KEY (`level_id`, `permission`),
            CONSTRAINT `level_permission_level` FOREIGN KEY (`level_id`) REFERENCES `level` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
        );
    ]])
    cur = assert(con:execute[[
        CREATE TABLE IF NOT EXISTS `player` (
            `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            `guid` TEXT NOT NULL UNIQUE,
            `ip` TEXT NOT NULL,
            `level_id` INTEGER NOT NULL,
            `lastseen` INTEGER NOT NULL,
            `seen` INTEGER NOT NULL,
            CONSTRAINT `player_level` FOREIGN KEY (`level_id`) REFERENCES `level` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
        );
    ]])
    cur = assert(con:execute[[
        CREATE TABLE IF NOT EXISTS `player_permission` (
            `player_id` INTEGER NOT NULL,
            `permission` TEXT NOT NULL,
            PRIMARY KEY (`player_id`, `permission`),
            CONSTRAINT `player_permission_player` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
        );
    ]])
    cur = assert(con:execute[[
        CREATE TABLE IF NOT EXISTS `alias` (
            `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            `player_id` INTEGER NOT NULL,
            `alias` TEXT NOT NULL,
            `cleanalias` TEXT NOT NULL,
            `lastused` INTEGER NOT NULL,
            `used` INTEGER NOT NULL,
            CONSTRAINT `alias_player` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
        );
    ]])
    cur = assert(con:execute[[
        CREATE INDEX IF NOT EXISTS `alias_player_idx` ON `alias` (`player_id`);
    ]])
    cur = assert(con:execute[[
        CREATE TABLE IF NOT EXISTS `history` (
            `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            `victim_id` INTEGER NOT NULL,
            `invoker_id` INTEGER NOT NULL,
            `type` TEXT NOT NULL,
            `datetime` INTEGER NOT NULL,
            `reason` TEXT NOT NULL,
            CONSTRAINT `history_victim` FOREIGN KEY (`victim_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
            CONSTRAINT `history_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
        );
    ]])
    cur = assert(con:execute[[
        CREATE INDEX IF NOT EXISTS `history_victim_idx` ON `history` (`victim_id`);
    ]])
    cur = assert(con:execute[[
        CREATE INDEX IF NOT EXISTS `history_invoker_idx` ON `history` (`invoker_id`);
    ]])
    cur = assert(con:execute[[
        CREATE TABLE IF NOT EXISTS `mute` (
            `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            `victim_id` INTEGER NOT NULL,
            `invoker_id` INTEGER NOT NULL,
            `type` TEXT NOT NULL,
            `issued` INTEGER NOT NULL,
            `expires` INTEGER NOT NULL,
            `duration` INTEGER NOT NULL,
            `reason` TEXT NOT NULL,
            CONSTRAINT `mute_victim` FOREIGN KEY (`victim_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
            CONSTRAINT `mute_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
        );
    ]])
    cur = assert(con:execute[[
        CREATE INDEX IF NOT EXISTS `mute_victim_idx` ON `mute` (`victim_id`);
    ]])
    cur = assert(con:execute[[
        CREATE INDEX IF NOT EXISTS `mute_invoker_idx` ON `mute` (`invoker_id`);
    ]])
    cur = assert(con:execute[[
        CREATE TABLE IF NOT EXISTS `ban` (
            `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            `victim_id` INTEGER NOT NULL,
            `invoker_id` INTEGER NOT NULL,
            `issued` INTEGER NOT NULL,
            `expires` INTEGER NOT NULL,
            `duration` INTEGER NOT NULL,
            `reason` TEXT NOT NULL,
            CONSTRAINT `ban_victim` FOREIGN KEY (`victim_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
            CONSTRAINT `ban_invoker` FOREIGN KEY (`invoker_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
        );
    ]])
    cur = assert(con:execute[[
        CREATE INDEX IF NOT EXISTS `ban_victim_idx` ON `ban` (`victim_id`);
    ]])
    cur = assert(con:execute[[
        CREATE INDEX IF NOT EXISTS `ban_invoker_idx` ON `ban` (`invoker_id`);
    ]])
    cur = assert(con:execute[[
        CREATE TABLE IF NOT EXISTS `map` (
            `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            `name` TEXT NOT NULL,
            `lastplayed` INTEGER NOT NULL
        );
    ]])
    cur = assert(con:execute[[
        CREATE TABLE IF NOT EXISTS `record` (
            `map_id` INTEGER NOT NULL,
            `type` INTEGER NOT NULL,
            `date` INTEGER NOT NULL,
            `record` INTEGER NOT NULL,
            `player_id` INTEGER NOT NULL,
            PRIMARY KEY (`map_id`, `type`),
            CONSTRAINT `record_map` FOREIGN KEY (`map_id`) REFERENCES `map` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
            CONSTRAINT `record_player` FOREIGN KEY (`player_id`) REFERENCES `player` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
        );
    ]])
    cur = assert(con:execute[[
        CREATE INDEX IF NOT EXISTS `record_player_idx` ON `record` (`player_id`);
    ]])
    -- cur:close()
end

local function populateDb()

    -- FIXME: Do bulk insert
    -- cur = assert(con:setautocommit(true))
    -- cur = assert(con:commit(true, "IMMEDIATE"))
    -- cur = assert(con:execute[[
    --     BEGIN;
    --     ...
    --     COMMIT;
    -- ]])

    -- insert database version in config
    cur = assert(con:execute[[INSERT INTO `config` (`id`, `value`) VALUES ('schema_version', '1.2.0');]])

    -- add levels
    cur = assert(con:execute[[INSERT INTO `level` (`id`, `name`) VALUES (0, 'Guest');]])
    cur = assert(con:execute[[INSERT INTO `level` (`id`, `name`) VALUES (1, 'Regular');]])
    cur = assert(con:execute[[INSERT INTO `level` (`id`, `name`) VALUES (2, 'VIP');]])
    cur = assert(con:execute[[INSERT INTO `level` (`id`, `name`) VALUES (3, 'Admin');]])
    cur = assert(con:execute[[INSERT INTO `level` (`id`, `name`) VALUES (4, 'Senior Admin');]])
    cur = assert(con:execute[[INSERT INTO `level` (`id`, `name`) VALUES (5, 'Server Owner');]])

     -- add permissions for level 0
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (0, 'admintest');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (0, 'help');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (0, 'time');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (0, 'greeting');]])

     -- add permissions for level 1
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (1, 'admintest');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (1, 'help');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (1, 'time');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (1, 'greeting');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (1, 'listmaps');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (1, 'listsprees');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (1, 'listrules');]])

     -- add permissions for level 2
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'admintest');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'help');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'time');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'greeting');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'listplayers');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'listteams');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'listmaps');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'listsprees');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'listrules');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (2, 'spec999');]])

     -- add permissions for level 3
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'admintest');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'help');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'time');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'greeting');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'listplayers');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'listteams');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'listmaps');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'listsprees');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'listrules');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'listhistory');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'listbans');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'liststats');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'adminchat');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'put');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'dropweapons');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'warn');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'mute');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'voicemute');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'spec999');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'balance');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'cointoss');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'pause');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'nextmap');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'restart');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'botadmin');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'enablevote');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'noinactivity');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'novote');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'nocensor');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (3, 'novotelimit');]])

     -- add permissions for level 4
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'admintest');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'help');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'time');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'greeting');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listplayers');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listteams');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listmaps');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listsprees');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listrules');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listhistory');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listwarns');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listbans');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'listaliases');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'liststats');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'finger');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'adminchat');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'put');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'dropweapons');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'rename');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'freeze');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'disorient');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'burn');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'slap');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'gib');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'throw');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'glow');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'pants');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'pop');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'warn');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'mute');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'voicemute');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'kick');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'ban');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'spec999');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'balance');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'lockplayers');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'lockteam');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'shuffle');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'swap');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'cointoss');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'pause');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'nextmap');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'restart');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'botadmin');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'enablevote');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'cancelvote');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'passvote');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'news');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'noinactivity');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'novote');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'nocensor');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'nobalance');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'novotelimit');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'noreason');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'teamcmds');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (4, 'silentcmds');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'admintest');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'help');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'time');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'greeting');]])

     -- add permissions for level 5
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listplayers');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listteams');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listmaps');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listsprees');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listrules');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listhistory');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listwarns');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listbans');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'listaliases');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'liststats');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'finger');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'adminchat');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'put');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'dropweapons');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'rename');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'freeze');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'disorient');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'burn');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'slap');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'gib');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'throw');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'glow');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'pants');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'pop');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'warn');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'mute');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'voicemute');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'kick');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'ban');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'spec999');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'balance');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'lockplayers');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'lockteam');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'shuffle');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'swap');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'cointoss');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'pause');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'nextmap');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'restart');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'botadmin');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'enablevote');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'cancelvote');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'passvote');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'news');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'uptime');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'setlevel');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'readconfig');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'noinactivity');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'novote');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'nocensor');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'nobalance');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'novotelimit');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'noreason');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'perma');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'teamcmds');]])
    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'silentcmds');]])

    cur = assert(con:execute[[INSERT INTO `level_permission`(`level_id`, `permission`) VALUES (5, 'spy');]])

    -- add console to players table
    cur = assert(con:execute[[INSERT INTO `player` (`id`, `guid`, `ip`, `level_id`, `lastseen`, `seen`) VALUES (1, 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', '127.0.0.1', 5, 0, 0);]])
    cur = assert(con:execute[[INSERT INTO `alias` (`id`, `player_id`, `alias`, `cleanalias`, `lastused`, `used`) VALUES (1, 1, 'console', 'console', 0, 0);]])

    -- cur:close()
end

-- load sqlite driver
local luasql = require "luasql.sqlite3"

-- database path
local settings = require "luascripts.wolfadmin.util.settings"
local dbpath = wolfa_getHomePath()..settings.get("db_file")

-- check if database exists
local file=io.open(dbpath,"r")
if file~=nil then io.close(file)
    return
else
    outputDebug("^3[Legacy] Initial database not found...")
end

-- create environement object
env = assert(luasql.sqlite3())

-- connect to database
con = assert(env:connect(dbpath))

-- create database
outputDebug("^3[Legacy] Creating database...")
createDb()

-- populate database
outputDebug("^3[Legacy] Populating database... this will take a few seconds")
populateDb()
