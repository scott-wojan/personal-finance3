import { Button, Group, Stepper } from "@mantine/core";
import React, { useState } from "react";

export default function Wizard({ style = {}, children }) {
  const [currentStep, setCurent] = useState(0);
  if (!children) return null;

  const numberOfChildren = React.Children.count(children) ?? 0;

  const nextStep = () =>
    setCurent((current) =>
      current < numberOfChildren ? current + 1 : current
    );
  const prevStep = () =>
    setCurent((current) => (current > 0 ? current - 1 : current));

  const components = Array.isArray(children) ? children : [children];

  return (
    <div style={{}}>
      <div>
        {/* {components.map((child, index) => {
          // console.log("child.props", child.props);
          return <>{child}</>;
        })} */}
        {components[currentStep]}
      </div>
      <Group position="center" mt="xl">
        <Button
          variant="default"
          onClick={prevStep}
          disabled={currentStep === 0}
        >
          Back
        </Button>
        <Button onClick={nextStep}>
          {currentStep === numberOfChildren ? "Complete" : "Next step"}
        </Button>
      </Group>
    </div>
  );
}

{
  /* <Stepper
style={{ ...style }}
size="lg"
active={active}
breakpoint="sm"
// onStepClick={setActive}
// iconPosition="right"
>
{components.map((child, index) => {
  // console.log("child.props", child.props);
  return (
    <Stepper.Step key={index} {...child.props}>
      <>{child}</>
    </Stepper.Step>
  );
})}
</Stepper> */
}
