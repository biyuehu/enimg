import * as lua from 'lua-in-js'
import enimgCode from '../../build/enimg.lua?raw'
import mainCode from '../../build/main.lua?raw'
import lib from './lib'

const env = lua.createEnv()
lib.loadAll(env)
env.loadLib('enimg', env.parse(enimgCode).exec() as lua.Table)
try {
  env.parse(mainCode).exec()
} catch (error) {
  console.error('Error executing teal code:', error)
}
