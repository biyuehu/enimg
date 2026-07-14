import { decode, encode } from '@jsquash/png'
import * as lua from 'lua-in-js'

const utilsObject = {
  gcd: (a: number, b: number): number => (b === 0 ? a : utilsObject.gcd(b, a % b)),
  icon: '🖼️',
  set_loading: (v: boolean) => {
    const loading = document.querySelector('#loading')
    if (v) {
      loading?.classList.remove('hidden')
    } else {
      loading?.classList.add('hidden')
    }
  }
}

const utilsLib = new lua.Table(utilsObject)

const asyncLib = new lua.Table({
  next: <T, R>(promise: Promise<T>, callback: (data: T) => R) => promise.then((x) => callback(x)),
  catch: <R>(promise: Promise<unknown>, callback: (error: Error) => R) => promise.catch(callback),
  finally: <R>(promise: Promise<unknown>, callback: () => R) => promise.finally(callback)
})

const limpLib = new lua.Table({
  create: (size: lua.Table): ImageData => {
    const w = Number(size.get('x'))
    const h = Number(size.get('y'))
    return {
      width: w,
      height: h,
      data: new Uint8ClampedArray(w * h * 4),
      colorSpace: 'srgb'
    }
  },
  read: async (target: ArrayBuffer) => {
    const img = await decode(target)
    return {
      width: img.width,
      height: img.height,
      buffer: img.data.buffer,
      data: new Uint8Array(img.data)
    }
  },
  write: (image: ImageData) =>
    encode({ width: image.width, height: image.height, data: image.data, colorSpace: 'srgb' }),
  get_size: (image: ImageData) => new lua.Table({ x: image.width, y: image.height }),
  get_pixel: (image: ImageData, index: number) => image.data[index],
  set_pixel: (image: ImageData, index: number, value: number) => (image.data[index] = value)
})

const webLib = new lua.Table({
  console: (...msg: unknown[]) => console.log(...msg),
  query: (selector: string) => document.querySelector(selector),
  create: (tag: string) => document.createElement(tag),
  body: () => document.body,
  append: (parent: Element, child: Element) => parent.appendChild(child),
  remove: (parent: Element, child: Element) => parent.removeChild(child),
  get_text: (element: Element) => element.textContent ?? '',
  set_text: (element: Element, text: string) => (element.textContent = text),
  get_html: (element: Element) => element.innerHTML,
  set_html: (element: Element, html: string) => (element.innerHTML = html),
  get_attr: (element: Element, name: string) => element.getAttribute(name),
  set_attr: (element: Element, name: string, value: string) => element.setAttribute(name, value),
  get_style: (element: HTMLElement, name: string) => element.style.getPropertyValue(name),
  set_style: (element: HTMLElement, name: string, value: string) => element.style.setProperty(name, value),
  get_value: (element: HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement) => element.value,
  set_value: (element: HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement, value: string) =>
    (element.value = value),
  get_prop: (element: object, name: string | number) => element[name as keyof typeof element],
  set_prop: (element: object, name: string | number, value: object) =>
    ((element[name as keyof typeof element] as object) = value),
  on: (element: Element, event: string, listener: (event: Event) => void) => element.addEventListener(event, listener),
  off: (element: Element, event: string, listener: (event: Event) => void) =>
    element.removeEventListener(event, listener),
  once: (element: Element, event: string, listener: (event: Event) => void) =>
    element.addEventListener(event, listener, { once: true }),
  revoke_object_url: (url: string) => URL.revokeObjectURL(url),
  create_object_url: (blob: Blob) => URL.createObjectURL(blob),
  new_blob: (blobPart: BlobPart) => new Blob([blobPart]),
  set_timeout: (callback: () => void, delay: number) => setTimeout(callback, delay),
  array_buffer: (blob: Blob) => blob.arrayBuffer(),
  click: (element: Element & { click: () => void }) => element.click()
})

export default {
  utils: utilsLib,
  async: asyncLib,
  limp: limpLib,
  web: webLib,
  loadAll: (env: ReturnType<(typeof lua)['createEnv']>) => {
    env.loadLib('utils', utilsLib)
    env.loadLib('async', asyncLib)
    env.loadLib('limp', limpLib)
    env.loadLib('web', webLib)
  }
}
