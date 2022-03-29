import { removeUserCookie } from "cookies/user";
import React from "react";

export default function SignOut() {
  return <></>;
}

export async function getServerSideProps(context) {
  const { req, res } = context;
  removeUserCookie(req, res);
  return {
    redirect: {
      destination: "/signin",
      permanent: false,
    },
  };
}
