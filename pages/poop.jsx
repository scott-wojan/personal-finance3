import { Button, TextInput } from "@mantine/core";
import axios from "axios";
import Script from "next/script";
import React, { useEffect, useState } from "react";

export default function Poop() {
  const [partnerAuthToken, setPartnerAuthToken] = useState();
  const [customerId, setCustomerId] = useState("5027273800");
  useEffect(() => {
    async function getPartnerAuth() {
      // You can await here
      const res = await axios.post("/api/finicity/partner-authentication");
      setPartnerAuthToken(res.data.token);
    }
    getPartnerAuth();
  }, []);

  const launchConnect = async () => {
    const res = await axios.post("/api/finicity/generate-connect-url", {
      appToken: partnerAuthToken,
      customerId,
    });
    console.log(res.data.link);
  };

  return (
    <div>
      <Script src="https://connect2.finicity.com/assets/sdk/finicity-connect.min.js" />
      <div>
        <TextInput
          value={customerId}
          onChange={(e) => {
            setCustomerId(e.target.value);
          }}
        />
        <Button onClick={launchConnect}>Launch</Button>
      </div>
    </div>
  );
}
