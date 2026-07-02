import { readFileSync, writeFileSync } from 'node:fs'
import * as lua from 'lua-in-js'

const fsLib = new lua.Table({
  read_file: (path: string) => Buffer.from(readFileSync(path).buffer),
  write_file: (path: string, data: Buffer) => writeFileSync(path, data),
  read_file_to_string: (path: string) => readFileSync(path, 'utf8'),
  write_file_from_string: (path: string, data: string) => writeFileSync(path, data)
})

const processLib = new lua.Table({
  argv: new lua.Table(process.argv.slice(2)),
  exit: (code: number) => process.exit(code)
})

export default {
  fs: fsLib,
  process: processLib,
  loadAll: (env: ReturnType<(typeof lua)['createEnv']>) => {
    env.loadLib('fs', fsLib)
    env.loadLib('process', processLib)
    return env
  }
}
