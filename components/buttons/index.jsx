import { Anchor, Button } from "@mantine/core";
import React from "react";

function SecondaryButton({ children, ...rest }) {
  return (
    <Button variant="default" {...rest}>
      {children}
    </Button>
  );
}

function PrimaryButton({ children, ...rest }) {
  return <Button {...rest}>{children}</Button>;
}

function PrimaryLinkButton({ children, href, ...rest }) {
  return (
    <Anchor href={href}>
      <PrimaryButton {...rest}>{children}</PrimaryButton>
    </Anchor>
  );
}
function SecondaryLinkButton({ children, href, ...rest }) {
  return (
    <PrimaryLinkButton href={href} variant="outline" {...rest}>
      {children}
    </PrimaryLinkButton>
  );
}

export {
  SecondaryButton,
  PrimaryButton,
  PrimaryLinkButton,
  SecondaryLinkButton,
};
