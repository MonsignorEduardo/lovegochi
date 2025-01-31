import { swagger } from "@elysiajs/swagger";
import { consola, createConsola } from "consola";
import { Elysia, t } from "elysia";
import { location } from "./api/location";

const app = new Elysia().use(swagger()).use(location).listen(3000);

consola.start(
	`🦊 Elysia is running at ${app.server?.hostname}:${app.server?.port}`,
);
