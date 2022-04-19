import { Button, Tooltip } from "@mantine/core";
import axios from "axios";
import { useApi } from "hooks/useApi";
import { useRouter } from "next/router";
import React, { useCallback, useEffect, useState } from "react";
import { usePlaidLink } from "react-plaid-link";
import { AlertCircle } from "tabler-icons-react";
import { environment } from "appconfig";

const PlaidLink = ({ text, linkToken, redirectRoute = "/" }) => {
  const router = useRouter();
  const onSuccess = useCallback(
    async (public_token, metadata) => {
      await axios.post("/api/plaid/public_token_exchange", {
        public_token,
        metadata,
      });

      router.push(redirectRoute);
    },
    [redirectRoute, router]
  );

  const onExit = useCallback(async (error, metadata) => {
    // metadata contains the most recent API request ID and the
    // Link session ID. Storing this information is helpful
    // for support.
    // console.log(metadata);

    if (error != null) {
      // The user encountered a Plaid API error prior to exiting.
      console.error(error);
    }
  }, []);

  const config = {
    token: linkToken,
    onSuccess,
    onExit,
  };
  const { open, ready, error } = usePlaidLink(config);

  return (
    <>
      <Button
        // @ts-ignore
        onClick={open}
        loading={!ready}
        disabled={!open}
      >
        {text}
      </Button>
      {error}
    </>
  );
};

export default function PlaidLinkButton({
  text = "Connect Accounts",
  redirectRoute = undefined,
}) {
  const [linkToken, setLinkToken] = useState(null);

  const { error, data } = useApi({
    url: "plaid/create_link_token",
  });

  useEffect(() => {
    if (data) {
      const { link_token } = data;
      setLinkToken(link_token);
    }
  }, [data]);

  if (error) {
    return (
      <>
        <Tooltip
          withArrow
          width={320}
          color="red"
          wrapLines
          position="bottom"
          label={
            !environment.isDevelopment
              ? "There was an error connecting with our partner"
              : JSON.stringify(error)
          }
        >
          <Button
            color="red"
            leftIcon={<AlertCircle size={18} strokeWidth={2} />}
          >
            Error!
          </Button>
        </Tooltip>
      </>
    );
  }

  return (
    <PlaidLink
      redirectRoute={redirectRoute}
      text={text}
      linkToken={linkToken}
    />
  );
}
