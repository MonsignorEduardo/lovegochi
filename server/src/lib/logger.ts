import consola, { createConsola } from "consola";
import { Elysia, StatusMap } from "elysia";

const ELYSIA_VERSION = import.meta.require("elysia/package.json").version;

export function getStatusCode(status: string | number): number {
	if (typeof status === "number") return status;
	return (StatusMap as Record<string, number>)[status] || 500;
}

export default function logger() {
	return new Elysia({
		name: "Logger",
	})
		.state({ beforeTime: BigInt(0) })
		.onStart((ctx) => {
			consola.box(
				`  Elysia v${ELYSIA_VERSION}  \n  🦊 Starting server on port ${ctx.server?.port}  `,
			);
		})
		.onRequest((ctx) => {
			ctx.store.beforeTime = process.hrtime.bigint();
		})
		.onAfterHandle({ as: "global" }, ({ request, set, store }) => {
			const time = process.hrtime.bigint() - store.beforeTime;
			const status = getStatusCode(set.status || 200);

			consola.success(
				`${request.method} ${request.url} - ${status} - ${time / BigInt(1e6)}ms`,
			);
		})
		.onError({ as: "global" }, ({ request, error, set, store }) => {
			const time = process.hrtime.bigint() - store.beforeTime;
			const status = getStatusCode(set.status || 500);
			consola.error(
				`${request.method} ${request.url} - ${status} - ${time / BigInt(1e6)}ms`,
			);
		});
}
