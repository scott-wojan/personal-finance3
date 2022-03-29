import LinkFirstAccount from "components/accounts/LinkFirstAccount";
import { Application } from "components/app/Application";
import { getUserFromCookie } from "cookies/user";
import React from "react";

export default function Home({ user }) {
  if (!user?.has_accounts) {
    return <LinkFirstAccount />;
  }
  return <Application>Home</Application>;
}

export async function getServerSideProps(context) {
  const user = getUserFromCookie(context.req, context.res);
  return {
    props: { user },
  };
}
