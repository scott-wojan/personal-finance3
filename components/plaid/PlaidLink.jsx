import { Button, Tooltip } from "@mantine/core";
import axios from "axios";
import { useApi } from "hooks/useApi";
import { useRouter } from "next/router";
import React, { useCallback, useEffect, useState } from "react";
import { usePlaidLink } from "react-plaid-link";
import { AlertCircle } from "tabler-icons-react";
import { environment } from "appconfig";

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
      <Button
        // @ts-ignore
        onClick={open}
        loading={!ready}
        disabled={!open}
      >
        Connect Accounts
      </Button>
      {error}
    </>
  );
};

export default function PlaidLinkButton() {
  const [token, setToken] = useState(null);

  const { isLoading, error, data } = useApi({
    url: "plaid/create_link_token",
  });

  useEffect(() => {
    const { link_token } = data;
    setToken(link_token);
    console.log("data", data);
  }, [data]);

  // useEffect(() => {
  //   async function createLinkToken() {
  //     try {
  //       const response = await axios.get("/api/plaid/create_link_token");
  //       if (response.status === 200) {
  //         const { link_token } = await response.data;
  //         setToken(link_token);
  //       } else {
  //         alert("Error in PlaidLinkButton");
  //       }
  //     } catch (error) {
  //       alert(error);
  //     }
  //   }
  //   createLinkToken();
  // }, []);

  if (error) {
    return (
      <>
        <Tooltip
          width={320}
          color="red"
          wrapLines
          position="bottom"
          label={
            !environment.isDevelopment
              ? "There was an error connecting with our partner"
              : JSON.stringify(error)
          }
          withArrow
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

  return <PlaidLink token={token} />;
}
