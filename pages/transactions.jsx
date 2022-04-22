import { Button, Group, Modal, Table, Title } from "@mantine/core";
import { Application } from "components/app/Application";
import { RuleEditor } from "components/transactions/RuleEditor";
import TransactionsGrid from "components/transactions/TransactionsGrid";
import { useApi } from "hooks/useApi";
import React, { useEffect, useState } from "react";
import { Bolt } from "tabler-icons-react";

export default function Transactions() {
  const [opened, setOpened] = useState(false);
  return (
    <Application
      sidebar={
        <>
          Stats?
          <br />
          Behavioral Reinforcement?
          <br />
          ads?
        </>
      }
    >
      <Group position="apart" pb="md">
        <Title order={3}>Transactions</Title>
        <Button
          size="xs"
          leftIcon={<Bolt size={16} />}
          onClick={() => setOpened(true)}
        >
          Manage Rules
        </Button>
      </Group>
      <div>
        <TransactionsGrid pageSize={12} />
      </div>
      <Modal
        overflow="inside"
        centered
        opened={opened}
        onClose={() => setOpened(false)}
        title="Your transaction rules"
      >
        <Rules />
      </Modal>
    </Application>
  );
}

function Rules() {
  const [tableData, setTableDate] = useState([]);

  const { isLoading, error, data } = useApi({
    url: "rules",
  });

  useEffect(() => {
    setTableDate(
      data?.map((rule) => {
        return (
          <tr key={rule.id}>
            <td>
              <RuleEditor data={rule} mode={"display"} />
            </td>
          </tr>
        );
      })
    );
  }, [data]);

  return (
    <>
      {isLoading && <>Loading...</>}
      {error && <>Error!! {error?.message}</>}
      {data && (
        <Table>
          <tbody>{tableData}</tbody>
        </Table>
      )}
    </>
  );
}
