import { swagger } from "@elysiajs/swagger";
import consola from "consola";
import { Elysia, t } from "elysia";
import { location } from "./api/location";
import bearer from "./lib/bearer";
import logger from "./lib/logger";
const app = new Elysia()
	.use(bearer())
	.use(logger())
	.guard(
		{
			beforeHandle({ bearer, error }) {
				if (!bearer || bearer !== process.env.SECRET_TOKEN) {
					throw error(401, "Unauthorized");
				}
			},
		},
		(app) => app.use(location),
	)
	.get(
		"/status",
		async (request) => {
			return { status: "ok" };
		},
		{ detail: { tags: ["Status"] }, security: [] },
	)
	.use(
		swagger({
			documentation: {
				components: {
					securitySchemes: {
						bearerAuth: {
							type: "http",
							scheme: "bearer",
						},
					},
				},
			},
		}),
	)

	.listen(3000);
