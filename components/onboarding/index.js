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
  RadioGroup,
  Radio,
  TextInput,
  Box,
} from "@mantine/core";
import Wizard from "components/wizard";
import Step from "components/wizard/Step";
import React, { useState } from "react";
import { CircleCheck, MapPin, Trash, User } from "tabler-icons-react";
import Image from "next/image";
import { MonetaryInput } from "components/inputs/MonetaryInput";
import { useForm, formList } from "@mantine/form";

export default function Onboarding() {
  const theme = useMantineTheme();
  const breakpoints = [{ maxWidth: "sm", cols: 1 }];
  // return <ManualOrImport />;
  // return <OnboardingAccordian />;
  return (
    <Center style={{ height: "100vh" }}>
      <Paper shadow="xs" p="md">
        <Wizard style={{ width: 600 }}>
          <Demo />
          <ManualOrImport />
          <Savings />
          <Checking />
        </Wizard>
      </Paper>
    </Center>
  );
}

function Demo() {
  const form = useForm({
    initialValues: {
      employees: formList([{ name: "", active: false }]),
    },
  });

  const fields = form.values.employees.map((_, index) => (
    <Group key={index} mt="xs">
      <TextInput
        placeholder="financial institution name"
        required
        sx={{ flex: 1 }}
        {...form.getListInputProps("employees", index, "name")}
      />
      <MonetaryInput
        {...form.getListInputProps("employees", index, "active")}
      />
      <ActionIcon
        color="red"
        variant="hover"
        onClick={() => form.removeListItem("employees", index)}
      >
        <Trash size={16} />
      </ActionIcon>
    </Group>
  ));

  return (
    <Box sx={{ maxWidth: 500 }} mx="auto">
      {fields.length > 0 ? (
        <Group mb="xs">
          <Text weight={500} size="sm" sx={{ flex: 1 }}>
            Financial Institution
          </Text>
          <Text weight={500} size="sm" pr={80}>
            Amount
          </Text>
        </Group>
      ) : (
        <Text color="dimmed" align="center">
          No one here...
        </Text>
      )}

      {fields}

      <Group position="left" mt="xs">
        <Button
          variant="outline"
          onClick={() =>
            form.addListItem("employees", { name: "", active: false })
          }
        >
          Add more
        </Button>
      </Group>
    </Box>
  );
}

function ManualOrImport() {
  const theme = useMantineTheme();
  const breakpoints = [{ maxWidth: "sm", cols: 1 }];
  const [isManualEntry, setIsManualEntry] = useState(false);
  const [isImport, setIsImport] = useState(false);

  return (
    <SimpleGrid style={{ justifyItems: "center" }}>
      <Title order={2}>Let's start understanding your financial future</Title>
      <Title order={5} style={{ color: theme.colors.gray[6] }}>
        How would you like to get started?
      </Title>
      <SimpleGrid
        cols={2}
        breakpoints={breakpoints}
        style={{ justifyItems: "center" }}
      >
        <IconOption
          height={200}
          width={200}
          icon={{ src: "/onboarding/icons8-import-100.png", size: 60 }}
          isSelected={isImport}
          setIsSelected={(isSelected) => {
            setIsImport(isSelected);
            setIsManualEntry(false);
          }}
          text={{
            text: "Import my information for me",
            size: "md",
          }}
        />
        <IconOption
          height={200}
          width={200}
          isSelected={isManualEntry}
          setIsSelected={(isManual) => {
            setIsManualEntry(isManual);
            setIsImport(false);
          }}
          icon={{ src: "/onboarding/icons8-form-100.png", size: 60 }}
          text={{
            text: "I'll enter all information manually",
            size: "md",
          }}
        />
      </SimpleGrid>
    </SimpleGrid>
  );
}

function Savings() {
  const theme = useMantineTheme();
  const breakpoints = [{ maxWidth: "sm", cols: 1 }];
  return (
    <SimpleGrid cols={1} breakpoints={breakpoints} style={{}}>
      <Title order={2}>Let's discover your assets</Title>
      <Title order={5} style={{ color: theme.colors.gray[6] }}>
        Do you have a savings account?
      </Title>
      <Group align="center">
        <Image
          width={40}
          height={40}
          alt="Savings"
          src="/onboarding/icons8-bank-building-100.png"
        />
        <TextInput size="xs" label="Financial institution name" required />
        <MonetaryInput label="Amount" value={0} required />
      </Group>
    </SimpleGrid>
  );
}

function Checking() {
  const theme = useMantineTheme();
  const breakpoints = [{ maxWidth: "sm", cols: 1 }];
  return (
    <SimpleGrid cols={1} breakpoints={breakpoints} style={{}}>
      <Title order={2}>Let's discover your assets</Title>
      <Title order={5} style={{ color: theme.colors.gray[6] }}>
        Do you have a checking account?
      </Title>
      <Group align="center">
        <Image
          width={40}
          height={40}
          alt="Savings"
          src="/onboarding/icons8-merchant-account-100.png"
        />
        <TextInput size="xs" label="Financial institution name" required />
        <MonetaryInput label="Amount" value={0} required />
      </Group>
    </SimpleGrid>
  );
}

function Select2() {
  const theme = useMantineTheme();
  const breakpoints = [{ maxWidth: "sm", cols: 1 }];
  return (
    <SimpleGrid
      cols={1}
      breakpoints={breakpoints}
      style={{ justifyItems: "center" }}
    >
      <Title order={2}>What types of assets do you have?</Title>
      <Title order={5} style={{ color: theme.colors.gray[6] }}>
        Select all that apply
      </Title>
      <SimpleGrid
        cols={5}
        breakpoints={breakpoints}
        style={{ justifyItems: "center" }}
      >
        <IconOption
          icon="/onboarding/icons8-money-100.png"
          text="Have a savings account"
        />
        <IconOption
          icon="/onboarding/icons8-merchant-account-100.png"
          text="Have a checking account"
        />
        <IconOption
          icon="/onboarding/icons8-debit-card-100.png"
          text="Have a credit card"
        />
        <IconOption
          icon="/onboarding/icons8-clinic-100.png"
          text="Have life insurance"
        />
        <IconOption
          icon="/onboarding/icons8-bonds-100.png"
          text="Have Stocks, bonds, or funds"
        />
        <IconOption
          icon="/onboarding/icons8-home-100.png"
          text="Own a home or investment property"
        />
        <IconOption
          icon="/onboarding/icons8-car-100.png"
          text="Own an automobile"
        />
        <IconOption
          icon="/onboarding/icons8-money-box-100.png"
          text="Have IRA or 401k accounts"
        />
        <IconOption
          icon="/onboarding/icons8-bank-building-100.png"
          text="Collect Social Security"
        />
        <IconOption
          icon="/onboarding/icons8-university-100.png"
          text="Student or other loans"
        />
      </SimpleGrid>
    </SimpleGrid>
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

function WizardForm() {
  return (
    <Center style={{ height: "100vh" }}>
      <Wizard style={{ width: 600 }}>
        <Step
          title="Step 1"
          label="Getting Started"
          description="Create an account"
        >
          Step 1
        </Step>
        <Step label="Assets" description="Create an account" title="Step 2">
          Step 2
        </Step>
      </Wizard>
    </Center>
  );
}
