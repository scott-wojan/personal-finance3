import LinkFirstAccount from "components/accounts/LinkFirstAccount";
import Dashboard from "components/dashboard";
import Onboarding from "components/onboarding";
import { getUserFromCookie, removeUserCookie } from "cookies/user";
import React from "react";

export default function Index({ user }) {
  // return <Onboarding />;

  // if (!user?.has_accounts) {
  //   return <LinkFirstAccount />;
  // }

  return <Dashboard user={user} />;
}

export async function getServerSideProps(context) {
  const { req, res } = context;
  const user = getUserFromCookie(req, res);
  console.log(user);
  if (!user) {
    return {
      redirect: {
        destination: "/signin",
        permanent: false,
      },
    };
  }

  return {
    props: { user },
  };
}
