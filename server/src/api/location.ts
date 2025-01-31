import Elysia, { error, t } from "elysia";
import { getDistance } from "geolib";

import consola from "consola";
import { type Location, getLocationUser, setLocationUser } from "../db";

const getMinDistance = (location1: Location, location2: Location) => {
	const distance = getDistance(
		{ latitude: location1.latitude, longitude: location1.longitude },
		{ latitude: location2.latitude, longitude: location2.longitude },
	);

	return distance;
};

export const location = new Elysia({ name: "location", prefix: "/api" })
	.post(
		"/location",
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
		"/location",
		async ({ query: { user1, user2 } }) => {
			const location1 = getLocationUser(user1);
			const location2 = getLocationUser(user2);

			if (!location1 || !location2) {
				throw error(404, "Location not found :(");
			}

			const distance = getMinDistance(location1, location2);

			return { distance };
		},
		{
			query: t.Object({
				user1: t.String(),
				user2: t.String(),
			}),
		},
	)

	.ws("/location/ws", {
		query: t.Object({
			user1: t.String(),
			user2: t.String(),
		}),
		message(ws, { message }) {
			// Get schema from `ws.data`
			const { user1, user2 } = ws.data.query;

			const location1 = getLocationUser(user1);
			const location2 = getLocationUser(user2);

			if (!location1 || !location2) {
				ws.send({ error: "Location not found :(" });
				return;
			}

			const distance = getMinDistance(location1, location2);

			ws.send({ distance });
		},
	});
