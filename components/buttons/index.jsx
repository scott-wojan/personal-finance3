import { Anchor, Button } from "@mantine/core";
import React from "react";

export function SecondaryButton({ children, ...rest }) {
  return (
    <Button variant="default" {...rest}>
      {children}
    </Button>
  );
}

export function PrimaryButton({ children, ...rest }) {
  return <Button {...rest}>{children}</Button>;
}

export function PrimaryLinkButton({ children, href, ...rest }) {
  return (
    <Anchor href={href}>
      <PrimaryButton {...rest}>{children}</PrimaryButton>
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
