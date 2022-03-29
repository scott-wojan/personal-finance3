import axios from "axios";
import { PrimaryButton } from "components/buttons";
import { useRouter } from "next/router";
import React, { useCallback, useEffect, useState } from "react";
import { usePlaidLink } from "react-plaid-link";

const PlaidLink = ({ token }) => {
  const router = useRouter();
  const onSuccess = useCallback(
    async (public_token, metadata) => {
      await axios.post("/api/plaid/token_exchange", {
        public_token,
        metadata,
      });

      router.push("/");
    },
    [router]
  );

  const onExit = useCallback(async (error, metadata) => {
    // metadata contains the most recent API request ID and the
    // Link session ID. Storing this information is helpful
    // for support.
    console.log(metadata);

    if (error != null) {
      // The user encountered a Plaid API error prior to exiting.
      console.log(error);
      alert("Link Error");
    }
  }, []);

  const config = {
    token,
    onSuccess,
    onExit,
  };

  const { open, ready, error } = usePlaidLink(config);

  return (
    <>
      <PrimaryButton onClick={open} loading={!ready} disabled={!open}>
        Connect Accounts
      </PrimaryButton>
      {error}
    </>
  );
};

export default function PlaidLinkButton() {
  const [token, setToken] = useState(null);
  useEffect(() => {
    async function createLinkToken() {
      try {
        const response = await axios.get("/api/plaid/create_link_token");
        if (response.status === 200) {
          const { link_token } = await response.data;
          setToken(link_token);
          console.log("link_token", link_token);
        } else {
          alert("Error in PlaidLinkButton");
        }
      } catch (error) {
        console.log(error);
        alert(error);
      }
    }
    createLinkToken();
  }, []);
  return <PlaidLink token={token} />;
}
