import {
  Accordion,
  Button,
  Group,
  List,
  SimpleGrid,
  Table,
  Title,
  useAccordionState,
  useMantineTheme,
} from "@mantine/core";
import { Application } from "components/app/Application";
import React from "react";
import { CircleCheck, MapPin, User } from "tabler-icons-react";

function FinanceTable({ children }) {
  return (
    <Table
      sx={(theme) => ({
        width: "auto",
        height: "100px",
        "tr td:not(:first-of-type)": {
          textAlign: "right",
        },
        "tr th:not(:first-of-type)": {
          textAlign: "right",
        },
        "tbody tr td": {
          verticalAlign: "top",
          padding: "2px 7px",
        },
        "thead tr th": {
          textAlign: "left",
          fontWeight: 800,
          fontSize: theme.fontSizes.md,
        },
        ".first": {
          paddingLeft: theme.spacing.xl,
          fontWeight: 600,
        },
        ".second": {
          paddingLeft: theme.spacing.xl * 2,
        },
      })}
    >
      {children}
    </Table>
  );
}

export default function FinancialStatement() {
  const breakpoints = [
    { maxWidth: "sm", cols: 1 },
    { maxWidth: "md", cols: 1 },
    { maxWidth: "lg", cols: 3 },
  ];
  return (
    <Application>
      <Title order={3}>Financial Statement</Title>
      <SimpleGrid cols={3} breakpoints={breakpoints}>
        <FinanceTable>
          <thead>
            <tr>
              <th>Assets</th>
              <th>Total</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td className="first">Cash Accounts</td>
              <td></td>
            </tr>
            <tr>
              <td className="second">Checking</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">Savings</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">Certificates of Deposit (CDs)</td>
              <td>$2,452,342.00</td>
            </tr>

            <tr>
              <td className="first">Investments</td>
              <td></td>
            </tr>
            <tr>
              <td className="second">Checking</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">Life Insurance (cash value)</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">Brokerage Accounts (non-retirement)</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">
                Securities (stocks, bonds, mutual funds)
              </td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">Investment Real Estate (market value)</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">Treasury Bills/Notes</td>
              <td>$2,452,342.00</td>
            </tr>

            <tr>
              <td className="first">Personal Property</td>
              <td></td>
            </tr>
            <tr>
              <td className="second">Primary Residence (market value)</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">Automobiles (market value)</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">Bullion (silver, gold, etc)</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">Treasury Bills/Notes</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">Jewelry, Art and Collectibles</td>
              <td>$2,452,342.00</td>
            </tr>

            <tr>
              <td className="first">Retirement</td>
              <td></td>
            </tr>
            <tr>
              <td className="second">Individual Retirement Account (IRA)</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">Workplace Savings Plan (401k)</td>
              <td>$2,452,342.00</td>
            </tr>
          </tbody>
        </FinanceTable>

        <FinanceTable>
          <thead>
            <tr>
              <th>Liabilities</th>
              <th>Total</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td className="first">Real Estate</td>
              <td></td>
            </tr>
            <tr>
              <td className="second">Mortgage primary residence</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">Mortgage investment property</td>
              <td>$2,452,342.00</td>
            </tr>

            <tr>
              <td className="first">Loans</td>
              <td></td>
            </tr>
            <tr>
              <td className="second">Auto Loans</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">Student Loans</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="second">Personal Loans</td>
              <td>$2,452,342.00</td>
            </tr>
          </tbody>
        </FinanceTable>

        <FinanceTable>
          <thead>
            <tr>
              <th>Net Worth</th>
              <th>Total</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td className="first">Total Assets</td>
              <td>$2,452,342.00</td>
            </tr>
            <tr>
              <td className="first">Total Liabilities</td>
              <td>-$2,452,342.00</td>
            </tr>
            <tr>
              <td className="first">Current Net Worth</td>
              <td>$2,452,342.00</td>
            </tr>
          </tbody>
        </FinanceTable>
      </SimpleGrid>
    </Application>
  );
}
