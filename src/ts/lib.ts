import * as J from 'jimp'
import * as lua from 'lua-in-js'

const { Jimp } = J

const utilsObject = {
  gcd: (a: number, b: number): number => (b === 0 ? a : utilsObject.gcd(b, a % b))
}

const utilsLib = new lua.Table(utilsObject)

const asyncLib = new lua.Table({
  next: <T, R>(promise: Promise<T>, callback: (data: T) => R) => promise.then((x) => callback(x)),
  catch: <R>(promise: Promise<unknown>, callback: (error: Error) => R) => promise.catch(callback),
  finally: <R>(promise: Promise<unknown>, callback: () => R) => promise.finally(callback)
  /* 	solve: <T, R1, R2, R3>(
    promise: Promise<T>,
    handler: {
      next?: (data: T) => R1;
      catch?: (e: Error) => R2;
      finally?: () => R3;
    },
  ) => promise.then(handler.next).catch(handler.catch).finally(handler.finally), */
})

const limpLib = new lua.Table({
  create: (size: lua.Table) =>
    new Jimp({
      width: Number(size.get('x')),
      height: Number(size.get('y'))
    }),
  read: (target: ArrayBuffer | Buffer<ArrayBufferLike>) => Jimp.read(target),
  get_size: (image: InstanceType<typeof Jimp>) => new lua.Table({ x: image.bitmap.width, y: image.bitmap.height }),
  get_pixel: (image: InstanceType<typeof Jimp>, index: number) => image.bitmap.data[index],
  set_pixel: (image: InstanceType<typeof Jimp>, index: number, value: number) => (image.bitmap.data[index] = value),
  get_buffer: (image: InstanceType<typeof Jimp>, mime: Parameters<InstanceType<typeof Jimp>['getBuffer']>[0]) =>
    image.getBuffer(mime)
})

const domLib = new lua.Table({
  query: (selector: string) => document.querySelector(selector),
  create: (tag: string) => document.createElement(tag),
  body: () => document.body,
  append: (parent: Element, child: Element) => parent.appendChild(child),
  remove: (element: Element) => element.remove(),
  text: (element: Element) => element.textContent ?? '',
  set_text: (element: Element, text: string) => (element.textContent = text),
  html: (element: Element) => element.innerHTML,
  set_html: (element: Element, html: string) => (element.innerHTML = html),
  attr: (element: Element, name: string) => element.getAttribute(name),
  set_attr: (element: Element, name: string, value: string) => element.setAttribute(name, value),
  style: (element: HTMLElement, name: string) => element.style.getPropertyValue(name),
  set_style: (element: HTMLElement, name: string, value: string) => element.style.setProperty(name, value),
  value: (element: HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement) => element.value,
  set_value: (element: HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement, value: string) =>
    (element.value = value),
  on: (element: Element, event: string, listener: (event: Event) => void) => element.addEventListener(event, listener)
})

export default {
  utils: utilsLib,
  async: asyncLib,
  limp: limpLib,
  dom: domLib,
  loadAll: (env: ReturnType<(typeof lua)['createEnv']>) => {
    env.loadLib('utils', utilsLib)
    env.loadLib('async', asyncLib)
    env.loadLib('limp', limpLib)
    env.loadLib('dom', domLib)
  }
}
