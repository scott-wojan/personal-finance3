import { List, Modal, Paper, ThemeIcon, Title } from "@mantine/core";
import { PrimaryButton } from "components/buttons";
import PlaidLinkButton from "components/plaid/PlaidLink";
import React from "react";
import { Check } from "tabler-icons-react";

export default function LinkFirstAccount({}) {
  return (
    <Modal
      size={700}
      style={{}}
      centered={true}
      withCloseButton={false}
      closeOnEscape={false}
      opened={true}
      onClose={() => {}}
    >
      <Paper shadow="xs" p="lg" style={{ boxShadow: "none" }}>
        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          <Title order={3}>Let's connect your first account!</Title>
          <List
            style={{ paddingLeft: 12, paddingRight: 12 }}
            spacing="xs"
            size="sm"
            center
            icon={
              <ThemeIcon size={18} radius="xl">
                <Check size={16} />
              </ThemeIcon>
            }
          >
            <List.Item>Connecting your accounts is safe and easy</List.Item>
            <List.Item>
              The more accounts you connect, the better financial picture you'll
              have
            </List.Item>
            <List.Item>All communications are encypted and secure</List.Item>
            <List.Item>Vestibulum auctor dapibus neque</List.Item>
          </List>
          <div style={{ display: "flex", justifyContent: "flex-end" }}>
            <PlaidLinkButton />
          </div>
        </div>
      </Paper>
    </Modal>
  );
}
