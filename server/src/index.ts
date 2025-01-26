import { swagger } from "@elysiajs/swagger";
import { consola, createConsola } from "consola";
import { Elysia, t } from "elysia";
import { getDistance } from "geolib";
import { getLocationUser, setLocationUser } from "./db";
const app = new Elysia()
	.use(swagger())
	.post(
		"/api/v1/location",

		async ({ body: { name, latitude, longitude } }) => {
			setLocationUser(name, { latitude, longitude });
			consola.info(`User ${name} location set to ${latitude}, ${longitude}`);
			return { message: "Location set" };
		},

		{
			body: t.Object({
				name: t.String(),
				latitude: t.Number(),
				longitude: t.Number(),
			}),
		},
	)
	.get(
		"/api/v1/location/:user",
		async ({ params: { user1, user2 } }) => {
			const location1 = getLocationUser(user1);
			const location2 = getLocationUser(user2);

			if (!location1 || !location2) {
				return { message: "Users not found", location1, location2 };
			}

			const distance = getDistance(
				{ latitude: location1.latitude, longitude: location1.longitude },
				{ latitude: location2.latitude, longitude: location2.longitude },
			);

			return { distance };
		},
		{
			params: t.Object({
				user1: t.String(),
				user2: t.String(),
			}),
		},
	)
	.get("/api/v1/location", async () => {})

	.listen(3000);

consola.start(
	`🦊 Elysia is running at ${app.server?.hostname}:${app.server?.port}`,
);
