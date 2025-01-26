import { BunSqliteKeyValue } from "bun-sqlite-key-value";

const store = new BunSqliteKeyValue();

type Location = {
	latitude: number;
	longitude: number;
};

const locationKey = (userId: string) => `location:${userId}`;

export const getLocationUser = (userId: string) =>
	store.get<Location>(locationKey(userId));

export const setLocationUser = (userId: string, location: Location) =>
	store.set(locationKey(userId), location);
