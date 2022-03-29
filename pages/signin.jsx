import {
  Center,
  Checkbox,
  Grid,
  Modal,
  PasswordInput,
  Select,
  TextInput,
  Title,
} from "@mantine/core";
import { ShieldLock, At } from "tabler-icons-react";
import React, { useState } from "react";
import { PrimaryButton } from "components/buttons";
import axios from "axios";
import router from "next/router";

export default function Login() {
  const [email, setEmail] = useState(null);
  const login = async () => {
    const response = await axios.post("/api/auth/login", { email: email });
    const { status, data: user } = response;
    if (user && status === 200) {
      router.push("/home");
      return;
    }
    if (!user) alert("User not found");
  };

  return (
    <>
      <Modal
        size={700}
        style={{}}
        centered={true}
        withCloseButton={false}
        closeOnEscape={false}
        opened={true}
        onClose={() => {}}
      >
        <Grid style={{}}>
          <Grid.Col md={12} lg={6} style={{}}>
            <Center style={{ height: "100%" }}>
              <div>img</div>
            </Center>
          </Grid.Col>
          <Grid.Col md={12} lg={6} style={{}}>
            <Center style={{ height: "100%" }}>
              <div
                style={{
                  paddingTop: 60,
                  paddingBottom: 60,
                  marginRight: 14,
                  width: "100%",
                }}
              >
                <Title order={1} style={{ paddingBottom: 8 }}>
                  Sign In
                </Title>
                <form
                  style={{ display: "flex", flexDirection: "column", gap: 12 }}
                >
                  <Select
                    style={{}}
                    label="Email to log in with"
                    placeholder="Select User"
                    onChange={setEmail}
                    data={[
                      { value: "test@test.com", label: "user with accounts" },
                      { value: "asd@asd.com", label: "user without accounts" },
                      {
                        value: "austinpowers@shag.com",
                        label: "Austin Powers",
                      },
                    ]}
                    value={email}
                  />
                  <TextInput
                    disabled={true}
                    placeholder="your email"
                    required
                    icon={<At size={16} strokeWidth={1} />}
                  />
                  <PasswordInput
                    disabled={true}
                    placeholder="your password"
                    icon={<ShieldLock size={16} strokeWidth={1} />}
                    required
                  />
                  <Checkbox label="Remember Me" />
                  <PrimaryButton disabled={!email} onClick={login}>
                    Sign In
                  </PrimaryButton>
                </form>
              </div>
            </Center>
          </Grid.Col>
        </Grid>
      </Modal>
    </>
  );
}

// <Grid style={{ height: "100vh", maxWidth: "100%" }}>
// <Grid.Col md={12} lg={6} style={{}}>
//   <Center style={{ height: "100vh", backgroundColor: "red" }}>
//     <div>All elements inside Center are centered</div>
//   </Center>
// </Grid.Col>
// <Grid.Col md={12} lg={6} style={{}}>
//   <Center style={{ height: "100vh", backgroundColor: "blue" }}>
//     <div>All elements inside Center are centered</div>
//   </Center>
// </Grid.Col>
// </Grid>
