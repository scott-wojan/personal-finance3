import {
  Text,
  Accordion,
  Button,
  Center,
  Group,
  SimpleGrid,
  Stack,
  useAccordionState,
  useMantineTheme,
  List,
  Title,
  ActionIcon,
  createStyles,
  Paper,
  TextInput,
  Box,
} from "@mantine/core";

import React, { useReducer, useState } from "react";
import { CircleCheck, MapPin, Trash, User } from "tabler-icons-react";
import Image from "next/image";
import { MonetaryInput } from "components/inputs/MonetaryInput";
import { useForm, formList } from "@mantine/form";
import { useSetState } from "@mantine/hooks";

const ON_GOALS_SELECTED = "ON_GOALS_SELECTED";
const ON_DEPOSITORY_SELECTED = "ON_DEPOSITORY_SELECTED";
const ON_INVESTMENTS_SELECTED = "ON_INVESTMENTS_SELECTED";

function onboardingWizardReducer(state, { type, payload }) {
  switch (type) {
    case ON_GOALS_SELECTED:
      return {
        ...state,
        currentStep: state.currentStep + 1,
        goals: payload,
      };
    case ON_DEPOSITORY_SELECTED:
    case ON_INVESTMENTS_SELECTED:
      return {
        ...state,
        currentStep: state.currentStep + 1,
      };
    default:
      throw new Error(`Unhandled action type: ${type}`);
  }
}

const onboardingWizardDefaults = {
  currentStep: 0,
  goals: {
    budget: false,
    financialHeath: false,
  },
};

export default function Onboarding() {
  const [state, setState] = useSetState({
    isNextButtonEnabled: false,
    wantsToBudget: undefined,
    wantsFinancialUnderstading: undefined,
  });

  // return <ManualOrImport />;
  // return <OnboardingAccordian />;
  return (
    <OnboardingWizard>
      <Goals />
      <DepositoryAccounts />
      <InvestmentAccounts />
      <LoanAccounts />
      <Review />
      {/* <SelectTypesOfAccounts state={state} setState={setState} /> */}
      {/* <Demo /> */}
      {/* <ManualOrImport />
      <Savings />
      <Checking /> */}
    </OnboardingWizard>
  );
}

function OnboardingWizard({ children }) {
  const [state, dispatch] = useReducer(
    onboardingWizardReducer,
    onboardingWizardDefaults
  );
  const components = (Array.isArray(children) ? children : [children]).map(
    (component) => {
      return React.cloneElement(component, { state, dispatch }, null);
    }
  );
  return (
    <Center style={{ height: "100vh" }}>
      <Paper shadow="xs" p="md" style={{ width: 800 }}>
        {components[state.currentStep]}
      </Paper>
    </Center>
  );
}

function Goals({ state: wizardState, dispatch }) {
  const [state, setState] = useSetState(wizardState.goals);

  const onNextClicked = () => {
    dispatch({ type: ON_GOALS_SELECTED, payload: state });
  };

  return (
    <OnboardingTile
      title="What are your goals today?"
      subtitle="Select all options that apply"
    >
      <OnboardingContentGrid numberOfColumns={2}>
        <IconOption
          height={200}
          width={200}
          icon={{ src: "/onboarding/icons8-accounting-80.png", size: 60 }}
          isSelected={state.budget}
          setIsSelected={(selected) => {
            setState({ budget: selected });
          }}
          text={{
            text: "I'd like to create a budget",
            size: "md",
          }}
        />
        <IconOption
          height={200}
          width={200}
          isSelected={state.financialHeath}
          setIsSelected={(selected) => {
            setState({ financialHeath: selected });
          }}
          icon={{ src: "/onboarding/icons8-combo-chart-80.png", size: 60 }}
          text={{
            text: "I’d like to understand my financial health",
            size: "md",
          }}
        />
      </OnboardingContentGrid>
      <WizardButtons
        nextButton={{
          isDisabled: !state.budget && !state.financialHeath,
          onClick: onNextClicked,
        }}
      />
    </OnboardingTile>
  );
}

function IconListItem({ imgSrc, text }) {
  return (
    <List.Item
      icon={
        <Image width={24} height={24} alt="xxx" src={`/onboarding/${imgSrc}`} />
      }
    >
      {text}
    </List.Item>
  );
}

function DepositoryAccounts({ dispatch }) {
  const onNextClicked = () => {
    dispatch({ type: ON_DEPOSITORY_SELECTED, payload: null });
  };

  return (
    <OnboardingTile
      title="Let's connect your depository accounts"
      subtitle="Connecting these will help you with budgeting, cash flow and determining net worth"
    >
      <OnboardingContentGrid numberOfColumns={2}>
        <List>
          <IconListItem text="Savings" imgSrc="icons8-money-100.png" />
          <IconListItem text="Checking" imgSrc="icons8-check-book-80.png" />
        </List>
        <List>
          <IconListItem
            text="Certificate of deposit"
            imgSrc="icons8-contract-80.png"
          />
          <IconListItem text="Money market" imgSrc="icons8-coins-80.png" />
        </List>
      </OnboardingContentGrid>
      <WizardButtons
        nextButton={{
          text: "Connect depository accounts",
          isDisabled: false,
          onClick: onNextClicked,
        }}
      />
    </OnboardingTile>
  );
}

function LoanAccounts({ dispatch }) {
  const onNextClicked = () => {
    dispatch({ type: ON_DEPOSITORY_SELECTED, payload: null });
  };

  return (
    <OnboardingTile
      title="Finally, let's connect your loan accounts"
      subtitle="Connecting these will help you determine your net worth"
    >
      <OnboardingContentGrid numberOfColumns={2}>
        <List>
          <IconListItem
            text="Credit cards"
            imgSrc="icons8-debit-card-100.png"
          />

          <IconListItem text="Auto loans" imgSrc="icons8-car-80.png" />
          <IconListItem
            text="Construction loans"
            imgSrc="icons8-construction-80.png"
          />
        </List>
        <List>
          <IconListItem
            text="Home equity line of credit"
            imgSrc="icons8-rent-80.png"
          />
          <IconListItem text="Mortgage" imgSrc="icons8-house-80.png" />
          <IconListItem
            text="Student loan"
            imgSrc="icons8-graduation-cap-80.png"
          />
        </List>
      </OnboardingContentGrid>
      <WizardButtons
        nextButton={{
          text: "Connect accounts",
          isDisabled: false,
          onClick: onNextClicked,
        }}
      />
    </OnboardingTile>
  );
}

function InvestmentAccounts({ state: wizardState, dispatch }) {
  const onNextClicked = () => {
    dispatch({ type: ON_DEPOSITORY_SELECTED, payload: null });
  };

  /*
  https://smartasset.com/investing/types-of-investment
  */

  return (
    <OnboardingTile
      title="Let's connect your investment accounts"
      subtitle="Connecting these will help you determine your net worth"
    >
      <OnboardingContentGrid numberOfColumns={2}>
        <List>
          <IconListItem text="401K" imgSrc="icons8-money-box-100.png" />
          <IconListItem text="Stocks" imgSrc="icons8-diploma-80.png" />
          <IconListItem
            text="Exchange-Traded funds"
            imgSrc="icons8-investment-portfolio-80.png"
          />
          <IconListItem
            text="Mutual funds"
            imgSrc="icons8-crowdfunding-80.png"
          />
        </List>
        <List>
          <IconListItem text="IRA" imgSrc="icons8-money-bag-80.png" />
          <IconListItem text="Bonds" imgSrc="icons8-bonds-100.png" />

          <IconListItem
            text="Annuities"
            imgSrc="icons8-duration-finance-80.png"
          />
          <IconListItem
            text="Education savings eg: 529"
            imgSrc="icons8-university-80.png"
          />
        </List>
      </OnboardingContentGrid>
      <WizardButtons
        nextButton={{
          text: "Connect accounts",
          isDisabled: false,
          onClick: onNextClicked,
        }}
      />
    </OnboardingTile>
  );
}

function Review() {
  return <div>Review</div>;
}

function OnboardingTile({ title, subtitle, children }) {
  const theme = useMantineTheme();
  return (
    <SimpleGrid style={{ justifyItems: "center" }}>
      <Title order={2}>{title}</Title>
      <Title order={5} style={{ color: theme.colors.gray[6] }}>
        {subtitle}
      </Title>
      {children}
    </SimpleGrid>
  );
}

function OnboardingContentGrid({ numberOfColumns, children }) {
  const breakpoints = [{ maxWidth: "sm", cols: 1 }];
  return (
    <SimpleGrid
      cols={numberOfColumns}
      // @ts-ignore
      breakpoints={breakpoints}
      style={{ justifyItems: "center" }}
    >
      {children}
    </SimpleGrid>
  );
}

function WizardButtons({ nextButton }) {
  return (
    <Group position="apart" mt="xl">
      <Button
        disabled={nextButton?.isDisabled ?? true}
        onClick={nextButton?.onClick}
      >
        {nextButton?.text ?? "Next"}
      </Button>
    </Group>
  );
}

function OnboardingAccordian() {
  const [state, handlers] = useAccordionState({ total: 3, initialItem: 0 });
  const theme = useMantineTheme();
  const breakpoints = [{ maxWidth: "sm", cols: 1 }];
  return (
    <>
      <Accordion state={state} onChange={handlers.setState} disableIconRotation>
        <Accordion.Item
          label="Getting started"
          icon={<User color={theme.colors.blue[6]} />}
        >
          <Group position="right" mt="xl">
            <Button onClick={() => handlers.toggle(1)}>Next step</Button>
          </Group>
        </Accordion.Item>
        <Accordion.Item
          label="Assets"
          icon={<MapPin color={theme.colors.red[6]} />}
        >
          <SimpleGrid cols={3} breakpoints={breakpoints}>
            <List size="sm">
              Cash
              <List.Item>Checking Accounts</List.Item>
              <List.Item>Savings Accounts</List.Item>
              <List.Item>Certificates of Deposit (CDs)</List.Item>
            </List>

            <List size="sm">
              Investments
              <List.Item>Life Insurance (cash surrender value)</List.Item>
              <List.Item>Brokerage Accounts (non-retirement)</List.Item>
              <List.Item>Securities (stocks, bonds, mutual funds)</List.Item>
              <List.Item>Investment Real Estate (market value)</List.Item>
              <List.Item>Treasury Bills/Notes</List.Item>
            </List>

            <List size="sm">
              Personal Property
              <List.Item>Primary Residence (market value)</List.Item>
              <List.Item>Automobiles (present value)</List.Item>
              <List.Item>Bullion (silver, gold, etc)</List.Item>
              <List.Item>Treasury Bills/Notes</List.Item>
              <List.Item>Jewelry, Art and Collectibles</List.Item>
            </List>

            <List size="sm">
              Retirement
              <List.Item>Retirements Accounts (IRA, 401k)</List.Item>
              <List.Item>Pension and Project Sharing</List.Item>
              <List.Item>Social Security ($/month * 240) </List.Item>
            </List>
          </SimpleGrid>

          <Group position="right" mt="xl">
            <Button variant="default" onClick={() => handlers.toggle(0)}>
              Previous step
            </Button>
            <Button onClick={() => handlers.toggle(2)}>Next step</Button>
          </Group>
        </Accordion.Item>
        <Accordion.Item
          label="Liabilities"
          icon={<CircleCheck color={theme.colors.teal[6]} />}
        >
          <SimpleGrid cols={3} breakpoints={breakpoints}>
            <List size="sm">
              Real Estate
              <List.Item>Mortgage on primary residence</List.Item>
              <List.Item>Mortgages on investment property</List.Item>
            </List>
            <List size="sm">
              Loans
              <List.Item>Auto Loans</List.Item>
              <List.Item>Student Loans</List.Item>
              <List.Item>Personal Loans</List.Item>
            </List>
          </SimpleGrid>
          <Group position="left" mt="xl">
            <Button variant="default" onClick={() => handlers.toggle(1)}>
              Previous step
            </Button>
            <Button onClick={() => handlers.toggle(2)}>See results!</Button>
          </Group>
        </Accordion.Item>
        <Accordion.Item
          label="Net worth and overview"
          icon={<CircleCheck color={theme.colors.teal[6]} />}
        >
          <SimpleGrid cols={3} breakpoints={breakpoints}>
            <List size="sm">
              Real Estate
              <List.Item>Mortgage on primary residence</List.Item>
              <List.Item>Mortgages on investment property</List.Item>
            </List>
            <List size="sm">
              Common financial ratios
              <List.Item>
                Debt-to-Assets Ratio (Total Liabilities / Total Assets)
              </List.Item>
              <List.Item>
                Basic Liquidity Ratio (Liquid Assets / Monthly Living Expenses)
              </List.Item>
              <List.Item>
                Investment-Assets-to-Net-Worth Ratio (Investment Assets / Net
                Worth)
              </List.Item>
            </List>
          </SimpleGrid>
        </Accordion.Item>
      </Accordion>
    </>
  );
}

function IconOption({
  icon,
  text,
  isSelected = false,
  setIsSelected = undefined,
  height = 120,
  width = 120,
}) {
  const imgInfo = typeof icon === "string" ? { src: icon, size: 40 } : icon;
  const textInfo = typeof text === "string" ? { text, size: "xs" } : text;

  const useStyles = createStyles((theme) => ({
    option: {
      cursor: "pointer",
      display: "flex",
      alignItems: "center",
      height,
      width,
      paddingTop: theme.spacing.sm,
      paddingBottom: theme.spacing.sm,
      paddingLeft: theme.spacing.xs,
      paddingRight: theme.spacing.xs,
      backgroundColor: isSelected ? theme.colors[theme.primaryColor][0] : "",
      border: `1px solid ${
        isSelected ? theme.colors[theme.primaryColor][6] : theme.colors.gray[4]
      }`,
      borderRadius: theme.spacing.xs,
      "&:hover": {
        backgroundColor: theme.colors[theme.primaryColor][0],
        border: `1px solid ${theme.colors[theme.primaryColor][6]}`,
      },
      svg: {
        color: theme.colors[theme.primaryColor][6],
      },
    },
  }));

  const { classes, cx } = useStyles();

  return (
    <div
      className={cx(classes.option)}
      onClick={() => {
        setIsSelected(!isSelected);
      }}
    >
      <Stack
        align="center"
        sx={(theme) => ({
          gap: 6,
          width: "100%",
        })}
      >
        {!isSelected && icon && (
          <Image
            width={imgInfo.size}
            height={imgInfo.size}
            alt={text}
            src={imgInfo.src}
          />
        )}
        {isSelected && <CircleCheck size={imgInfo.size} strokeWidth={1} />}
        <Text size={textInfo.size} style={{ textAlign: "center" }} weight={600}>
          {textInfo.text}
        </Text>
      </Stack>
    </div>
  );
}
