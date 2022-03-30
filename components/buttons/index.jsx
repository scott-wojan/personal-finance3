import { Anchor, Button } from "@mantine/core";
import React from "react";

export function SecondaryButton({ children, ...rest }) {
  return (
    <Button variant="default" {...rest}>
      {children}
    </Button>
  );
}

export function PrimaryLinkButton({ children, href, ...rest }) {
  return (
    <Anchor href={href}>
      <Button {...rest}>{children}</Button>
    </Anchor>
  );
}
export function SecondaryLinkButton({ children, href, ...rest }) {
  return (
    <PrimaryLinkButton href={href} variant="outline" {...rest}>
      {children}
    </PrimaryLinkButton>
  );
}
