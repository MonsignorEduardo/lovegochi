import { swagger } from "@elysiajs/swagger";

import { Elysia, t } from "elysia";

const app = new Elysia()
	.use(swagger())
	.post(
		"/api/v1/location",

		async ({ body: { lat, lng } }) => {
			const location = await prisma.location.create({
				data: {
					latitude: lat,
					longitude: lng,
				},
			});
			console.log(location);
		},
		{
			body: t.Object({
				lat: t.Number(),
				lng: t.Number(),
			}),
		},
	)

	.listen(3000);

console.log(
	`🦊 Elysia is running at ${app.server?.hostname}:${app.server?.port}`,
);
