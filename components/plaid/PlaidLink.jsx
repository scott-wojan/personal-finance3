import { Button, Tooltip } from "@mantine/core";
import axios from "axios";
import { useApi } from "hooks/useApi";
import React, { useCallback, useEffect, useState } from "react";
import { usePlaidLink } from "react-plaid-link";
import { AlertCircle } from "tabler-icons-react";
import { environment } from "appconfig";

// https://plaid.com/docs/link/

const PlaidLink = ({ text, linkToken, onLinkSuccess, isRefresh }) => {
  //https://plaid.com/docs/link/web/#onsuccess

  const onSuccess = useCallback(
    async (public_token, metadata) => {
      if (isRefresh) {
        onLinkSuccess?.(null);
        return;
      }

      await axios.post("/api/plaid/public_token_exchange", {
        public_token,
        metadata,
      });

      onLinkSuccess?.(metadata);
    },
    [isRefresh, onLinkSuccess]
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

  const onEvent = useCallback(async (eventName, metadata) => {
    // metadata contains the most recent API request ID and the
    // Link session ID. Storing this information is helpful
    // for support.
    // console.log(metadata);

    if (eventName != null) {
      console.error(eventName, metadata);
    }
  }, []);

  const config = {
    token: linkToken,
    onSuccess,
    onExit,
    onEvent,
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
  products = undefined,
  access_token = undefined,
  text = "Connect Accounts",
  onLinkSuccess = undefined,
}) {
  const [linkToken, setLinkToken] = useState(null);

  // if (!products || products?.length === 0) {
  //   throw new Error("Must specify one or more products");
  // }

  const { error, data } = useApi({
    url: "plaid/create_link_token",
    payload: { products, access_token },
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
      onLinkSuccess={onLinkSuccess}
      text={text}
      linkToken={linkToken}
      isRefresh={access_token ? true : false}
    />
  );
}
