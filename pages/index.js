import LinkFirstAccount from "components/accounts/LinkFirstAccount";
import { getUserFromCookie, removeUserCookie } from "cookies/user";
import React from "react";
import { Dashboard } from "tabler-icons-react";

export default function Index({ user }) {
  if (!user?.has_accounts) {
    return <LinkFirstAccount />;
  }

  return <div>xxxx</div>;
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
