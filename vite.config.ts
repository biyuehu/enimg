import { spawn } from 'node:child_process'
import { defineConfig, type HmrContext } from 'vite'

function tealPlugin() {
  return {
    name: 'teal-build',
    async handleHotUpdate(ctx: HmrContext) {
      if (!ctx.file.endsWith('.tl')) return
      await new Promise((resolve, reject) =>
        spawn('cyan', ['build'], { stdio: 'inherit', shell: true }).on('exit', (code) =>
          code === 0 ? resolve(null) : reject()
        )
      )
      ctx.server.ws.send({ type: 'full-reload' })
    }
  }
}

export default defineConfig({
  plugins: [tealPlugin()],
  optimizeDeps: {
    include: ['gifwrap']
  }
})
