import React from "react";
import { Text } from "@mantine/core";
import { MoodSad } from "tabler-icons-react";

export default function NoResults() {
  return (
    <>
      <div>
        <Text size="xl" weight={700}>
          Oh No
        </Text>
      </div>
      <MoodSad size={48} strokeWidth={1} color={"gray"} />
      <div>No results were found</div>
    </>
  );
}
