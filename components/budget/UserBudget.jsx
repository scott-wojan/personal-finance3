import faker from "@faker-js/faker";
import { createStyles, RangeSlider, Table, Title } from "@mantine/core";
import { groupBy } from "formatting";
import { useApi } from "hooks/useApi";
import React, { Fragment, useEffect, useState } from "react";

export default function UserBudget() {
  // @ts-ignore
  const useStyles = createStyles((theme) => ({
    table: {
      // tableLayout: "fixed",
      fontSize: 14,
      borderCollapse: "collapse",
      tr: {
        borderBottom: "1px solid #ddd",
      },
      "thead th": {
        textAlign: "center !important",
      },
      "tbody td": {
        minWidth: 80,
      },
      "thead tr:nth-of-type(1)": {
        borderBottom: 0,
      },
      "table, th, td": {
        // borderLeft: "1px solid",
        // borderRight: "1px solid",
      },
      td: {
        // paddingTop: "12px !important",
        // paddingBottom: "2px !important",
        // borderBottom: "0 !important",
      },
      "tbody td:nth-of-type(n+2)": {
        textAlign: "center",
      },
      "tbody tr td:last-child": {
        minWidth: 260,
      },
      th: {
        fontWeight: "400 !important",
      },
      "th.main": {
        fontWeight: "700 !important",
        textAlign: "left",
      },
    },
    category: {
      fontWeight: 600,
    },
    subcategory: {
      paddingLeft: `${theme.spacing.lg}px !important`,
    },
  }));

  const { classes, cx } = useStyles();

  const { isLoading, error, data } = useApi({
    url: "budget",
  });

  if (error) {
    // @ts-ignore
    return <div>ERROR... {error.message}</div>;
  }

  return (
    <>
      <Title order={3} pb="sm">
        Budget
      </Title>
      <table className={cx(classes.table)}>
        <thead>
          <tr>
            <th></th>
            <th className="main" colSpan={2}></th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <th className="main">Category</th>
            <th>Minimum</th>
            <th>Max</th>
            <th>Range Selection</th>
          </tr>
          {data &&
            Object.entries(groupBy(data, "user_category")).map(
              ([key, value]) => {
                return (
                  <Fragment key={key}>
                    <tr>
                      <td className={cx(classes.category)}>{key}</td>
                      <td></td>
                      <td></td>
                      <td></td>
                    </tr>
                    {value.map((subcategory) => {
                      console.log("subcategory", subcategory);
                      return (
                        <BudgetRow
                          key={subcategory.user_subcategory}
                          subcategory={subcategory}
                        />
                        // <tr key={subcategory.user_subcategory}>
                        //   <td className={cx(classes.subcategory)}>
                        //     {subcategory.user_subcategory}
                        //   </td>

                        //   <td className="center">
                        //     {`$${faker.datatype.number({
                        //       min: 22,
                        //       max: 78,
                        //     })}`}
                        //   </td>
                        //   <td className="center">
                        //     {`$${faker.datatype.number({
                        //       min: 22,
                        //       max: 78,
                        //     })}`}
                        //   </td>
                        //   <td className="center">
                        //     <BudgetRangeSlider
                        //       marks={[
                        //         { value: 25, label: `Min $${25}` },
                        //         { value: 50, label: `Avg $${45}` },
                        //         { value: 75, label: `Max $${75}` },
                        //       ]}
                        //     />
                        //   </td>
                        // </tr>
                      );
                    })}
                  </Fragment>
                );
              }
            )}
        </tbody>
      </table>
    </>
  );
}

function BudgetRow({ subcategory }) {
  const useStyles = createStyles((theme) => ({
    subcategory: {
      paddingLeft: `${theme.spacing.lg}px !important`,
    },
  }));

  const { classes, cx } = useStyles();

  return (
    <tr>
      <td className={cx(classes.subcategory)}>
        {subcategory.user_subcategory}
      </td>

      <td className="center">
        {`$${faker.datatype.number({
          min: 22,
          max: 78,
        })}`}
      </td>
      <td className="center">
        {`$${faker.datatype.number({
          min: 22,
          max: 78,
        })}`}
      </td>
      <td className="center">
        <BudgetRangeSlider
          marks={[
            { value: 25, label: `Min $${25}` },
            { value: 50, label: `Avg $${45}` },
            { value: 75, label: `Max $${75}` },
          ]}
        />
      </td>
    </tr>
  );
}

function BudgetRangeSlider({ marks, onChange }) {
  const [showMarks, setShowMarks] = useState(false);
  return (
    <div
      onFocus={(e) => {
        setShowMarks(true);
      }}
      onBlur={(e) => {
        setShowMarks(false);
      }}
    >
      <RangeSlider
        labelAlwaysOn={false}
        precision={0}
        minRange={0}
        size="xs"
        label={(val) => `$${val}`}
        showLabelOnHover={true}
        onChangeEnd={onChange}
        max={100}
        step={1}
        min={0}
        defaultValue={[10, 90]}
        marks={showMarks ? marks : []}
      />
      {/* <div>&gt;= $12, ~$24, &lt;=$54</div> */}
    </div>
  );
}
