import { readFileSync, writeFileSync } from "node:fs";
import { Jimp } from "jimp";
import lua from "lua-in-js";

const env = lua.createEnv();

const utilsObject = {
	gcd: (a: number, b: number): number =>
		b === 0 ? a : utilsObject.gcd(b, a % b),
};

const utilsModule = new lua.Table(utilsObject);

const asyncModule = new lua.Table({
	next: <T, R>(promise: Promise<T>, callback: (data: T) => R) =>
		promise.then((x) => callback(x)),
	catch: <R>(promise: Promise<unknown>, callback: (error: Error) => R) =>
		promise.catch(callback),
	finally: <R>(promise: Promise<unknown>, callback: () => R) =>
		promise.finally(callback),
	/* 	solve: <T, R1, R2, R3>(
		promise: Promise<T>,
		handler: {
			next?: (data: T) => R1;
			catch?: (e: Error) => R2;
			finally?: () => R3;
		},
	) => promise.then(handler.next).catch(handler.catch).finally(handler.finally), */
});

const limpModule = new lua.Table({
	create: (size: lua.Table) =>
		new Jimp({
			width: Number(size.get("x")),
			height: Number(size.get("y")),
		}),
	read: (target: ArrayBuffer | Buffer<ArrayBufferLike>) => Jimp.read(target),
	get_size: (image: InstanceType<typeof Jimp>) =>
		new lua.Table({ x: image.bitmap.width, y: image.bitmap.height }),
	get_pixel: (image: InstanceType<typeof Jimp>, index: number) =>
		image.bitmap.data[index],
	set_pixel: (image: InstanceType<typeof Jimp>, index: number, value: number) =>
		(image.bitmap.data[index] = value),
	get_buffer: (
		image: InstanceType<typeof Jimp>,
		mime: Parameters<InstanceType<typeof Jimp>["getBuffer"]>[0],
	) => image.getBuffer(mime),
});

const fsModule = new lua.Table({
	read_file: (path: string) => Buffer.from(readFileSync(path).buffer),
	write_file: (path: string, data: Buffer) => writeFileSync(path, data),
	read_file_to_string: (path: string) => readFileSync(path, "utf8"),
	write_file_from_string: (path: string, data: string) =>
		writeFileSync(path, data),
});

env.loadLib("utils", utilsModule);
env.loadLib("async", asyncModule);
env.loadLib("limp", limpModule);
env.loadLib("fs", fsModule);

try {
	console.log(
		"JS 收到返回值:",
		env.parse(readFileSync("lua_build/main.lua", "utf8")).exec(),
	);
} catch (e) {
	console.error(e);
}
