import Script from "next/script";
import React from "react";

export default function Poop() {
  return (
    <div>
      <Script src="https://connect2.finicity.com/assets/sdk/finicity-connect.min.js" />
    </div>
  );
}
