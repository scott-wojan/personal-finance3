import { getUserFromCookie } from "cookies/user";
import { NextResponse } from "next/server";

export function middleware(req, ev) {
  if (req.url.includes("/api/auth/")) {
    return NextResponse.next();
  }

  //Check for auth cookie
  const user = getUserFromCookie(req, null);
  if (!user) {
    return new Response(null, { status: 401 });
  }

  return NextResponse.next();
}
