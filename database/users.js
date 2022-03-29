import sql from "./db.js";

async function getUserByEmail(email) {
  // @ts-ignore
  const rows = await sql`
  select u.id, u.email,
         exists(select 1 from accounts where user_id = u.id) as has_accounts
    from users u
    where u.email = ${email}
  `;
  return rows[0];
}

async function createUser(email) {
  // @ts-ignore
  const rows = await sql`
    INSERT INTO users (email) VALUES (${email}) ON CONFLICT DO NOTHING RETURNING * ;
  `;
  return rows[0];
}

export { getUserByEmail, createUser };
