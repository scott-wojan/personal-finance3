import axios from "axios";
import { useApi } from "hooks/useApi";
import router from "next/router";
import React, { useEffect, useRef, useState } from "react";

export default function Index() {
  const [email, setEmail] = useState(null);

  const login = async () => {
    const response = await axios.post("/api/signin", { email: email });
    const { status, data: user } = response;
    if (user && status === 200) {
      router.push("/home");
      return;
    }
    if (!user) alert("User not found");
  };
  const create = async () => {
    const response = await axios.post("/api/signup", { email: email });
    const { status, data: user } = response;
    if (user && status === 200) {
      router.push("/home");
      return;
    }
    if (!user) alert("User create failed");
  };

  return (
    <>
      <h4>Existing</h4>
      <select
        onChange={(e) => {
          setEmail(e.target.value);
        }}
      >
        <option></option>
        <option value="austinpowers@shag.com">Austin Powers</option>
        <option value="test@test.com">Me</option>
      </select>
      <button onClick={login}>Login</button>
      <h4>Create</h4>
      <input
        type="text"
        onChange={(e) => {
          setEmail(e.target.value);
        }}
      />
      <button onClick={create}>Create User</button>
    </>
  );
}
