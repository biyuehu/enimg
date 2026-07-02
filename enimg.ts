import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import * as lua from 'lua-in-js'
import lib from './src/ts/lib'
import serverLib from './src/ts/server-lib'

const env = lua.createEnv()
lib.loadAll(env)
serverLib.loadAll(env)
env.loadLib('enimg', env.parse(readFileSync(join(__dirname, 'build/enimg.lua'), 'utf-8')).exec() as lua.Table)
env.parse(readFileSync(join(__dirname, 'build/bin.lua'), 'utf-8')).exec()
