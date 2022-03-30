import { createStyles } from "@mantine/core";
import React from "react";

export function TransactionStatus({ value, align }) {
  const useStyles = createStyles((theme) => ({
    pending: {
      backgroundColor: theme.colors.yellow[4],
      color: theme.colors.gray[9],
      borderRadius: 20,
      padding: "3px 8px 3px 8px",
    },
    container: {
      textAlign: align,
    },
    posted: {},
  }));

  const { classes, cx } = useStyles();
  return (
    <div className={cx(classes.container)}>
      {value === true ? (
        <span className={cx(classes.pending)}>Pendng</span>
      ) : (
        <span className={cx(classes.posted)}>Posted</span>
      )}
    </div>
  );
}
