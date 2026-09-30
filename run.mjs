// Runs schema.sql then seed.sql against the database in DATABASE_URL.
// Usage:
//   npm install pg
//   DATABASE_URL="postgresql://user:pass@host/db?sslmode=disable" node run.mjs

import { readFileSync } from "node:fs";
import pg from "pg";

const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
  console.error("Set DATABASE_URL before running this script.");
  process.exit(1);
}

const client = new pg.Client({ connectionString });

async function main() {
  await client.connect();
  console.log("Connected. Applying schema.sql...");
  await client.query(readFileSync(new URL("./schema.sql", import.meta.url), "utf8"));
  console.log("Schema applied. Applying seed.sql...");
  await client.query(readFileSync(new URL("./seed.sql", import.meta.url), "utf8"));
  console.log("Seed data inserted. Done.");
  await client.end();
}

main().catch(async (err) => {
  console.error("Failed:", err.message);
  await client.end();
  process.exit(1);
});
