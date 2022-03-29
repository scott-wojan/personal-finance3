import { getCookie, setCookies } from "cookies-next";

function getUserFromCookie(req, res) {
  const cookie = getCookie("user", { req, res });
  if (!cookie) return null;

  try {
    // @ts-ignore
    return JSON.parse(cookie).user;
  } catch (error) {
    throw new Error("Error parsing user cookie");
  }
}

function setUserCookie(req, res, user) {
  setCookies(
    "user",
    { user },
    {
      req,
      res,
      maxAge: 60 * 60 * 24,
      httpOnly: true,
      sameSite: false, //environment.isProduction,
    }
  );
}

export { getUserFromCookie, setUserCookie };
